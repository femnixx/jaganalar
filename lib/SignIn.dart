import 'package:flutter/material.dart';
import 'package:jaganalar/Dashboard.dart';
import 'package:jaganalar/ForgotPassword.dart';
import 'package:jaganalar/SignUp.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Supabase.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Signin extends StatefulWidget {
  const Signin({Key? key}) : super(key: key);

  @override
  _SigninState createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  bool _hidePassword = true;
  bool _rememberMe = false;

  Future<void> signInWithGoogle() async {
    try {
      // Start OAuth login
      await SupabaseService.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutter://login-callback',
      );

      // Listen for session change once
      SupabaseService.client.auth.onAuthStateChange.listen((data) async {
        final session = data.session;
        if (session != null) {
          final user = session.user;

          // Check if user already exists in your "users" table
          final existingUser = await SupabaseService.client
              .from('users')
              .select()
              .eq('uuid', user.id)
              .maybeSingle();

          if (existingUser == null) {
            // Insert only if it doesn't exist
            await SupabaseService.client.from('users').insert({
              'uuid': user.id,
              'username': user.userMetadata?['full_name'] ?? 'Anonymous',
              'email': user.email,
              'timestamp': DateTime.now().toIso8601String(),
            });
          }

          // Navigate after everything is done
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Dashboard()),
            );
          }
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login gagal : $e')));
    }
  }

  Future<void> signInWithEmail() async {
    final email = emailController.text;
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) return;

    try {
      final res = await SupabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = res.user;
      if (user != null && context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Dashboard()),
        ).then((_) {});
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
      print(e);
    }
  }

  @override
  void dispose() {
    passwordController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    bool allValid =
        emailController.text.isNotEmpty && passwordController.text.isNotEmpty;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.05,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: screenHeight * 0.05),
                      // Logo and App Name
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/Logo.svg',
                            width: screenWidth * 0.2,
                            height: screenWidth * 0.2,
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          Text(
                            'JagaNalar',
                            style: TextStyle(
                              fontSize: screenWidth * 0.06,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.05),
                      Text(
                        'Selamat Datang!',
                        style: TextStyle(
                          fontSize: screenWidth * 0.07,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        'Masuk ke akun anda untuk melanjutkan',
                        style: TextStyle(fontSize: screenWidth * 0.04),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      // Email TextField
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      // Password TextField
                      TextField(
                        controller: passwordController,
                        obscureText: _hidePassword,
                        decoration: InputDecoration(
                          hintText: 'Kata sandi',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _hidePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _hidePassword = !_hidePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      // Remember Me & Forgot Password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (val) {
                                  setState(() {
                                    _rememberMe = val!;
                                  });
                                },
                              ),
                              const Text('Remember me'),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ForgotPassword(),
                                ),
                              );
                            },
                            child: const Text('Lupa Password?'),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      // Login Button
                      ElevatedButton(
                        onPressed: allValid ? signInWithEmail : null,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(
                            double.infinity,
                            screenHeight * 0.07,
                          ),
                          backgroundColor: allValid
                              ? const Color(0xff1C6EA4)
                              : Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Masuk',
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            color: allValid ? Colors.white : Colors.black54,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.02,
                            ),
                            child: const Text('Atau masuk dengan'),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Google Login Button
                      ElevatedButton(
                        onPressed: signInWithGoogle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          minimumSize: Size(
                            double.infinity,
                            screenHeight * 0.07,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/devicon_google.svg',
                              width: screenWidth * 0.06,
                              height: screenWidth * 0.06,
                            ),
                            const SizedBox(width: 10),
                            const Text('Login with Google'),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Belum punya akun?'),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => Signup()),
                              );
                            },
                            child: const Text('Daftar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
