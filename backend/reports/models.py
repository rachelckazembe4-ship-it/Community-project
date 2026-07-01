from django.db import models
from django.contrib.auth.models import AbstractUser

class User(AbstractUser):
    ROLE_CHOICES = [
        ('citizen', 'Citizen'),
        ('ward_officer', 'Ward Officer'),
        ('admin', 'Admin'),
    ]
    LANG_CHOICES = [
        ('sw', 'Kiswahili'),
        ('en', 'English'),
    ]
    
    email = models.EmailField(unique=True)
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='citizen')
    language = models.CharField(max_length=2, choices=LANG_CHOICES, default='sw')
    municipality = models.CharField(max_length=100, blank=True, null=True)
    ward = models.CharField(max_length=100, blank=True, null=True)
    street = models.CharField(max_length=200, blank=True, null=True)
    phone = models.CharField(max_length=20, blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['username']

    class Meta:
        db_table = 'users'

class Report(models.Model):
    SERVICE_CHOICES = [
        ('water', 'Water'),
        ('sanitation', 'Sanitation'),
        ('lighting', 'Lighting'),
        ('transport', 'Transport'),
    ]
    
    GENDER_CHOICES = [
        ('female', 'Female'),
        ('male', 'Male'),
        ('other', 'Other'),
    ]
    
    AGE_CHOICES = [
        ('under18', 'Under 18'),
        ('18_35', '18-35'),
        ('36_60', '36-60'),
        ('over60', 'Over 60'),
    ]
    
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('submitted', 'Submitted'),
        ('resolved', 'Resolved'),
    ]
    
    MUNICIPALITY_CHOICES = [
        ('Kinondoni', 'Kinondoni'),
        ('Ilala', 'Ilala'),
        ('Temeke', 'Temeke'),
        ('Ubungo', 'Ubungo'),
        ('Kigamboni', 'Kigamboni'),
    ]
    
    WARDS = {
        'Kinondoni': ['Bunju', 'Hananasif', 'Kawe', 'Kigogo', 'Kijitonyama', 'Kinondoni', 'Kunduchi', 'Mabwepande', 'Magomeni', 'Makongo', 'Makumbusho', 'Mbezi Juu', 'Mbweni', 'Mikocheni', 'Msasani', 'Mwananyamala', 'Mizimuni', 'Ndugumbi', 'Tandale', 'Wazo'],
        'Temeke': ['Azimio', 'Buza', 'Chamanzi', "Chang'ombe", 'Charambe', 'Keko', 'Kibondemaji', 'Kiburugwa', 'Kijichi', 'Kilakala', 'Kilungule', 'Kurasini', 'Makangarawe', 'Mbagala', 'Mbagala Kuu', 'Mianzini', 'Miburani', 'Mtoni', 'Sandali', 'Tandika', 'Temeke', 'Toangoma', 'Yombovituka'],
        'Ilala': ['Bonyokwa', 'Buguruni', 'Buyuni', 'Chanika', 'Gerezani', 'Gongolamboto', 'Ilala', 'Jangwani', 'Kariakoo', 'Kimanga', 'Kinyerezi', 'Kipawa', 'Kipunguni', 'Kisukuru', 'Kisutu', 'Kitunda', 'Kivukoni', 'Kivule', 'Kiwalani', 'Liwiti', 'Majohe', 'Mchafukoge', 'Mchikichini', 'Minazi Mirefu', 'Mnyamani', 'Msongola', 'Mzinga', 'Pugu', 'Pugu Station', 'Segerea', 'Tabata', 'Ukonga', 'Upanga Magharibi', 'Upanga Mashariki', 'Vingunguti', 'Zingiziwa'],
        'Kigamboni': ['Kibada', 'Kigamboni', 'Kimbiji', 'Kisarawe II', 'Mjimwema', 'Pembamnazi', 'Somangila', 'Tungi', 'Vijibweni'],
        'Ubungo': ['Goba', 'Kibamba', 'Kimara', 'Kwembe', 'Mabibo', 'Makuburi', 'Mkurumla', 'Manzese', 'Mbezi', 'Mburahati', 'Msigani', 'Saranga', 'Sinza', 'Ubungo'],
    }
    
    reporter = models.ForeignKey('User', on_delete=models.CASCADE, related_name='reports')
    service_type = models.CharField(max_length=20, choices=SERVICE_CHOICES)
    municipality = models.CharField(max_length=100, choices=MUNICIPALITY_CHOICES)
    ward = models.CharField(max_length=100)
    street = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    gender = models.CharField(max_length=10, choices=GENDER_CHOICES)
    age_group = models.CharField(max_length=20, choices=AGE_CHOICES)
    report_self = models.BooleanField(default=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    latitude = models.FloatField(blank=True, null=True)
    longitude = models.FloatField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    resolved_at = models.DateTimeField(blank=True, null=True)

    class Meta:
        db_table = 'reports'
        ordering = ['-created_at']

    def __str__(self):
        return f"RPT-{self.id:04d} - {self.service_type} - {self.ward}"
