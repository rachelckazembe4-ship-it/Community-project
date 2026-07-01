import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'report_wizard.dart';
import '../l10n/app_localizations.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');
    String? name;
    if (userJson != null) {
      try {
        final user = jsonDecode(userJson);
        name = user['username'] ?? user['email'] ?? 'User';
      } catch (e) {
        name = 'User';
      }
    }
    setState(() {
      _userName = name ?? 'User';
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          l10n?.get('my_ward') ?? 'My Ward',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF064e3b)),
        ),
        actions: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF064e3b),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _userName?.split(' ').map((n) => n[0]).join().substring(0, min(2, _userName!.split(' ').map((n) => n[0]).join().length)).toUpperCase() ?? 'U',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              l10n?.get('report_service_issue') ?? 'Report a Service Issue',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF064e3b)),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildServiceCard(
                    context,
                    icon: Icons.water_drop,
                    title: l10n?.get('water') ?? 'Water',
                    color: const Color(0xFF0ea5e9),
                    onTap: () => _openReportWizard('water'),
                  ),
                  _buildServiceCard(
                    context,
                    icon: Icons.cleaning_services,
                    title: l10n?.get('sanitation') ?? 'Sanitation',
                    color: const Color(0xFF64748b),
                    onTap: () => _openReportWizard('sanitation'),
                  ),
                  _buildServiceCard(
                    context,
                    icon: Icons.lightbulb_outline,
                    title: l10n?.get('lighting') ?? 'Lighting',
                    color: const Color(0xFFf59e0b),
                    onTap: () => _openReportWizard('lighting'),
                  ),
                  _buildServiceCard(
                    context,
                    icon: Icons.directions_bus,
                    title: l10n?.get('transport') ?? 'Transport',
                    color: const Color(0xFF10b981),
                    onTap: () => _openReportWizard('transport'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openReportWizard(null),
        backgroundColor: const Color(0xFF064e3b),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, {required IconData icon, required String title, required Color color, required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openReportWizard(String? preSelectedService) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportWizardScreen(preSelectedService: preSelectedService),
      ),
    );
  }
}

int min(int a, int b) => a < b ? a : b;
