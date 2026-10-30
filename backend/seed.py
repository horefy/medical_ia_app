import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'medical_backend.settings')
django.setup()

from core.models import Symptom, DecisionRule, SymptomWeight

def seed():
    print("Initialisation des données de base...")

    # Symptômes
    fievre, _ = Symptom.objects.get_or_create(name="Fièvre", description="Température corporelle > 38°C")
    toux, _ = Symptom.objects.get_or_create(name="Toux", description="Toux sèche ou grasse")
    fatigue, _ = Symptom.objects.get_or_create(name="Fatigue", description="Sensation de fatigue intense")
    diff_respi, _ = Symptom.objects.get_or_create(name="Difficulté respiratoire", description="Essoufflement au repos ou à l'effort")
    douleur_poitrine, _ = Symptom.objects.get_or_create(name="Douleur thoracique", description="Douleur ou pression dans la poitrine")

    # Règle 1 : Grippe / Rhume (LOW)
    r1, _ = DecisionRule.objects.get_or_create(
        name="Syndrome grippal léger",
        min_weight_score=2.0,
        recommendation="Il semble que vous ayez un état grippal. Reposez-vous, hydratez-vous et surveillez votre température.",
        level='LOW'
    )
    SymptomWeight.objects.get_or_create(rule=r1, symptom=fievre, weight=1.0)
    SymptomWeight.objects.get_or_create(rule=r1, symptom=toux, weight=1.0)
    SymptomWeight.objects.get_or_create(rule=r1, symptom=fatigue, weight=0.5)

    # Règle 2 : Problème respiratoire (HIGH)
    r2, _ = DecisionRule.objects.get_or_create(
        name="Urgence Respiratoire",
        min_weight_score=1.0,
        recommendation="ATTENTION : Vos symptômes respiratoires sont inquiétants. Contactez immédiatement les urgences (15).",
        level='HIGH'
    )
    SymptomWeight.objects.get_or_create(rule=r2, symptom=diff_respi, weight=1.0)
    SymptomWeight.objects.get_or_create(rule=r2, symptom=douleur_poitrine, weight=2.0)

    print("Terminé !")

if __name__ == '__main__':
    seed()
