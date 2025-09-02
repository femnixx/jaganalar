import 'package:dash_chat_2/dash_chat_2.dart';
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
      await SupabaseService.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutter://login-callback',
        scopes: 'email profile',
      );

      // once user signs in
      final session = SupabaseService.client.auth.currentSession;
      if (session != null) {
        final user = session.user;

        if (user != null &&
            (user.userMetadata == null ||
                user.userMetadata!['full_name'] == null)) {
          await SupabaseService.client.auth.updateUser(
            UserAttributes(
              data: {
                'full_name': user.userMetadata?['full_name'] ?? 'Anonymous',
              },
            ),
          );
        }
        final existingUserResponse = await SupabaseService.client
            .from('users')
            .select()
            .eq('uuid', user.id); // no execute()

        final existingUser = existingUserResponse as List<dynamic>?;

        if (existingUser!.isEmpty) {
          await SupabaseService.client.from('users').insert({
            'uuid': user.id,
            'username': user.userMetadata?['full_name'] ?? 'Anonymous',
            'email': user.email,
            'timestamp': DateTime.now().toIso8601String(),
          });
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Dashboard()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> saveRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', value);
  }

  Future<bool> loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('rememberMe') ?? false;
  }

  void signIn() async {
    String password = passwordController.text;
    String email = emailController.text;

    if (password.isNotEmpty && email.isNotEmpty) {
      try {
        final AuthResponse res = await SupabaseService.client.auth
            .signInWithPassword(email: email, password: password);
        if (res != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Dashboard()),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $error')));
        print(error);
      }
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
                      // Logo
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
                        'Masuk ke akun anda untuk melanjutkann',
                        style: TextStyle(fontSize: screenWidth * 0.04),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: screenHeight * 0.03),

                      // Email
                      TextField(
                        controller: emailController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      // Password
                      TextField(
                        controller: passwordController,
                        onChanged: (_) => setState(() {}),
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
                                onChanged: (value) {
                                  setState(() {
                                    _rememberMe = value!;
                                  });
                                },
                              ),
                              Text('Remember me'),
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
                            child: Text('Lupa Password?'),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      // Login Button
                      ElevatedButton(
                        onPressed: allValid
                            ? signIn
                            : null, // disables if not valid
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(
                            double.infinity,
                            screenHeight * 0.07,
                          ),
                          backgroundColor: allValid
                              ? Color(0xff1C6EA4)
                              : Color(0xffD7D7D7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Masuk',
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            color: allValid ? Colors.white : Color(0xff717171),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),

                      // Or Login With
                      Row(
                        children: [
                          Expanded(
                            child: Divider(color: Colors.grey, thickness: 1),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.02,
                            ),
                            child: Text("Atau masuk dengan"),
                          ),
                          Expanded(
                            child: Divider(color: Colors.grey, thickness: 1),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      // Google Login
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          minimumSize: Size(
                            double.infinity,
                            screenHeight * 0.07,
                          ),
                        ),
                        onPressed: signInWithGoogle,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/devicon_google.svg',
                              width: screenWidth * 0.06,
                              height: screenWidth * 0.06,
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Text(
                              'Login with Google',
                              style: TextStyle(fontSize: screenWidth * 0.045),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),

                      // Signup
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Belum punya akun?'),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => Signup()),
                              );
                            },
                            child: Text('Daftar'),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        'Dengan mendaftar, anda menyetujui Ketentuan Layanan dan Kebijakan Privasi Meksiko',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: screenWidth * 0.035),
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
