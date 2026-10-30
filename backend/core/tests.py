from django.test import TestCase
from .models import Symptom, DecisionRule, SymptomWeight
from .engine import SymptomEngine

class EngineTestCase(TestCase):
    def setUp(self):
        self.s1 = Symptom.objects.create(name="S1")
        self.s2 = Symptom.objects.create(name="S2")

        self.rule = DecisionRule.objects.create(
            name="Test Rule",
            min_weight_score=2.0,
            recommendation="Test Rec",
            level="MEDIUM"
        )
        SymptomWeight.objects.create(rule=self.rule, symptom=self.s1, weight=1.5)
        SymptomWeight.objects.create(rule=self.rule, symptom=self.s2, weight=1.0)

    def test_engine_trigger(self):
        # S1 + S2 = 2.5 > 2.0 -> Doit déclencher
        result = SymptomEngine.evaluate([self.s1.id, self.s2.id])
        self.assertEqual(result['level'], "MEDIUM")

    def test_engine_no_trigger(self):
        # S2 = 1.0 < 2.0 -> Ne doit pas déclencher la règle Test Rule
        result = SymptomEngine.evaluate([self.s2.id])
        self.assertEqual(result['level'], "LOW")
