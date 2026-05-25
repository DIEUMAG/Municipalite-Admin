// lib/screens/login_screen.dart

import 'package:flutter/material.dart';

import '/core/api/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController usernameController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {

    // Validation
    if (usernameController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez remplir tous les champs',
          ),
        ),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {

      final success = await AuthService().login(
        username: usernameController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      if (success) {

        Navigator.pushReplacementNamed(
          context,
          '/dashboard',
        );

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Nom d’utilisateur ou mot de passe incorrect',
            ),
          ),
        );
      }

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur: $e',
          ),
        ),
      );

    } finally {

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF5F7FA),

      body: Center(
        child: SingleChildScrollView(

          padding: const EdgeInsets.all(20),

          child: Container(

            width: 400,

            padding: const EdgeInsets.all(24),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius: BorderRadius.circular(20),

              boxShadow: [
                BoxShadow(
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  color: Colors.grey.shade300,
                ),
              ],
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [

                const Icon(
                  Icons.admin_panel_settings,
                  size: 80,
                  color: Colors.blue,
                ),

                const SizedBox(height: 20),

                const Text(
                  "Connexion Administrateur",

                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                // USERNAME
                TextField(

                  controller: usernameController,

                  decoration: InputDecoration(

                    labelText: "Nom d'utilisateur",

                    prefixIcon: const Icon(
                      Icons.person,
                    ),

                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // PASSWORD
                TextField(

                  controller: passwordController,

                  obscureText: true,

                  decoration: InputDecoration(

                    labelText: "Mot de passe",

                    prefixIcon: const Icon(
                      Icons.lock,
                    ),

                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // LOGIN BUTTON
                SizedBox(

                  width: double.infinity,
                  height: 50,

                  child: ElevatedButton(

                    onPressed:
                        isLoading ? null : login,

                    style: ElevatedButton.styleFrom(

                      backgroundColor:
                          Colors.blue,

                      foregroundColor:
                          Colors.white,

                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                    ),

                    child: isLoading

                        ? const SizedBox(

                            height: 22,
                            width: 22,

                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )

                        : const Text(
                            'Se connecter',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.bold,
                            ),
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