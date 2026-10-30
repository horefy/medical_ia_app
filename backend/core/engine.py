from .models import DecisionRule, SymptomWeight

class SymptomEngine:
    """
    Moteur de règles basé sur des poids.
    Prend une liste d'IDs de symptômes et retourne la meilleure recommandation.
    """

    @staticmethod
    def evaluate(symptom_ids):
        rules = DecisionRule.objects.prefetch_related('weights', 'symptoms').all()
        best_rule = None
        highest_score = -1

        for rule in rules:
            score = 0
            # On calcule le score pour cette règle en fonction des symptômes présents
            relevant_weights = rule.weights.filter(symptom_id__in=symptom_ids)
            for sw in relevant_weights:
                score += sw.weight

            # Si le score dépasse le seuil et est le meilleur trouvé jusqu'ici
            if score >= rule.min_weight_score and score > highest_score:
                highest_score = score
                best_rule = rule

        if best_rule:
            return {
                'recommendation': best_rule.recommendation,
                'level': best_rule.level,
                'score': highest_score
            }

        return {
            'recommendation': "Aucune condition spécifique détectée. Si les symptômes persistent, consultez un médecin.",
            'level': 'LOW',
            'score': 0
        }
