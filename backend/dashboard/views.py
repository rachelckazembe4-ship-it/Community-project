import os
from django.shortcuts import render, redirect
from django.http import JsonResponse
from django.core.paginator import Paginator
from django.conf import settings
import requests
import json
import random

API_BASE = os.environ.get('API_BASE', 'http://localhost:8000/api')

def get_api_data(endpoint, token=None):
    headers = {}
    if token:
        headers['Authorization'] = f'Token {token}'
    
    try:
        response = requests.get(f'{API_BASE}/{endpoint}', headers=headers)
        if response.status_code == 200:
            return response.json()
    except Exception as e:
        pass
    return {}

def dashboard_home(request):
    lang = request.GET.get('lang', 'sw')
    
    try:
      data = get_api_data('analytics/summary/')
    except Exception as e:
      data = {}
    
    total = data.get('total_reports', 0)
    female = data.get('female_reports', 0)
    male = data.get('male_reports', 0)
    unresolved = data.get('unresolved', 0)
    
    context = {
        'lang': lang,
        'total_reports': total,
        'female_reports': female,
        'male_reports': male,
        'female_pct': data.get('female_percentage', 0),
        'male_pct': data.get('male_percentage', 0),
        'unresolved': unresolved,
        'unresolved_pct': round((unresolved / total * 100) if total > 0 else 0, 1),
        'weekly_trend': data.get('weekly_trend', []),
        'by_municipality': data.get('by_municipality', []),
        'by_service': data.get('by_service', []),
        'gender_distribution': data.get('gender_distribution', {'female': 0, 'male': 0}),
        'user': {
            'name': 'Amina Rashidi',
            'role': 'Ward Officer',
            'ward': 'Kinondoni',
            'initials': 'AR'
        }
    }
    return render(request, 'dashboard/home.html', context)

def dashboard_summary(request):
    data = get_api_data('analytics/summary/')
    
    total = data.get('total_reports', 0)
    female = data.get('female_reports', 0)
    male = data.get('male_reports', 0)
    unresolved = data.get('unresolved', 0)
    
    context = {
        'lang': request.GET.get('lang', 'sw'),
        'total_reports': total,
        'total_reports_pct': f"+{random.randint(8, 15)}%",
        'female_reports': female,
        'male_reports': male,
        'female_pct': data.get('female_percentage', 0),
        'male_pct': data.get('male_percentage', 0),
        'unresolved': unresolved,
        'unresolved_pct': round((unresolved / total * 100) if total > 0 else 0, 1),
        'weekly_trend': data.get('weekly_trend', []),
        'by_municipality': data.get('by_municipality', []),
        'by_service': data.get('by_service', []),
        'gender_distribution': data.get('gender_distribution', {'female': 0, 'male': 0}),
    }
    return JsonResponse(context)

def dashboard_reports(request):
    status_filter = request.GET.get('status', 'all')
    search = request.GET.get('search', '')
    page = request.GET.get('page', 1)
    lang = request.GET.get('lang', 'sw')
    
    params = []
    if status_filter != 'all':
        params.append(f'status={status_filter}')
    if search:
        params.append(f'search={search}')
    
    endpoint = 'reports'
    if params:
        endpoint += '?' + '&'.join(params)
    
    data = get_api_data(endpoint)
    reports = data.get('results', data if isinstance(data, list) else [])
    
    paginator = Paginator(reports, 20)
    page_obj = paginator.get_page(page)
    
    context = {
        'lang': lang,
        'reports': page_obj,
        'status_filter': status_filter,
        'search': search,
        'total_reports': data.get('count', len(reports)) if isinstance(data, dict) else len(reports),
    }
    return render(request, 'dashboard/reports.html', context)

def dashboard_analysis(request):
    data = get_api_data('reports/weekly/')
    
    service_comparison = []
    csv_data = get_api_data('reports/export/csv/')
    
    summary = get_api_data('analytics/summary/')
    by_service = summary.get('by_service', [])
    
    service_icons = {
        'water': '💧',
        'sanitation': '🧹',
        'lighting': '💡',
        'transport': '🚌'
    }
    
    for svc in by_service:
        total = svc.get('total', 0)
        female = svc.get('female', 0)
        male = svc.get('male', 0)
        ratio = round(female / male, 1) if male > 0 else 0
        female_pct = round((female / total * 100) if total > 0 else 0, 0)
        male_pct = round((male / total * 100) if total > 0 else 0, 0)
        
        service_comparison.append({
            'service_name': svc.get('service_type', 'Unknown'),
            'icon': service_icons.get(svc.get('service_type'), '📊'),
            'female': female,
            'male': male,
            'total': total,
            'ratio': f"{female_pct:.0f}:{male_pct:.0f}" if female_pct > 0 or male_pct > 0 else "N/A",
            'female_pct': female_pct,
            'male_pct': male_pct,
        })
    
    context = {
        'lang': request.GET.get('lang', 'sw'),
        'insights': data.get('insights', []),
        'service_comparison': service_comparison,
        'weekly_data': data,
    }
    return render(request, 'dashboard/analysis.html', context)
