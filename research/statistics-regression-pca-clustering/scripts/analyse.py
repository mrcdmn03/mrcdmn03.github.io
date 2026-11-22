"""Runnable Python recreation of methods covered in MS4S08 SAS coursework."""
from pathlib import Path
import argparse, json
import numpy as np
import pandas as pd
import statsmodels.api as sm
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

PREDICTORS=["Age","Salary","Maintenance","Comfort","Advertised"]
WELLBEING=["Workload","JobControl","SocialSupport","Leadership","Rewards","Security",
           "Communication","Stress","Growth","Teamwork","Facilities","Autonomy","Fairness","Flexibility"]
MOTIVATIONS=["Fitness","Social","Facilities","Cost"]

def load(path,fields):
    data=pd.read_csv(path)
    missing=set(fields)-set(data.columns)
    if missing:raise ValueError(f"{path}: missing {sorted(missing)}")
    return data[fields].apply(pd.to_numeric,errors="coerce").dropna()

def regression(frame):
    frame=frame.dropna(subset=PREDICTORS+["CarValue"])
    if len(frame)<10:raise ValueError("Need >= 10 car observations")
    fit=sm.OLS(frame.CarValue,sm.add_constant(frame[PREDICTORS],has_constant="add")).fit()
    coefs=pd.DataFrame({"term":fit.params.index,"coefficient":fit.params.values,
                        "p_value":fit.pvalues.values})
    return {"n":len(frame),"r_squared":float(fit.rsquared),
            "adjusted_r_squared":float(fit.rsquared_adj),
            "model_f_pvalue":float(fit.f_pvalue),
            "coefficients":coefs.to_dict("records")},fit

def wellbeing_pca(frame):
    if len(frame)<10:raise ValueError("Need >= 10 wellbeing observations")
    pca=PCA().fit(StandardScaler().fit_transform(frame[WELLBEING]))
    return {"n":len(frame),"eigenvalues":pca.explained_variance_.tolist(),
            "explained_variance_ratio":pca.explained_variance_ratio_.tolist(),
            "components_over_one":int((pca.explained_variance_>1).sum())},pca

def segment(frame):
    if len(frame)<6:raise ValueError("Need >= 6 gym observations")
    scaled=StandardScaler().fit_transform(frame[MOTIVATIONS])
    model=KMeans(n_clusters=3,n_init=20,random_state=42).fit(scaled)
    means=frame.assign(cluster=model.labels_+1).groupby("cluster").agg(
        **{name+"_mean":(name,"mean") for name in MOTIVATIONS},
        count=("Fitness","size")).round(2).reset_index()
    return {"n":len(frame),"clusters":3,"profiles":means.to_dict("records")}

def run(input_dir,output_dir):
    root=Path(input_dir);out=Path(output_dir);out.mkdir(parents=True,exist_ok=True)
    cars=load(root/"TaskA_CarPurchase.csv",PREDICTORS+["CarValue"])
    wellbeing=load(root/"TaskB_Wellbeing.csv",WELLBEING)
    gym=load(root/"TaskC_GymMotivation.csv",MOTIVATIONS)
    r,fit=regression(cars);p,pca=wellbeing_pca(wellbeing);g=segment(gym)
    result={"provenance":"Results correspond to the input datasets, not the original SAS submission.",
            "regression":r,"pca":p,"clustering":g}
    (out/"summary.json").write_text(json.dumps(result,indent=2))
    pd.DataFrame(r["coefficients"]).to_csv(out/"regression_coefficients.csv",index=False)
    pd.DataFrame(g["profiles"]).to_csv(out/"gym_cluster_profiles.csv",index=False)
    fig,ax=plt.subplots(figsize=(7,5))
    ax.scatter(cars.CarValue,fit.fittedvalues,s=20,alpha=.7)
    ax.set(xlabel="Observed car value",ylabel="Predicted car value",title="Multiple regression")
    fig.tight_layout();fig.savefig(out/"car_regression.png",dpi=160);plt.close(fig)
    fig,ax=plt.subplots(figsize=(7,4))
    ax.plot(range(1,len(pca.explained_variance_)+1),pca.explained_variance_,marker="o")
    ax.axhline(1,color="grey",linestyle="--")
    ax.set(xlabel="Component",ylabel="Eigenvalue",title="Wellbeing PCA scree plot")
    fig.tight_layout();fig.savefig(out/"wellbeing_scree.png",dpi=160);plt.close(fig)
    profiles=pd.DataFrame(g["profiles"]).set_index("cluster")
    axes=profiles[[x+"_mean" for x in MOTIVATIONS]].rename(
        columns={x+"_mean":x for x in MOTIVATIONS}).T.plot(kind="bar",figsize=(8,4.5))
    axes.set(ylabel="Mean original score",title="Three gym motivation clusters")
    axes.tick_params(axis="x",rotation=0)
    axes.figure.tight_layout();axes.figure.savefig(out/"gym_cluster_profiles.png",dpi=160)
    plt.close(axes.figure)
    return result

if __name__=="__main__":
    a=argparse.ArgumentParser();a.add_argument("--input-dir",default="data/demo")
    a.add_argument("--output-dir",default="outputs");args=a.parse_args()
    result=run(args.input_dir,args.output_dir)
    print("Car model R2 =",round(result["regression"]["r_squared"],4))
    print("PCA components with eigenvalue >1 =",result["pca"]["components_over_one"])
    print("Gym profiles =",[x["count"] for x in result["clustering"]["profiles"]])
