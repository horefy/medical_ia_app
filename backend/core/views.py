from rest_framework import generics, status, permissions
from rest_framework.response import Response
from rest_framework.views import APIView
from django.contrib.auth.models import User
from .models import Symptom, Consultation, HealthProfile
from .serializers import UserSerializer, SymptomSerializer, ConsultationSerializer, HealthProfileSerializer
from .vision_service import HealthAIService

class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    permission_classes = (permissions.AllowAny,)
    serializer_class = UserSerializer

class ProfileView(generics.RetrieveUpdateAPIView):
    serializer_class = HealthProfileSerializer
    permission_classes = (permissions.AllowAny,)
    def get_object(self):
        p = HealthProfile.objects.first()
        if not p:
            u, _ = User.objects.get_or_create(username='demo')
            p, _ = HealthProfile.objects.get_or_create(user=u)
        return p

class SymptomListView(generics.ListAPIView):
    queryset = Symptom.objects.all()
    serializer_class = SymptomSerializer
    permission_classes = (permissions.AllowAny,)

class ConsultationView(APIView):
    permission_classes = (permissions.AllowAny,)
    def post(self, request):
        try:
            # Extraction des données
            s_data = request.data.get('symptoms', '')
            ids = []
            if s_data:
                # Version simplifiée pour éviter les erreurs d'IDE
                try:
                    for val in s_data.split(','):
                        if val.strip(): ids.append(int(val))
                except:
                    for val in s_data: ids.append(int(val))
            
            img = request.FILES.get('image')
            names = [s.name for s in Symptom.objects.filter(id__in=ids)]
            
            # Appel IA Gemini 1.5
            ai = HealthAIService.analyze_health_case(img, names)
            
            # Sauvegarde
            usr = User.objects.first() or User.objects.create_user(username='demo', password='123')
            c = Consultation.objects.create(
                user=usr,
                result_recommendation=ai.get('final_text', 'Erreur IA'),
                result_level=ai.get('level', 'MEDIUM'),
                image=img,
                image_analysis_label=ai.get('label', 'Analyse'),
                image_analysis_confidence=0.99
            )
            if ids: c.symptoms.set(ids)
            return Response(ConsultationSerializer(c).data, status=status.HTTP_201_CREATED)
        except Exception:
            return Response({"error": "Erreur lors du traitement"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

class HistoryView(generics.ListAPIView):
    queryset = Consultation.objects.all().order_by('-date')
    serializer_class = ConsultationSerializer
    permission_classes = (permissions.AllowAny,)

class SystemStatusView(APIView):
    permission_classes = (permissions.AllowAny,)
    def get(self, request):
        return Response({
            "status": "online",
            "api_ok": HealthAIService.verify_key()
        })
