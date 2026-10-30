from rest_framework import serializers
from django.contrib.auth.models import User
from .models import HealthProfile, Symptom, Consultation

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'username', 'email', 'password')
        extra_kwargs = {'password': {'write_only': True}}

    def create(self, validated_data):
        user = User.objects.create_user(**validated_data)
        HealthProfile.objects.create(user=user)
        return user

class HealthProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = HealthProfile
        fields = ('age', 'gender', 'chronic_conditions')

class SymptomSerializer(serializers.ModelSerializer):
    class Meta:
        model = Symptom
        fields = '__all__'

class ConsultationSerializer(serializers.ModelSerializer):
    symptoms_names = serializers.StringRelatedField(many=True, read_only=True, source='symptoms')

    class Meta:
        model = Consultation
        fields = ('id', 'date', 'symptoms', 'symptoms_names', 'result_recommendation', 'result_level', 'image_analysis_label', 'image_analysis_confidence')
        read_only_fields = ('result_recommendation', 'result_level')
