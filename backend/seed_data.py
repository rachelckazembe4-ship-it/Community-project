#!/usr/bin/env python
import os
import sys
import django
from datetime import datetime, timedelta
import random

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
django.setup()

from django.utils import timezone
from reports.models import User, Report

def create_users():
    officers = [
        {'email': 'amina.rashidi@example.org', 'username': 'amina_rashidi', 'role': 'ward_officer', 'municipality': 'Kinondoni', 'ward': 'Mwananyamala'},
        {'email': 'juma.mohamed@example.org', 'username': 'juma_mohamed', 'role': 'ward_officer', 'municipality': 'Ilala', 'ward': 'Buguruni'},
        {'email': 'fatuma.hassan@example.org', 'username': 'fatuma_hassan', 'role': 'ward_officer', 'municipality': 'Temeke', 'ward': 'Kurasini'},
    ]
    
    for officer in officers:
        if not User.objects.filter(email=officer['email']).exists():
            user = User.objects.create_user(
                email=officer['email'],
                username=officer['username'],
                password='password123',
                role=officer['role'],
                municipality=officer['municipality'],
                ward=officer['ward']
            )
            print(f"Created officer: {officer['username']}")
    
    citizens = []
    female_names = ['Amina', 'Halima', 'Maryam', 'Zainab', 'Khadija', 'Saidia', 'Rehema', 'Sakina', 'Mwanahamisi', 'Zawadi']
    male_names = ['Juma', 'Mohamed', 'Hassan', 'Abubakar', 'Omar', 'Rashid', 'Kwame', 'Daniel', 'Emmanuel', 'Joseph']
    streets = ['Mwinjuma Road', 'Samora Avenue', 'Morogoro Road', 'Uhuru Street', 'Mtaa Road', 'Barack Obama Drive', 'Nyerere Road', 'Kitunda Road', 'Kariakoo Street', 'Buguruni Road']
    
    for muni, wards in Report.WARDS.items():
        for ward in wards[:3]:
            for i in range(10):
                gender = random.choice(['female', 'male'])
                if gender == 'female':
                    name = random.choice(female_names)
                else:
                    name = random.choice(male_names)
                
                suffix = random.randint(10000, 99999)
                email = f"{name.lower()}.{suffix}@example.com"
                username = f"{name.lower()}_{suffix}"
                
                if not User.objects.filter(email=email).exists():
                    user = User.objects.create_user(
                        email=email,
                        username=username,
                        password='password123',
                        role='citizen',
                        municipality=muni,
                        ward=ward,
                        street=random.choice(streets)
                    )
                    citizens.append(user)
    
    print(f"Created {len(citizens)} citizen users")

def create_reports():
    if Report.objects.count() > 0:
        print(f"Database already has {Report.objects.count()} reports")
        return
    
    services = ['water', 'sanitation', 'lighting', 'transport']
    statuses = ['pending', 'submitted', 'resolved']
    descriptions = {
        'water': ['No water supply for 3 days', 'Broken water pipe on main road', 'Water quality is poor', 'Frequent water rationing', 'Water pressure too low'],
        'sanitation': ['Garbage not collected for 2 weeks', 'Blocked drainage system', 'Overflowing public toilet', 'No waste bins in the area', 'Uncollected debris on street'],
        'lighting': ['Street light not working for weeks', 'Dark street causing safety concerns', 'Multiple lights broken in area', 'Insufficient street lighting', 'Lights out since last storm'],
        'transport': ['Bus stop needs shelter', 'No public transport service', 'Poor road condition for vehicles', 'Missing pedestrian crossing', 'Bus route not accessible'],
    }
    
    users = User.objects.filter(role='citizen')
    if not users.exists():
        print("No citizen users found")
        return
    
    for i in range(50):
        user = random.choice(users)
        service = random.choice(services)
        report = Report.objects.create(
            reporter=user,
            service_type=service,
            municipality=user.municipality,
            ward=user.ward,
            street=user.street,
            description=random.choice(descriptions[service]),
            gender=random.choice(['female', 'male']),
            age_group=random.choice(['under18', '18_35', '36_60', 'over60']),
            report_self=random.choice([True, False]),
            status=random.choice(statuses),
            created_at=timezone.now() - timedelta(days=random.randint(0, 60))
        )
    
    print(f"Created 50 sample reports")

if __name__ == '__main__':
    print("Seeding database...")
    create_users()
    create_reports()
    print("Done!")
    
    total_users = User.objects.count()
    total_reports = Report.objects.count()
    print(f"Total users: {total_users}")
    print(f"Total reports: {total_reports}")
