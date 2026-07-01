from rest_framework import serializers
from .models import User, Report

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'email', 'username', 'first_name', 'last_name', 'role', 'language', 'municipality', 'ward', 'street', 'phone', 'created_at']
        read_only_fields = ['id', 'created_at']

class UserRegistrationSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=6)
    password2 = serializers.CharField(write_only=True, min_length=6)
    
    class Meta:
        model = User
        fields = ['email', 'username', 'first_name', 'last_name', 'password', 'password2', 'role', 'language', 'municipality', 'ward', 'street', 'phone']
    
    def validate(self, data):
        if data['password'] != data['password2']:
            raise serializers.ValidationError("Passwords do not match")
        return data
    
    def create(self, validated_data):
        validated_data.pop('password2')
        password = validated_data.pop('password')
        username = validated_data.get('username', '')
        if username:
            validated_data['username'] = username.replace(' ', '_').replace('-', '_')
        user = User.objects.create_user(**validated_data)
        user.set_password(password)
        user.save()
        return user

class ReportSerializer(serializers.ModelSerializer):
    reporter_name = serializers.CharField(source='reporter.username', read_only=True)
    report_id = serializers.SerializerMethodField()
    
    class Meta:
        model = Report
        fields = ['id', 'report_id', 'reporter', 'reporter_name', 'service_type', 'municipality', 'ward', 'street', 
                  'description', 'gender', 'age_group', 'report_self', 'status', 'latitude', 'longitude', 
                  'created_at', 'updated_at', 'resolved_at']
        read_only_fields = ['id', 'created_at', 'updated_at']
    
    def get_report_id(self, obj):
        return f"RPT-{obj.id:04d}"

class ReportCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Report
        fields = ['service_type', 'municipality', 'ward', 'street', 'description', 'gender', 'age_group', 'report_self', 'latitude', 'longitude']
