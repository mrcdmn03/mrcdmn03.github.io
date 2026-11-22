from pathlib import Path
import unittest,sys
import pandas as pd
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/"scripts"))
from analyse import analyse

class Tests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.frame=pd.read_csv(ROOT/"data/homelessness_quarterly_2018_2025.csv")
        cls.result,cls.annual,_,_=analyse(cls.frame)
    def test_count(self):
        self.assertEqual(len(self.frame),29)
    def test_duty_totals(self):
        self.assertTrue(((self.frame.total_duty-self.frame.prevention_duty-
                          self.frame.relief_duty).abs()<200).all())
    def test_pearson(self):
        self.assertAlmostEqual(self.result["prevention_vs_relief"]["pearson_r"],.232,delta=.03)
    def test_trend(self):
        self.assertAlmostEqual(self.result["simple_time_trend"]["slope_per_year"],2633,delta=100)
    def test_annual_mean(self):
        value=self.annual.set_index("year").loc[2018,"mean_total_duty"]
        self.assertAlmostEqual(value,65370,delta=100)
if __name__=="__main__":unittest.main()
