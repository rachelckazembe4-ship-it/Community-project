import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isSent = false;

  Future<void> _sendResetEmail() async {
    if (_emailController.text.trim().isEmpty || !_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.get('enter_valid_email') ?? 'Enter a valid email')),
      );
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isLoading = false;
        _isSent = true;
      });
    }
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n?.get('reset_password_title') ?? 'Reset Your Password',
          style: const TextStyle(color: Color(0xFF064e3b), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF064e3b).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  _isSent ? Icons.check_circle_outline : Icons.lock_reset,
                  size: 48,
                  color: const Color(0xFF064e3b),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _isSent
                    ? (l10n?.get('reset_password_desc') ?? 'Check your email for reset instructions.')
                    : (l10n?.get('reset_password_title') ?? 'Reset Your Password'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF064e3b)),
              ),
              const SizedBox(height: 12),
              Text(
                l10n?.get('reset_password_desc') ?? 'Enter your email address and we will send you instructions to reset your password.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              if (!_isSent) ...[
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email_outlined),
                    hintText: l10n?.get('email_hint') ?? 'enter@email.com',
                    labelText: l10n?.get('email') ?? 'Email Address',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _sendResetEmail,
                  style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll<Color>(Color(0xFF064e3b)),
                    foregroundColor: WidgetStatePropertyAll<Color>(Colors.white),
                    padding: WidgetStatePropertyAll<EdgeInsets>(EdgeInsets.symmetric(vertical: 16)),
                    shape: WidgetStatePropertyAll<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(l10n?.get('send') ?? 'Send', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ] else ...[
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll<Color>(Color(0xFF064e3b)),
                    foregroundColor: WidgetStatePropertyAll<Color>(Colors.white),
                    padding: WidgetStatePropertyAll<EdgeInsets>(EdgeInsets.symmetric(vertical: 16)),
                    shape: WidgetStatePropertyAll<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
                  ),
                  child: Text(l10n?.get('back_to_login') ?? 'Back to Login', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
              const SizedBox(height: 16),
              if (!_isSent)
                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: Text(l10n?.get('back_to_login') ?? 'Back to Login'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
