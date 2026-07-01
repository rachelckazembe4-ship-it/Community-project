from django.contrib import admin
from .models import User, Report

@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ['email', 'username', 'role', 'municipality', 'ward', 'created_at']
    search_fields = ['email', 'username', 'municipality', 'ward']
    list_filter = ['role', 'municipality', 'created_at']

@admin.register(Report)
class ReportAdmin(admin.ModelAdmin):
    list_display = ['id', 'reporter', 'service_type', 'municipality', 'ward', 'gender', 'status', 'created_at']
    search_fields = ['ward', 'street', 'description']
    list_filter = ['service_type', 'municipality', 'gender', 'status', 'created_at']
    readonly_fields = ['created_at', 'updated_at']
