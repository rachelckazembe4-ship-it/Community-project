import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import '../l10n/app_localizations.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _municipality = 'Kinondoni';
  String? _ward;
  final _streetController = TextEditingController();
  String? _gender;
  bool _isLoading = false;
  List<dynamic> _wards = [];
  final ApiService _api = ApiService();

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

  String _sanitizeUsername(String name) {
    return name.trim().replaceAll(' ', '_').replaceAll(RegExp(r'[^a-zA-Z0-9@._+-]'), '');
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmPasswordController.text) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)?.get('password_mismatch') ?? 'Passwords do not match')),
        );
      }
      return;
    }
    setState(() => _isLoading = true);
    try {
      final rawName = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';
      final username = _sanitizeUsername(rawName);
      final email = _emailController.text.trim();
      
      await _api.register({
        'email': email,
        'username': username,
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'password': _passwordController.text,
        'password2': _confirmPasswordController.text,
        'role': 'citizen',
        'language': 'en',
        'municipality': _municipality,
        'ward': _ward ?? '',
        'street': _streetController.text.trim(),
        'phone': _phoneController.text.trim(),
      });
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = e.toString().replaceAll("Exception: ", "");
        if (errorMsg.contains("Registration failed")) {
          errorMsg = "Registration failed. Please check your details and try again.";
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.get('register') ?? 'Register'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF064e3b),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF064e3b)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(l10n?.get('register_subtitle') ?? 'Register to start reporting issues in your community.', style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person_outline),
                      hintText: l10n?.get('first_name') ?? 'First Name',
                      labelText: l10n?.get('first_name') ?? 'First Name',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) => v != null && v.isNotEmpty ? null : (l10n?.get('required') ?? 'Required'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person_outline),
                      hintText: l10n?.get('last_name') ?? 'Last Name',
                      labelText: l10n?.get('last_name') ?? 'Last Name',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) => v != null && v.isNotEmpty ? null : (l10n?.get('required') ?? 'Required'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _municipality,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.location_city),
                hintText: l10n?.get('municipality') ?? 'Municipality',
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
              onChanged: (v) {
                if (v != null) {
                  setState(() {
                    _municipality = v;
                    _ward = null;
                  });
                  _loadWards(v);
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _ward,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.location_on),
                hintText: l10n?.get('ward') ?? 'Ward',
                labelText: l10n?.get('ward') ?? 'Ward',
                border: const OutlineInputBorder(),
              ),
              items: _wards.isEmpty
                  ? [const DropdownMenuItem(value: '', child: Text('Loading...'))]
                  : _wards.map<DropdownMenuItem<String>>((w) {
                      return DropdownMenuItem<String>(value: w['value'] as String, child: Text(w['label']));
                    }).toList(),
              onChanged: _wards.isEmpty ? null : (v) => setState(() => _ward = v),
              validator: (v) => v != null && v.isNotEmpty ? null : (l10n?.get('required') ?? 'Required'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _streetController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.map_outlined),
                hintText: l10n?.get('street') ?? 'Street / Location',
                labelText: l10n?.get('street') ?? 'Street / Location',
                border: const OutlineInputBorder(),
              ),
              validator: (v) => v != null && v.isNotEmpty ? null : (l10n?.get('required') ?? 'Required'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.email_outlined),
                hintText: l10n?.get('email_hint') ?? 'enter@email.com',
                labelText: l10n?.get('email') ?? 'Email Address',
                border: const OutlineInputBorder(),
              ),
              validator: (v) => v != null && v.contains('@') ? null : (l10n?.get('enter_valid_email') ?? 'Enter valid email'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.phone_outlined),
                hintText: '255...',
                labelText: l10n?.get('phone') ?? 'Phone Number',
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (v) => v != null && v.isNotEmpty ? null : (l10n?.get('required') ?? 'Required'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _gender,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.person_outline),
                hintText: l10n?.get('gender') ?? 'Gender',
                labelText: l10n?.get('gender') ?? 'Gender',
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: 'male', child: Text(l10n?.get('male') ?? 'Male')),
                DropdownMenuItem(value: 'female', child: Text(l10n?.get('female') ?? 'Female')),
              ],
              onChanged: (v) => setState(() => _gender = v),
              validator: (v) => v != null && v.isNotEmpty ? null : (l10n?.get('required') ?? 'Required'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline),
                hintText: l10n?.get('password_hint') ?? '........',
                labelText: l10n?.get('password') ?? 'Password',
                border: const OutlineInputBorder(),
              ),
              validator: (v) => v != null && v.length >= 6 ? null : (l10n?.get('min_chars') ?? 'Minimum 6 characters'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline),
                hintText: l10n?.get('password_hint') ?? '........',
                labelText: l10n?.get('confirm_password') ?? 'Confirm Password',
                border: const OutlineInputBorder(),
              ),
              validator: (v) {
                if (v != null && v.length >= 6 && v == _passwordController.text) {
                  return null;
                }
                return l10n?.get('password_mismatch') ?? 'Passwords do not match';
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: const ButtonStyle(
                backgroundColor: WidgetStatePropertyAll<Color>(Color(0xFF064e3b)),
                foregroundColor: WidgetStatePropertyAll<Color>(Colors.white),
                padding: WidgetStatePropertyAll<EdgeInsets>(EdgeInsets.symmetric(vertical: 16)),
                shape: WidgetStatePropertyAll<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
              ),
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(l10n?.get('register') ?? 'Register', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
