from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from django.http import JsonResponse
from dashboard import views as dashboard_views

def health_check(request):
    return JsonResponse({'status': 'ok', 'message': 'Backend is running'})

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('reports.urls')),
    path('dashboard/', include('dashboard.urls')),
    path('health/', health_check),
]

if settings.DEBUG:
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATICFILES_DIRS[0])
