import os
import base64
from groq import Groq
from PIL import Image
import io

class HealthAIService:
    """
    Service de diagnostic médical utilisant Groq LPU.
    Utilise la clé GROQ_API_KEY du fichier .env.
    """

    @staticmethod
    def _get_api_key():
        # On cherche d'abord GROQ_API_KEY, puis GEMINI_API_KEY par sécurité
        return os.getenv("GROQ_API_KEY") or os.getenv("GEMINI_API_KEY")

    @staticmethod
    def analyze_health_case(image_file=None, symptoms_names=None):
        api_key = HealthAIService._get_api_key()
        if not api_key:
            return {"label": "Erreur", "final_text": "Clé API non trouvée dans le fichier .env."}

        try:
            client = Groq(api_key=api_key)
            
            prompt = (
                "Tu es un Expert Clinicien. Analyse les données suivantes et fournis un rapport médical complet. "
                "Structure : LABEL (Nom pathologie), LEVEL (Urgence: LOW, MEDIUM, HIGH), DESCRIPTION, RAPPORT détaillé, STATISTIQUES, CONSEILS."
            )
            
            context = ""
            if symptoms_names:
                context += f"\nSymptômes du patient : {', '.join(symptoms_names)}"

            # Format pour Groq (Llama 3.2 Vision ou Compound)
            # On utilise llama-3.2-11b-vision-preview qui est le plus standard
            model_name = "llama-3.2-11b-vision-preview"

            if image_file:
                image_file.seek(0)
                image_data = image_file.read()
                base64_image = base64.b64encode(image_data).decode('utf-8')
                
                messages = [{
                    "role": "user",
                    "content": [
                        {"type": "text", "text": prompt + context},
                        {
                            "type": "image_url",
                            "image_url": {"url": f"data:image/jpeg;base64,{base64_image}"}
                        }
                    ]
                }]
            else:
                messages = [{"role": "user", "content": prompt + context}]

            completion = client.chat.completions.create(
                messages=messages,
                model=model_name,
                temperature=0.1,
                max_tokens=3000,
            )
            
            return {
                'label': "Analyse Médicale",
                'level': "MEDIUM",
                'final_text': completion.choices[0].message.content
            }
        except Exception as e:
            return {
                'label': "Erreur IA",
                'level': "LOW",
                'final_text': f"Erreur technique Groq : {str(e)}"
            }

    @staticmethod
    def verify_key():
        api_key = HealthAIService._get_api_key()
        if not api_key: return False
        try:
            client = Groq(api_key=api_key)
            client.chat.completions.create(
                messages=[{"role": "user", "content": "ping"}],
                model="llama-3.1-8b-instant",
            )
            return True
        except:
            return False
