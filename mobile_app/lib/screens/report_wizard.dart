import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../l10n/app_localizations.dart';

class ReportWizardScreen extends StatefulWidget {
  final String? preSelectedService;
  const ReportWizardScreen({super.key, this.preSelectedService});

  @override
  State<ReportWizardScreen> createState() => _ReportWizardScreenState();
}

enum WizardStep { one, two, three }

class _ReportWizardScreenState extends State<ReportWizardScreen> {
  final _formKey = GlobalKey<FormState>();
  ApiService _api = ApiService();

  WizardStep _step = WizardStep.one;
  bool _submitting = false;

  // Step 1
  String? _serviceType;
  String _municipality = 'Kinondoni';
  String? _ward;
  String _street = '';

  // Step 2
  bool _reportSelf = true;
  String? _gender;
  String? _ageGroup;

  List<dynamic> _wards = [];

  final Map<String, List<String>> _localWards = {
    'Kinondoni': ['Bunju', 'Hananasif', 'Kawe', 'Kigogo', 'Kijitonyama', 'Kinondoni', 'Kunduchi', 'Mabwepande', 'Magomeni', 'Makongo', 'Makumbusho', 'Mbezi Juu', 'Mbweni', 'Mikocheni', 'Msasani', 'Mwananyamala', 'Mizimuni', 'Ndugumbi', 'Tandale', 'Wazo'],
    'Temeke': ['Azimio', 'Buza', 'Chamanzi', "Chang'ombe", 'Charambe', 'Keko', 'Kibondemaji', 'Kiburugwa', 'Kijichi', 'Kilakala', 'Kilungule', 'Kurasini', 'Makangarawe', 'Mbagala', 'Mbagala Kuu', 'Mianzini', 'Miburani', 'Mtoni', 'Sandali', 'Tandika', 'Temeke', 'Toangoma', 'Yombovituka'],
    'Ilala': ['Bonyokwa', 'Buguruni', 'Buyuni', 'Chanika', 'Gerezani', 'Gongolamboto', 'Ilala', 'Jangwani', 'Kariakoo', 'Kimanga', 'Kinyerezi', 'Kipawa', 'Kipunguni', 'Kisukuru', 'Kisutu', 'Kitunda', 'Kivukoni', 'Kivule', 'Kiwalani', 'Liwiti', 'Majohe', 'Mchafukoge', 'Mchikichini', 'Minazi Mirefu', 'Mnyamani', 'Msongola', 'Mzinga', 'Pugu', 'Pugu Station', 'Segerea', 'Tabata', 'Ukonga', 'Upanga Magharibi', 'Upanga Mashariki', 'Vingunguti', 'Zingiziwa'],
    'Kigamboni': ['Kibada', 'Kigamboni', 'Kimbiji', 'Kisarawe II', 'Mjimwema', 'Pembamnazi', 'Somangila', 'Tungi', 'Vijibweni'],
    'Ubungo': ['Goba', 'Kibamba', 'Kimara', 'Kwembe', 'Mabibo', 'Makuburi', 'Mkurumla', 'Manzese', 'Mbezi', 'Mburahati', 'Msigani', 'Saranga', 'Sinza', 'Ubungo'],
  };

  @override
  void initState() {
    super.initState();
    if (widget.preSelectedService != null) {
      _serviceType = widget.preSelectedService;
    }
    _wards = _localWards[_municipality]!.map((w) => {'value': w, 'label': w}).toList();
    _ward = _wards.isNotEmpty ? _wards[0]['value'] : null;
    _loadWards(_municipality);
  }

  Future<void> _loadWards(String muni) async {
    try {
      final apiWards = await _api.getWards(muni).timeout(const Duration(seconds: 5));
      if (mounted) {
        setState(() {
          _wards = apiWards;
          _ward = apiWards.isNotEmpty ? apiWards[0]['value'] : null;
        });
      }
    } catch (e) {
      // keep local data
    }
  }

