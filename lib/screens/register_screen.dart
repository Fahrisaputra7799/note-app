import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_app/widgets/build_input_file.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final auth = ref.read(authServiceProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Center(
            child: Column(
              children: [
                Padding(padding: EdgeInsetsGeometry.only(top: 210)),
                Icon(Icons.person_add_alt_1, size: 64, color: primaryColor),
                const SizedBox(height: 16),
                const Text(
                  "Buat Akun Baru",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),

                // Email Field
                _buildInputField(
                  label: "Email",
                  controller: emailController,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Email wajib diisi';
                    if (!value.contains('@')) return 'Format email tidak valid';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Password
                _buildInputField(
                  label: "Password",
                  controller: passwordController,
                  icon: Icons.lock_outline,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.length < 6)
                      return 'Minimal 6 karakter';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Konfirmasi Password
                _buildInputField(
                  label: "Konfirmasi Password",
                  controller: confirmPasswordController,
                  icon: Icons.lock_person_outlined,
                  isPassword: true,
                  validator: (value) {
                    if (value != passwordController.text)
                      return 'Konfirmasi tidak cocok';
                    return null;
                  },
                ),

                const SizedBox(height: 28),

                // Tombol Register
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed:
                        _isLoading
                            ? null
                            : () async {
                              if (!_formKey.currentState!.validate()) return;
                              setState(() => _isLoading = true);
                              try {
                                await auth.signUp(
                                  emailController.text,
                                  passwordController.text,
                                  confirmPasswordController.text,
                                );
                                if (!mounted) return;
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Colors.green,
                                    content: Text(
                                      'Registrasi berhasil!',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text(
                                      'Registrasi gagal: $e',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                              } finally {
                                setState(() => _isLoading = false);
                              }
                            },
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              "Daftar",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: Text(
                    'Sudah punya akun? Login',
                    style: TextStyle(color: primaryColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  final Color primaryColor = const Color(0xFF1D3557); // Biru navy
  final Color accentColor = const Color(0xFFE63946);

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: label,
        prefixIcon: Icon(icon, color: primaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
