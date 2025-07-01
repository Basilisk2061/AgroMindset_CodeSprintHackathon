import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:plantd/screen/home_screen.dart';


class LoginSignupPage extends StatefulWidget {
  const LoginSignupPage({super.key});
  @override
  State<LoginSignupPage> createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage>
    with SingleTickerProviderStateMixin {
  bool isLogin = true;
  bool isNepali = true;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPassController = TextEditingController();

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Map<String, String> get text => isNepali
      ? {
          'login': 'लग - इन',
          'signup': 'साइन अप',
          'email': 'इमेल',
          'password': 'पासवर्ड',
          'confirm': 'पासवर्ड पुष्टि गर्नुहोस्',
          'switchToSignup': 'खाता छैन? साइन अप गर्नुहोस्',
          'switchToLogin': 'पहिले नै खाता छ? लग - इन गर्नुहोस्',
          'language': 'ENGLISH'
        }
      : {
          'login': 'Login',
          'signup': 'Sign Up',
          'email': 'Email',
          'password': 'Password',
          'confirm': 'Confirm Password',
          'switchToSignup': "Don't have an account? Sign up",
          'switchToLogin': "Already have an account? Login",
          'language': 'नेपाली'
        };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0f2027), Color(0xFF2c5364)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 10, right: 16),
                child: ElevatedButton(
                  onPressed: () => setState(() => isNepali = !isNepali),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.3),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(text['language']!),
                ),
              ),
            ),
          ),
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    width: 350,
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25.0),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isLogin ? "🌿 ${text['login']}" : "🌱 ${text['signup']}",
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration(text['email']!, Icons.email),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration:
                              _inputDecoration(text['password']!, Icons.lock),
                        ),
                        if (!isLogin) ...[
                          const SizedBox(height: 16),
                          TextField(
                            controller: _confirmPassController,
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration(
                                text['confirm']!, Icons.lock_outline),
                          ),
                        ],
                        const SizedBox(height: 30),
                        GestureDetector(
                          onTap: () {
                            final email = _emailController.text;
                            final pass = _passwordController.text;
                            if (isLogin) {
                              Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomeScreen(isNepali: isNepali),
                              ),
                            );
                              // TODO: Implement login logic or call Firebase/Auth API
                            } else {
                              final confirm = _confirmPassController.text;
                              if (pass == confirm) {
                                print("Signing up: $email | $pass");
                                // TODO: Implement signup logic
                              } else {
                                print("Passwords do not match!");
                              }
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.teal, Colors.greenAccent],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.greenAccent.withOpacity(0.5),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 6),
                                )
                              ],
                            ),
                            child: Center(
                              child: Text(
                                isLogin ? text['login']! : text['signup']!,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => setState(() => isLogin = !isLogin),
                          child: Text(
                            isLogin
                                ? text['switchToSignup']!
                                : text['switchToLogin']!,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white30),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.greenAccent),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