  void _nextStep() {
    final l10n = AppLocalizations.of(context);
    if (_step == WizardStep.one) {
      if (_serviceType == null || _municipality.isEmpty || (_ward == null || _ward!.isEmpty) || _street.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n?.get('required') ?? 'Please fill all fields')));
        return;
      }
      setState(() => _step = WizardStep.two);
    } else if (_step == WizardStep.two) {
      if (_gender == null || _ageGroup == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n?.get('required') ?? 'Please select gender and age group')));
        return;
      }
      setState(() => _step = WizardStep.three);
    }
  }

  void _prevStep() {
    if (_step == WizardStep.two) {
      setState(() => _step = WizardStep.one);
    } else if (_step == WizardStep.three) {
      setState(() => _step = WizardStep.two);
    }
  }

  Future<void> _submitReport() async {
    setState(() => _submitting = true);
    try {
      await _api.createReport({
        'service_type': _serviceType!,
        'municipality': _municipality,
        'ward': _ward!,
        'street': _street,
        'description': 'Community report',
        'gender': _gender!,
        'age_group': _ageGroup!,
        'report_self': _reportSelf,
      });
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)?.get('report_submitted') ?? 'Report submitted successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString().replaceAll("Exception: ", "")}')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.get('new_report') ?? 'New Report'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF064e3b),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF064e3b)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: _step == WizardStep.one ? 1/3 : _step == WizardStep.two ? 2/3 : 1,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF064e3b)),
            minHeight: 4,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: _buildStep(),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(color: Colors.grey[200]!, blurRadius: 8, offset: const Offset(0, -2))
            ]),
            child: Row(
              children: [
                if (_step != WizardStep.one)
                  TextButton(onPressed: _prevStep, child: Text(l10n?.get('back') ?? 'Back'))
                else
                  const Spacer(),
                ElevatedButton(
                  onPressed: _step == WizardStep.three ? (_submitting ? null : _submitReport) : _nextStep,
                  style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll<Color>(Color(0xFF064e3b)),
                    foregroundColor: WidgetStatePropertyAll<Color>(Colors.white),
                    padding: WidgetStatePropertyAll<EdgeInsets>(EdgeInsets.symmetric(horizontal: 32, vertical: 14)),
                    shape: WidgetStatePropertyAll<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8)))),
                  ),
                  child: _submitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(_step == WizardStep.three ? (l10n?.get('submit') ?? 'Submit') : (l10n?.get('next') ?? 'Next')),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case WizardStep.one:
        return _StepOne(
          serviceType: _serviceType,
          municipality: _municipality,
          ward: _ward,
          street: _street,
          wards: _wards,
          onServiceChanged: (v) => setState(() => _serviceType = v),
          onMunicipalityChanged: (v) {
            setState(() {
              _municipality = v;
              _ward = null;
            });
            _loadWards(v);
          },
          onWardChanged: (v) => setState(() => _ward = v),
          onStreetChanged: (v) => setState(() => _street = v),
          api: _api,
        );
      case WizardStep.two:
        return _StepTwo(
          reportSelf: _reportSelf,
          gender: _gender,
          ageGroup: _ageGroup,
          onReportSelfChanged: (v) => setState(() => _reportSelf = v),
          onGenderChanged: (v) => setState(() => _gender = v),
          onAgeGroupChanged: (v) => setState(() => _ageGroup = v),
        );
      case WizardStep.three:
        return _StepThree(
          serviceType: _serviceType!,
          municipality: _municipality,
          ward: _ward!,
          street: _street,
          gender: _gender!,
          ageGroup: _ageGroup!,
          reportSelf: _reportSelf,
        );
    }
  }
}

class _StepOne extends StatelessWidget {
  final String? serviceType;
  final String municipality;
  final String? ward;
  final String street;
  final List<dynamic> wards;
  final Function(String?) onServiceChanged;
  final Function(String) onMunicipalityChanged;
  final Function(String?) onWardChanged;
  final Function(String) onStreetChanged;
  final ApiService api;

  const _StepOne({
    required this.serviceType,
    required this.municipality,
    required this.ward,
    required this.street,
    required this.wards,
    required this.onServiceChanged,
    required this.onMunicipalityChanged,
    required this.onWardChanged,
    required this.onStreetChanged,
    required this.api,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${l10n?.get('step') ?? 'Step'} 1', style: TextStyle(color: const Color(0xFF064e3b), fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          key: const ValueKey('service_type'),
          initialValue: serviceType,
          decoration: InputDecoration(
            labelText: l10n?.get('service_type') ?? 'Service Type',
            border: const OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'water', child: Text('Water')),
            DropdownMenuItem(value: 'sanitation', child: Text('Sanitation')),
            DropdownMenuItem(value: 'lighting', child: Text('Lighting')),
            DropdownMenuItem(value: 'transport', child: Text('Transport')),
          ],
          onChanged: onServiceChanged,
          validator: (v) => v == null ? (l10n?.get('required') ?? 'Required') : null,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          key: ValueKey('municipality_$municipality'),
          initialValue: municipality,
          decoration: InputDecoration(
            labelText: l10n?.get('municipality') ?? 'Municipality',
            border: const OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'Kinondoni', child: Text('Kinondoni')),
            DropdownMenuItem(value: 'Ilala', child: Text('Ilala')),
            DropdownMenuItem(value: 'Temeke', child: Text('Temeke')),
            DropdownMenuItem(value: 'Ubungo', child: Text('Ubungo')),
            DropdownMenuItem(value: 'Kigamboni', child: Text('Kigamboni')),
          ],
          onChanged: (v) => onMunicipalityChanged(v!),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          key: ValueKey('ward_$municipality$ward'),
          initialValue: ward,
          decoration: InputDecoration(
            labelText: l10n?.get('ward') ?? 'Ward',
            border: const OutlineInputBorder(),
          ),
          items: wards.isEmpty
              ? [const DropdownMenuItem(value: '', child: Text('Loading...'))]
              : wards.map<DropdownMenuItem<String>>((w) {
                  return DropdownMenuItem<String>(value: w['value'] as String, child: Text(w['label']));
                }).toList(),
          onChanged: wards.isEmpty ? null : onWardChanged,
          validator: (v) => v == null ? (l10n?.get('required') ?? 'Required') : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: street,
          decoration: InputDecoration(
            labelText: l10n?.get('street') ?? 'Street / Location',
            border: const OutlineInputBorder(),
          ),
          onChanged: onStreetChanged,
          validator: (v) => v == null || v.isEmpty ? (l10n?.get('required') ?? 'Required') : null,
        ),
      ],
    );
  }
}

