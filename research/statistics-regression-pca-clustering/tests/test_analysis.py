import unittest,sys
from pathlib import Path
from tempfile import TemporaryDirectory
import numpy as np
import pandas as pd
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/"scripts"))
from generate_demo import generate
from analyse import regression,wellbeing_pca,segment,WELLBEING,MOTIVATIONS

class Tests(unittest.TestCase):
    def test_generated_data(self):
        with TemporaryDirectory() as t:
            generate(t)
            self.assertEqual(len(pd.read_csv(Path(t)/"TaskA_CarPurchase.csv")),100)
            self.assertEqual(len(pd.read_csv(Path(t)/"TaskB_Wellbeing.csv")),120)
            self.assertEqual(len(pd.read_csv(Path(t)/"TaskC_GymMotivation.csv")),100)
    def test_regression(self):
        rng=np.random.default_rng(1);n=80
        d=pd.DataFrame({"Age":rng.integers(20,70,n),"Salary":rng.uniform(20000,80000,n),
          "Maintenance":rng.uniform(500,2000,n),"Comfort":rng.uniform(10,100,n),
          "Advertised":rng.uniform(0,100,n)})
        d["CarValue"]=5+.2*d["Comfort"]+.3*d["Advertised"]+rng.normal(0,1,n)
        self.assertGreater(regression(d)[0]["r_squared"],.9)
    def test_pca(self):
        d=pd.DataFrame(np.random.default_rng(1).uniform(0,100,(120,14)),columns=WELLBEING)
        result,_=wellbeing_pca(d)
        self.assertAlmostEqual(sum(result["explained_variance_ratio"]),1,places=5)
    def test_clusters(self):
        d=pd.DataFrame(np.random.default_rng(2).uniform(0,100,(60,4)),columns=MOTIVATIONS)
        self.assertEqual(sum(x["count"] for x in segment(d)["profiles"]),60)
if __name__=="__main__":unittest.main()
