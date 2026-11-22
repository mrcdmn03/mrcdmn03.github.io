"""Fictional teaching examples: NOT university-assessment data."""
import argparse
from pathlib import Path
import numpy as np
import pandas as pd

def generate(out_dir, seed=2026):
    out_dir=Path(out_dir);out_dir.mkdir(parents=True,exist_ok=True)
    rng=np.random.default_rng(seed)
    n=100
    age=rng.integers(21,75,n);salary=rng.integers(26000,80000,n)
    maintenance=rng.integers(600,2600,n)
    comfort=rng.integers(35,100,n);advertised=rng.integers(0,101,n)
    value=np.clip(20+.24*comfort+.16*advertised-.002*maintenance+rng.normal(0,12,n),0,100)
    pd.DataFrame(dict(ID=np.arange(1,n+1),Age=age,Salary=salary,Maintenance=maintenance,
        Comfort=comfort,Advertised=advertised,CarValue=value.round(2))).to_csv(out_dir/"TaskA_CarPurchase.csv",index=False)
    fields=["Workload","JobControl","SocialSupport","Leadership","Rewards","Security",
        "Communication","Stress","Growth","Teamwork","Facilities","Autonomy","Fairness","Flexibility"]
    wellbeing=np.clip(rng.normal(60,20,(120,len(fields))),0,100).round().astype(int)
    pd.DataFrame(wellbeing,columns=fields).to_csv(out_dir/"TaskB_Wellbeing.csv",index=False)
    types=rng.integers(0,3,100)
    centres=np.array([[80,35,40,85],[70,35,75,80],[90,50,65,30]])
    vals=np.clip(centres[types]+rng.normal(0,10,(100,4)),0,100).round().astype(int)
    pd.DataFrame(dict(MemberID=np.arange(1,101),Fitness=vals[:,0],Social=vals[:,1],
        Facilities=vals[:,2],Cost=vals[:,3])).to_csv(out_dir/"TaskC_GymMotivation.csv",index=False)

if __name__=="__main__":
    p=argparse.ArgumentParser();p.add_argument("--output-dir",default="data/demo")
    args=p.parse_args();generate(args.output_dir)
    print("Fictional demonstration CSV files created in",args.output_dir)
