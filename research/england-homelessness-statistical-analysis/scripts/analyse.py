"""Descriptive statistics for public-sector quarterly homelessness data."""
from pathlib import Path
import argparse,json
import numpy as np
import pandas as pd
from scipy import stats
import statsmodels.api as sm
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

REQUIRED=["year","quarter","total_initial_assessments","total_duty","prevention_duty","relief_duty"]

def analyse(frame):
    absent=set(REQUIRED)-set(frame.columns)
    if absent:raise ValueError(f"Missing columns {sorted(absent)}")
    data=frame[REQUIRED].copy()
    for field in REQUIRED:
        if field!="quarter":data[field]=pd.to_numeric(data[field],errors="coerce")
    data=data.dropna(subset=["year","total_duty","prevention_duty","relief_duty"])
    if len(data)<8:raise ValueError("Need at least 8 valid quarterly rows")
    annual=data.groupby("year").agg(
        n_quarters=("total_duty","size"),
        mean_total_duty=("total_duty","mean"),
        mean_prevention=("prevention_duty","mean"),
        mean_relief=("relief_duty","mean")).reset_index()
    pearson=stats.pearsonr(data["prevention_duty"],data["relief_duty"])
    fitted=sm.OLS(data["total_duty"],sm.add_constant(data["year"],has_constant="add")).fit()
    groups=[part["total_duty"].values for _,part in data.groupby("year") if len(part)>=2]
    anova=stats.f_oneway(*groups) if len(groups)>1 else None
    summary={
        "n_quarters":int(len(data)),
        "annual_means":annual.to_dict("records"),
        "prevention_vs_relief":{"pearson_r":float(pearson.statistic),"p_value":float(pearson.pvalue)},
        "simple_time_trend":{"slope_per_year":float(fitted.params["year"]),
                             "r_squared":float(fitted.rsquared),
                             "p_value":float(fitted.pvalues["year"])},
        "one_way_anova_p":float(anova.pvalue) if anova else None}
    return summary,annual,fitted,data

def run(source,out_dir):
    source=Path(source);out=Path(out_dir);out.mkdir(parents=True,exist_ok=True)
    result,annual,fit,data=analyse(pd.read_csv(source))
    (out/"summary.json").write_text(json.dumps(result,indent=2))
    annual.to_csv(out/"annual_summary.csv",index=False)
    fig,ax=plt.subplots(figsize=(8,4.5))
    ax.plot(annual.year,annual.mean_total_duty,marker="o")
    ax.set(xlabel="Year",ylabel="Mean quarterly total duty",
           title="England: average quarterly homelessness duty by year")
    fig.tight_layout();fig.savefig(out/"annual_means.png",dpi=160);plt.close(fig)
    fig,ax=plt.subplots(figsize=(7,5))
    ax.scatter(data.year,data.total_duty,alpha=.6)
    xs=np.array([data.year.min(),data.year.max()])
    ax.plot(xs,fit.params["const"]+fit.params["year"]*xs,color="#087b79")
    ax.set(xlabel="Year",ylabel="Quarterly total duty",
           title="Simple linear time trend (not causal)")
    fig.tight_layout();fig.savefig(out/"trend.png",dpi=160);plt.close(fig)
    fig,ax=plt.subplots(figsize=(7,5))
    ax.scatter(data.prevention_duty,data.relief_duty,alpha=.7)
    ax.set(xlabel="Prevention duty",ylabel="Relief duty",
           title="Prevention and relief duty counts")
    fig.tight_layout();fig.savefig(out/"prevention_relief.png",dpi=160);plt.close(fig)
    return result

if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--input",default="data/homelessness_quarterly_2018_2025.csv")
    p.add_argument("--output-dir",default="outputs")
    args=p.parse_args()
    res=run(args.input,args.output_dir)
    print("Quarters:",res["n_quarters"])
    print("Pearson r:",round(res["prevention_vs_relief"]["pearson_r"],4))
    print("Annual slope:",round(res["simple_time_trend"]["slope_per_year"],2))
    print("R2:",round(res["simple_time_trend"]["r_squared"],4))