class _StepTwo extends StatelessWidget {
  final bool reportSelf;
  final String? gender;
  final String? ageGroup;
  final Function(bool) onReportSelfChanged;
  final Function(String?) onGenderChanged;
  final Function(String?) onAgeGroupChanged;

  const _StepTwo({
    required this.reportSelf,
    required this.gender,
    required this.ageGroup,
    required this.onReportSelfChanged,
    required this.onGenderChanged,
    required this.onAgeGroupChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${l10n?.get('step') ?? 'Step'} 2', style: TextStyle(color: const Color(0xFF064e3b), fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SwitchListTile(
          title: Text(l10n?.get('report_self') ?? 'Report on behalf of yourself'),
          value: reportSelf,
          onChanged: onReportSelfChanged,
          activeThumbColor: const Color(0xFF064e3b),
        ),
        DropdownButtonFormField<String>(
          initialValue: gender,
          decoration: InputDecoration(
            labelText: l10n?.get('gender') ?? 'Gender',
            border: const OutlineInputBorder(),
          ),
          items: [
            DropdownMenuItem(value: 'female', child: Text(l10n?.get('female') ?? 'Female')),
            DropdownMenuItem(value: 'male', child: Text(l10n?.get('male') ?? 'Male')),
            DropdownMenuItem(value: 'other', child: Text('Other')),
          ],
          onChanged: onGenderChanged,
          validator: (v) => v == null ? (l10n?.get('required') ?? 'Required') : null,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: ageGroup,
          decoration: InputDecoration(
            labelText: l10n?.get('age_group') ?? 'Age Group',
            border: const OutlineInputBorder(),
          ),
          items: [
            DropdownMenuItem(value: 'under18', child: Text(l10n?.get('under_18') ?? 'Under 18')),
            DropdownMenuItem(value: '18_35', child: Text(l10n?.get('age_18_35') ?? '18-35')),
            DropdownMenuItem(value: '36_60', child: Text(l10n?.get('age_36_60') ?? '36-60')),
            DropdownMenuItem(value: 'over60', child: Text(l10n?.get('age_over_60') ?? 'Over 60')),
          ],
          onChanged: onAgeGroupChanged,
          validator: (v) => v == null ? (l10n?.get('required') ?? 'Required') : null,
        ),
      ],
    );
  }
}

class _StepThree extends StatelessWidget {
  final String serviceType;
  final String municipality;
  final String ward;
  final String street;
  final String gender;
  final String ageGroup;
  final bool reportSelf;

  const _StepThree({
    required this.serviceType,
    required this.municipality,
    required this.ward,
    required this.street,
    required this.gender,
    required this.ageGroup,
    required this.reportSelf,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n?.get('review_title') ?? 'Review & Submit', style: TextStyle(color: const Color(0xFF064e3b), fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        _buildRow(l10n?.get('service_type') ?? 'Service Type', serviceType),
        _buildRow(l10n?.get('municipality') ?? 'Municipality', municipality),
        _buildRow(l10n?.get('ward') ?? 'Ward', ward),
        _buildRow(l10n?.get('street') ?? 'Street / Location', street),
        _buildRow(l10n?.get('gender') ?? 'Gender', gender),
        _buildRow(l10n?.get('age_group') ?? 'Age Group', ageGroup),
        _buildRow(l10n?.get('report_self') ?? 'Report for Self', reportSelf ? 'Yes' : 'No'),
      ],
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
          Text(value, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }
}
