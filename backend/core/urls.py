from django.urls import path
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from .views import RegisterView, SymptomListView, ConsultationView, HistoryView, ProfileView, SystemStatusView

urlpatterns = [
    # Auth
    path('auth/register/', RegisterView.as_view(), name='auth_register'),
    path('auth/login/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('auth/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('profile/', ProfileView.as_view(), name='profile'),

    # App
    path('symptoms/', SymptomListView.as_view(), name='symptoms_list'),
    path('consult/', ConsultationView.as_view(), name='consult'),
    path('history/', HistoryView.as_view(), name='history'),
    path('status/', SystemStatusView.as_view(), name='system_status'),
]
