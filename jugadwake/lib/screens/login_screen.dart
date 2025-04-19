import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_theme.dart';
import 'main_screen.dart';

// 1. Make sure your AndroidManifest has internet permission:
//    <uses-permission android:name="android.permission.INTERNET"/>
// 2. Download a valid Lottie JSON (e.g. mic.json) and place it under assets/animations/
// 3. In pubspec.yaml, include:
//
// flutter:
//   assets:
//     - assets/animations/mic.json

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();

  // Lottie animation controller
  late AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Background gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white, Colors.blue.shade50],
                  ),
                ),
              ),
            ),

            // Lottie from local asset
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.4,
              child: Container(
                color: Colors.grey.shade200,
                child: Lottie.asset(
                  'assets/animations/mic.json',
                  controller: _lottieController,
                  fit: BoxFit.cover,
                  onLoaded: (composition) {
                    // Play at 3× speed
                    _lottieController
                      ..duration = composition.duration * (1 / 3)
                      ..repeat();
                  },
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('Lottie error: $error');
                    return Container(
                      color: AppTheme.primary.withAlpha(30),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: AppTheme.primary,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to load animation',
                              style: TextStyle(color: AppTheme.primary),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Content layout
            Column(
              children: [
                // Logo section
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(26),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.mic,
                            size: 48,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Login form sheet
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Sign in to your account',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF222222),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Social login
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.facebook, color: Color(0xFF222222)),
                                    label: const Text('Facebook', style: TextStyle(color: Color(0xFF222222))),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      side: const BorderSide(color: Color(0xFFE0E0E0)),
                                      shape: const StadiumBorder(),
                                    ),
                                    onPressed: () {},
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.g_mobiledata, color: Color(0xFF222222), size: 24),
                                    label: const Text('Google', style: TextStyle(color: Color(0xFF222222))),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      side: const BorderSide(color: Color(0xFFE0E0E0)),
                                      shape: const StadiumBorder(),
                                    ),
                                    onPressed: () {},
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Divider
                            Row(
                              children: const [
                                Expanded(child: Divider(color: Color(0xFFE0E0E0))),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text('Or', style: TextStyle(color: Color(0xFF888888))),
                                ),
                                Expanded(child: Divider(color: Color(0xFFE0E0E0))),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Email field
                            TextFormField(
                              decoration: InputDecoration(
                                hintText: 'Enter your email address',
                                filled: true,
                                fillColor: const Color(0xFFF7F7F7),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.primary)),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) => (value == null || value.isEmpty) ? 'Please enter your email' : null,
                            ),
                            const SizedBox(height: 12),

                            // Password field
                            TextFormField(
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                hintText: '•••••••',
                                filled: true,
                                fillColor: const Color(0xFFF7F7F7),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.primary)),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: const Color(0xFF888888),
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              validator: (value) => (value == null || value.isEmpty) ? 'Please enter your password' : null,
                            ),
                            const SizedBox(height: 4),

                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(padding: EdgeInsets.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                                child: const Text('Forget Password?', style: TextStyle(color: Color(0xFF007AFF), fontSize: 12)),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Log In button
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (_) => const MainScreen()),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF007AFF),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('Log In', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Footer
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Don't have an account?", style: TextStyle(color: Color(0xFF888888), fontSize: 14)),
                                TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(padding: EdgeInsets.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                                  child: const Text('Sign Up', style: TextStyle(color: Color(0xFF007AFF), fontSize: 14, fontWeight: FontWeight.w500)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}