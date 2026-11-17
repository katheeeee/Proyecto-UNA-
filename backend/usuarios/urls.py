from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView

from .views import LoginView, RegistroView

urlpatterns = [
    path('registro/', RegistroView.as_view(), name='registro'),
    path('login/', LoginView.as_view(), name='login'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token-refresh'),
]
