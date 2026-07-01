import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class LanguageScreen extends StatelessWidget {
  final Function(String) onLangChanged;
  const LanguageScreen({super.key, required this.onLangChanged});

  Future<void> _selectLanguage(BuildContext context, String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    
    onLangChanged(lang);
    
    await Future.delayed(const Duration(milliseconds: 50));
    
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF064e3b), Color(0xFF065f46)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.monitor,
                        size: 48,
                        color: Color(0xFF064e3b),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Community Monitor',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Dar es Salaam',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Chagua Lugha / Choose Language',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _selectLanguage(context, 'sw'),
                              style: const ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll<Color>(Colors.white),
                                foregroundColor: WidgetStatePropertyAll<Color>(Color(0xFF064e3b)),
                                padding: WidgetStatePropertyAll<EdgeInsets>(EdgeInsets.symmetric(vertical: 16)),
                                shape: WidgetStatePropertyAll<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30)))),
                              ),
                              child: const Text(
                                'Kiswahili',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _selectLanguage(context, 'en'),
                              style: const ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll<Color>(Color(0x4DFFFFFF)),
                                foregroundColor: WidgetStatePropertyAll<Color>(Colors.white),
                                padding: WidgetStatePropertyAll<EdgeInsets>(EdgeInsets.symmetric(vertical: 16)),
                                shape: WidgetStatePropertyAll<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30)))),
                                side: WidgetStatePropertyAll<BorderSide>(BorderSide(color: Color(0x80FFFFFF))),
                              ),
                              child: const Text(
                                'English',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                const Spacer(),
                Center(
                  child: Text(
                    'ripoti yako haki yako',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
