from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register(r'reports', views.ReportViewSet, basename='report')

urlpatterns = [
    path('auth/login/', views.login_view, name='login'),
    path('auth/register/', views.register_view, name='register'),
    path('auth/user/', views.current_user, name='current_user'),
    path('location/municipalities/', views.municipalities_list, name='municipalities'),
    path('location/wards/', views.wards_list, name='wards'),
    path('', include(router.urls)),
    path('analytics/summary/', views.AnalyticsSummary.as_view(), name='analytics_summary'),
    path('reports/weekly/', views.WeeklyReportView.as_view(), name='weekly_reports'),
    path('reports/export/csv/', views.ReportsCSVView.as_view(), name='reports_csv'),
]
