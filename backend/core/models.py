from django.db import models
from django.contrib.auth.models import User

class HealthProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    age = models.IntegerField(null=True, blank=True)
    gender = models.CharField(max_length=10, choices=[('M', 'Masculin'), ('F', 'Féminin'), ('O', 'Autre')], null=True, blank=True)
    chronic_conditions = models.TextField(blank=True, help_text="Conditions chroniques séparées par des virgules")

    def __str__(self):
        return f"Profil de {self.user.username}"

class Symptom(models.Model):
    name = models.CharField(max_length=100, unique=True)
    description = models.TextField(blank=True)

    def __str__(self):
        return self.name

class DecisionRule(models.Model):
    RECOMMENDATION_LEVELS = [
        ('LOW', 'Repos et observation'),
        ('MEDIUM', 'Consulter un médecin généraliste'),
        ('HIGH', 'Urgences / Appel 15'),
    ]

    name = models.CharField(max_length=100)
    symptoms = models.ManyToManyField(Symptom, related_name='rules')
    min_weight_score = models.FloatField(default=1.0, help_text="Score minimum requis pour déclencher cette règle")
    recommendation = models.TextField()
    level = models.CharField(max_length=10, choices=RECOMMENDATION_LEVELS, default='LOW')

    def __str__(self):
        return f"{self.name} ({self.level})"

class SymptomWeight(models.Model):
    """Permet de définir un poids spécifique pour un symptôme au sein d'une règle."""
    rule = models.ForeignKey(DecisionRule, on_delete=models.CASCADE, related_name='weights')
    symptom = models.ForeignKey(Symptom, on_delete=models.CASCADE)
    weight = models.FloatField(default=1.0)

    class Meta:
        unique_together = ('rule', 'symptom')

class Consultation(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='consultations')
    date = models.DateTimeField(auto_now_add=True)
    symptoms = models.ManyToManyField(Symptom)
    result_recommendation = models.TextField()
    result_level = models.CharField(max_length=10)

    # Pour le volet caméra
    image = models.ImageField(upload_to='consultations/', null=True, blank=True)
    image_analysis_label = models.CharField(max_length=100, blank=True, null=True)
    image_analysis_confidence = models.FloatField(blank=True, null=True)

    def __str__(self):
        return f"Consultation {self.id} - {self.user.username} - {self.date.strftime('%d/%m/%Y')}"
