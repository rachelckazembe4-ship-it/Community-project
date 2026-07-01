from django.http import HttpResponse
from rest_framework import generics, status, viewsets
from rest_framework.decorators import action, api_view, permission_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.authtoken.models import Token
from django.contrib.auth import authenticate
from django.db.models import Count, Q
from django.utils import timezone
from datetime import datetime, timedelta
from rest_framework.views import APIView

from .models import User, Report
from .serializers import UserSerializer, UserRegistrationSerializer, ReportSerializer, ReportCreateSerializer

@api_view(['POST'])
@permission_classes([AllowAny])
def login_view(request):
    email = request.data.get('email')
    password = request.data.get('password')
    user = authenticate(request, email=email, password=password)
    if user:
        token, _ = Token.objects.get_or_create(user=user)
        return Response({
            'token': token.key,
            'user': UserSerializer(user).data
        })
    return Response({'error': 'Invalid credentials'}, status=status.HTTP_401_UNAUTHORIZED)

@api_view(['POST'])
@permission_classes([AllowAny])
def register_view(request):
    serializer = UserRegistrationSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.save()
        token, _ = Token.objects.get_or_create(user=user)
        return Response({
            'token': token.key,
            'user': UserSerializer(user).data
        }, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def current_user(request):
    serializer = UserSerializer(request.user)
    return Response(serializer.data)

@api_view(['GET'])
@permission_classes([AllowAny])
def municipalities_list(request):
    municipalities = [{'value': m[0], 'label': m[1]} for m in Report.MUNICIPALITY_CHOICES]
    return Response(municipalities)

@api_view(['GET'])
@permission_classes([AllowAny])
def wards_list(request):
    municipality = request.query_params.get('municipality')
    if not municipality:
        return Response([], status=status.HTTP_400_BAD_REQUEST)
    
    wards = Report.WARDS.get(municipality, [])
    ward_list = [{'value': w, 'label': w} for w in wards]
    return Response(ward_list)

class ReportViewSet(viewsets.ModelViewSet):
    serializer_class = ReportSerializer
    
    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            return [AllowAny()]
        return [IsAuthenticated()]
    
    def get_queryset(self):
        queryset = Report.objects.select_related('reporter').all()
        
        status_filter = self.request.query_params.get('status')
        if status_filter:
            queryset = queryset.filter(status=status_filter)
        
        search = self.request.query_params.get('search')
        if search:
            queryset = queryset.filter(
                Q(description__icontains=search) | 
                Q(reporter__username__icontains=search) |
                Q(ward__icontains=search)
            )
        
        return queryset
    
    def get_serializer_class(self):
        if self.action == 'create':
            return ReportCreateSerializer
        return ReportSerializer
    
    def perform_create(self, serializer):
        serializer.save(reporter=self.request.user)

class AnalyticsSummary(APIView):
    permission_classes = [AllowAny]
    
    def get(self, request):
        total_reports = Report.objects.count()
        female_reports = Report.objects.filter(gender='female').count()
        male_reports = Report.objects.filter(gender='male').count()
        unresolved = Report.objects.filter(status__in=['pending', 'submitted']).count()
        
        weekly_reports = []
        for i in range(8):
            week_start = timezone.now() - timedelta(weeks=8-i)
            week_end = week_start + timedelta(weeks=1)
            count = Report.objects.filter(created_at__range=[week_start, week_end]).count()
            weekly_reports.append({
                'week': f'W{i+1}',
                'total': count,
                'female': Report.objects.filter(created_at__range=[week_start, week_end], gender='female').count(),
                'male': Report.objects.filter(created_at__range=[week_start, week_end], gender='male').count(),
            })
        
        by_municipality = Report.objects.values('municipality').annotate(
            total=Count('id'),
            female=Count('id', filter=Q(gender='female')),
            male=Count('id', filter=Q(gender='male'))
        ).order_by('-total')
        
        by_service = Report.objects.values('service_type').annotate(
            total=Count('id'),
            female=Count('id', filter=Q(gender='female')),
            male=Count('id', filter=Q(gender='male'))
        ).order_by('-total')
        
        return Response({
            'total_reports': total_reports,
            'female_reports': female_reports,
            'male_reports': male_reports,
            'female_percentage': round((female_reports / total_reports * 100) if total_reports > 0 else 0, 1),
            'male_percentage': round((male_reports / total_reports * 100) if total_reports > 0 else 0, 1),
            'unresolved': unresolved,
            'unresolved_percentage': round((unresolved / total_reports * 100) if total_reports > 0 else 0, 1),
            'weekly_trend': weekly_reports,
            'by_municipality': list(by_municipality),
            'by_service': list(by_service),
            'gender_distribution': {
                'female': female_reports,
                'male': male_reports,
            }
        })

class WeeklyReportView(APIView):
    permission_classes = [AllowAny]
    
    def get(self, request):
        now = timezone.now()
        week_start = now - timedelta(days=now.weekday())
        
        weekly_reports = Report.objects.filter(created_at__gte=week_start)
        
        insights = []
        
        if weekly_reports.count() > 0:
            lighting_female = weekly_reports.filter(service_type='lighting', gender='female').count()
            lighting_male = weekly_reports.filter(service_type='lighting', gender='male').count()
            if lighting_female > 0 and lighting_male > 0:
                ratio = round(lighting_female / lighting_male, 1)
                insights.append({
                    'type': 'lighting_gap',
                    'color': 'green',
                    'template_key': 'lighting_gap',
                    'text_en': f"Women report {ratio}x more lighting issues than men.",
                    'text_sw': f"Wanawake wanaripoti matatizo ya taa mara {ratio}x zaidi ya wanaume."
                })
            
            water_reports = weekly_reports.filter(service_type='water').count()
            prev_week = week_start - timedelta(weeks=1)
            prev_water = Report.objects.filter(service_type='water', created_at__range=[prev_week, week_start]).count()
            if prev_water > 0:
                spike = round((water_reports - prev_water) / prev_water * 100)
                if spike > 0:
                    insights.append({
                        'type': 'water_spike',
                        'color': 'amber',
                        'template_key': 'water_spike',
                        'text_en': f"Water reports have spiked {spike}% compared to last week.",
                        'text_sw': f"Kuna ongezeko la {spike}% la ripoti za maji ikilinganisha na wiki iliyopita."
                    })
            
            sanitation_female = weekly_reports.filter(service_type='sanitation', gender='female').count()
            sanitation_total = weekly_reports.filter(service_type='sanitation').count()
            if sanitation_total > 0:
                pct = round(sanitation_female / sanitation_total * 100)
                insights.append({
                    'type': 'sanitation_women',
                    'color': 'teal',
                    'template_key': 'sanitation_women',
                    'text_en': f"{pct}% of sanitation reports come from women.",
                    'text_sw': f"{pct}% ya ripoti za usafi zinatoka kwa wanawake."
                })
            
            transport_total = weekly_reports.filter(service_type='transport').count()
            if transport_total > 5:
                transport_female = weekly_reports.filter(service_type='transport', gender='female').count()
                transport_male = weekly_reports.filter(service_type='transport', gender='male').count()
                ratio = round(transport_female / transport_male, 1) if transport_male > 0 else 1.0
                insights.append({
                    'type': 'transport_balance',
                    'color': 'purple',
                    'template_key': 'transport_balance',
                    'text_en': f"Transport reports are the most gender-balanced ({ratio}:1 F:M).",
                    'text_sw': f"Ripoti za usafiri zina mgawanyo sawa zaidi ({ratio}:1 F:M)."
                })
        
        return Response({
            'week_starting': week_start.strftime('%Y-%m-%d'),
            'total_reports': weekly_reports.count(),
            'insights': insights,
            'generated_at': now.strftime('%Y-%m-%d %H:%M')
        })

class ReportsCSVView(APIView):
    permission_classes = [AllowAny]
    
    def get(self, request):
        response = HttpResponse(content_type='text/csv')
        response['Content-Disposition'] = 'attachment; filename="reports.csv"'
        
        writer = csv.writer(response)
        writer.writerow([
            'Report ID', 'Service Type', 'Municipality', 'Ward', 'Street', 
            'Description', 'Gender', 'Age Group', 'Status', 'Date'
        ])
        
        reports = Report.objects.select_related('reporter').all()
        if request.query_params.get('status'):
            reports = reports.filter(status=request.query_params.get('status'))
        
        for report in reports:
            writer.writerow([
                f"RPT-{report.id:04d}",
                report.get_service_type_display(),
                report.municipality,
                report.ward,
                report.street,
                report.description,
                report.get_gender_display(),
                report.get_age_group_display(),
                report.get_status_display(),
                report.created_at.strftime('%Y-%m-%d')
            ])
        
        return response
