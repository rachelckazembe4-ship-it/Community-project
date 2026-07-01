import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'dashboard_screen.dart';
import 'forgot_password_screen.dart';
import 'language_screen.dart';
import '../services/api_service.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isLogin = true;
  String? _errorMsg;

  final ApiService _api = ApiService();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    try {
      await _api.login(_emailController.text.trim(), _passwordController.text);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMsg = e.toString().replaceAll("Exception: ", ""));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMsg!)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  void _goToForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
    );
  }

  void _goBackToLanguage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LanguageScreen(
          onLangChanged: (lang) {
            final app = context.findAncestorStateOfType<CommunityMonitorAppState>();
            app?.changeLang(lang);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF064e3b)),
          onPressed: _goBackToLanguage,
        ),
        title: Text(
          _isLogin ? (l10n?.get('login') ?? 'Log In') : (l10n?.get('register') ?? 'Register'),
          style: const TextStyle(color: Color(0xFF064e3b), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Text(
                  l10n?.get('app_name') ?? 'Community Monitor',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF064e3b)),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin
                      ? (l10n?.get('welcome_back') ?? 'Welcome back! Log in to report issues or track progress.')
                      : (l10n?.get('register_subtitle') ?? 'Register to start reporting issues in your community.'),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),
                Row(children: [
                  Expanded(child: _buildTab(l10n?.get('login') ?? 'Log In', _isLogin, () => setState(() => _isLogin = true))),
                  Expanded(child: _buildTab(l10n?.get('register') ?? 'Register', !_isLogin, _goToRegister)),
                ]),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email_outlined),
                    hintText: l10n?.get('email_hint') ?? 'enter@email.com',
                    labelText: l10n?.get('email') ?? 'Email Address',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                  ),
                  validator: (v) => v != null && v.contains('@') ? null : (l10n?.get('enter_valid_email') ?? 'Enter a valid email'),
                ),
                if (_isLogin) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline),
                      hintText: l10n?.get('password_hint') ?? '........',
                      labelText: l10n?.get('password') ?? 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                    ),
                    validator: (v) => v != null && v.length >= 6 ? null : (l10n?.get('min_chars') ?? 'Minimum 6 characters'),
                  ),
                ],
                const SizedBox(height: 32),
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
                      : Text(_isLogin ? (l10n?.get('login') ?? 'Log In') : (l10n?.get('register') ?? 'Register'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                if (_isLogin)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(onPressed: _goToForgotPassword, child: Text(l10n?.get('forgot_password') ?? 'Forgot Password?')),
                  )
                else
                  TextButton.icon(
                    onPressed: _goToRegister,
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: Text(l10n?.get('back_to_login') ?? 'Back to Login'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String title, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: active ? const Color(0xFF064e3b) : Colors.transparent, width: 3)),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: active ? const Color(0xFF064e3b) : Colors.grey,
          ),
        ),
      ),
    );
  }
}
