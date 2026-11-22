"""Reproducible breast-cancer classification: leakage-safe MSc follow-up.

This is a reviewed derivative of the original university assessment.
It preserves the user's modelling choices (Logistic Regression, Random Forest)
but removes duplicate records and fits preprocessing only on training data.

Not for clinical or diagnostic use.
"""
from pathlib import Path
import argparse
import json

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from sklearn.impute import SimpleImputer
from sklearn.metrics import (
    accuracy_score, classification_report, confusion_matrix,
    ConfusionMatrixDisplay, f1_score, precision_score, recall_score,
    roc_auc_score, RocCurveDisplay,
)
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier

BASE_DIR = Path(__file__).resolve().parents[1]
DATA_PATH = BASE_DIR / "data" / "MS4S16_Dataset.csv"


def load_and_split():
    df = pd.read_csv(DATA_PATH)
    expected = {"diagnosis", "id"}
    if not expected.issubset(df.columns):
        raise ValueError(f"Expected columns missing: {expected - set(df.columns)}")
    n_original = len(df)
    # A target value must be present before fitting a supervised model.
    df = df.dropna(subset=["diagnosis"]).drop_duplicates().copy()
    if not set(df["diagnosis"].unique()).issubset({"B", "M"}):
        raise ValueError("Unexpected diagnosis labels")
    y = df["diagnosis"].map({"B": 0, "M": 1}).astype(int)
    X = df.drop(columns=["id", "diagnosis"])
    X = X.apply(pd.to_numeric, errors="raise")
    # The course CSV uses -999 as an explicit missing-value marker in some columns.
    X = X.replace(-999, np.nan)
    split = train_test_split(X, y, test_size=0.2, random_state=42, stratify=y)
    return split, {"raw_rows": n_original, "clean_rows": len(df),
                   "removed_missing_target_and_duplicate_rows": n_original-len(df),
                   "features": X.shape[1], "missing_numeric_cells_after_sentinel_conversion": int(X.isna().sum().sum()), "class_counts": y.value_counts().sort_index().to_dict()}


def train_models(split):
    X_train, X_test, y_train, y_test = split
    models = {
        "Logistic Regression": Pipeline([
            ("imputer", SimpleImputer(strategy="mean")),
            ("scaler", StandardScaler()),
            ("model", LogisticRegression(max_iter=1000, random_state=42)),
        ]),
        "Random Forest": Pipeline([
            ("imputer", SimpleImputer(strategy="mean")),
            ("model", RandomForestClassifier(n_estimators=200, random_state=42)),
        ]),
    }
    metrics=[]; outputs={}
    for name, model in models.items():
        model.fit(X_train,y_train)
        prediction=model.predict(X_test)
        proba=model.predict_proba(X_test)[:,1]
        report={
            "model":name, "accuracy":float(accuracy_score(y_test,prediction)),
            "precision_malignant":float(precision_score(y_test,prediction,zero_division=0)),
            "recall_malignant":float(recall_score(y_test,prediction,zero_division=0)),
            "f1_malignant":float(f1_score(y_test,prediction,zero_division=0)),
            "roc_auc":float(roc_auc_score(y_test,proba)),
            "false_negatives":int(confusion_matrix(y_test,prediction,labels=[0,1])[1,0]),
            "false_positives":int(confusion_matrix(y_test,prediction,labels=[0,1])[0,1]),
        }
        metrics.append(report)
        outputs[name]={"model":model,"prediction":prediction,"proba":proba,
                       "confusion_matrix":confusion_matrix(y_test,prediction,labels=[0,1]).tolist(),
                       "classification_report":classification_report(y_test,prediction,
                           target_names=["Benign", "Malignant"],zero_division=0)}
    return pd.DataFrame(metrics), outputs


def save_plots(y_test,outputs,figures_dir):
    figures_dir.mkdir(parents=True,exist_ok=True)
    fig,ax=plt.subplots(figsize=(6.5,5))
    for name,out in outputs.items():
        RocCurveDisplay.from_predictions(y_test,out["proba"],name=name,ax=ax)
    ax.plot([0,1],[0,1],"--",color="gray",linewidth=1)
    ax.set_title("ROC curve — held-out test set")
    fig.tight_layout()
    fig.savefig(figures_dir/"roc_comparison.png",dpi=170)
    plt.close(fig)
    for name,out in outputs.items():
        fig,ax=plt.subplots(figsize=(5.6,4.9))
        ConfusionMatrixDisplay(np.array(out["confusion_matrix"]),
             display_labels=["Benign","Malignant"]).plot(ax=ax,cmap="Blues",colorbar=False)
        ax.set_title(f"Confusion matrix — {name}")
        fig.tight_layout()
        fig.savefig(figures_dir/(name.lower().replace(' ','_')+"_confusion_matrix.png"),dpi=170)
        plt.close(fig)


def run(save=True):
    split,data_summary=load_and_split()
    metrics,details=train_models(split)
    if save:
        (BASE_DIR/"results").mkdir(exist_ok=True)
        metrics.to_csv(BASE_DIR/"results"/"model_comparison.csv",index=False,float_format="%.8f")
        detail={"dataset":data_summary,"train_rows":len(split[0]),"test_rows":len(split[1]),
                "models":{k:{"confusion_matrix":v["confusion_matrix"],
                            "classification_report":v["classification_report"]} for k,v in details.items()}}
        (BASE_DIR/"results"/"evaluation_details.json").write_text(json.dumps(detail,indent=2),encoding="utf-8")
        save_plots(split[3],details,BASE_DIR/"figures")
    print("Dataset summary:",data_summary)
    print(metrics.to_string(index=False,float_format=lambda x:f"{x:.4f}"))
    return metrics

if __name__ == "__main__":
    run(save=True)