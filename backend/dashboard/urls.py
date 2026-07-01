from django.urls import path
from . import views

urlpatterns = [
    path('', views.dashboard_home, name='dashboard_home'),
    path('api/summary/', views.dashboard_summary, name='dashboard_summary'),
    path('reports/', views.dashboard_reports, name='dashboard_reports'),
    path('analysis/', views.dashboard_analysis, name='dashboard_analysis'),
]
