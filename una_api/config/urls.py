from django.urls import include, path

urlpatterns = [
    path("api/", include("servicios.urls")),
    path("api/", include("avisos.urls")),
]
