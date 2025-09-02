import 'package:flutter/material.dart';
import 'package:jaganalar/SignIn.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Supabase.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _hidePassword = true;
  bool _hidePassword2 = true;

  void signUp() async {
    String username = usernameController.text;
    String password = passwordController.text;
    String email = emailController.text;

    if (username.isNotEmpty &&
        password.isNotEmpty &&
        email.isNotEmpty &&
        password == confirmPasswordController.text) {
      try {
        final res = await SupabaseService.client.auth.signUp(
          email: email,
          password: password,
          data: {'username': username},
        );
        await SupabaseService.client.from('users').insert({
          'uuid': res.user?.id,
          'username': username,
          'email': email,
          'timestamp': DateTime.now().toIso8601String(),
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Signin()),
        );
      } catch (error) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $error')));
      }
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    bool allValid =
        usernameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        passwordController.text == confirmPasswordController.text;

    return Scaffold(
      appBar: AppBar(title: Text(''), scrolledUnderElevation: 0),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.03,
          ),
          children: [
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/Logo.svg',
                    width: screenWidth * 0.15,
                    height: screenWidth * 0.15,
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
            ),
            SizedBox(height: screenHeight * 0.03),
            Text(
              'Buat Akun',
              style: TextStyle(
                fontSize: screenWidth * 0.07,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.005),
            Text(
              'Daftarkan akun anda untuk mengakses aplikasi',
              style: TextStyle(fontSize: screenWidth * 0.04),
            ),
            SizedBox(height: screenHeight * 0.03),

            // Form Fields
            ...[
              {
                'controller': usernameController,
                'hint': 'Nama lengkap',
                'hide': false,
              },
              {'controller': emailController, 'hint': 'Email', 'hide': false},
              {
                'controller': passwordController,
                'hint': 'Kata sandi',
                'hide': true,
              },
              {
                'controller': confirmPasswordController,
                'hint': 'Konfirmasi Kata sandi',
                'hide': true,
              },
            ].map((field) {
              bool obscure = field['hide'] as bool;
              TextEditingController controller =
                  field['controller'] as TextEditingController;
              return Padding(
                padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                child: TextField(
                  controller: controller,
                  obscureText: obscure
                      ? (controller == passwordController
                            ? _hidePassword
                            : _hidePassword2)
                      : false,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: field['hint'] as String,
                    suffixIcon: obscure
                        ? IconButton(
                            icon: Icon(
                              controller == passwordController
                                  ? (_hidePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility)
                                  : (_hidePassword2
                                        ? Icons.visibility_off
                                        : Icons.visibility),
                            ),
                            onPressed: () {
                              setState(() {
                                if (controller == passwordController) {
                                  _hidePassword = !_hidePassword;
                                } else {
                                  _hidePassword2 = !_hidePassword2;
                                }
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              );
            }).toList(),

            ElevatedButton(
              onPressed: allValid
                  ? signUp
                  : () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('All fields must be filled')),
                    ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, screenHeight * 0.07),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: allValid ? Color(0xff1C6EA4) : Colors.grey,
              ),
              child: Text(
                'Daftar Akun',
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  color: Color(0xff717171),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),

            // Or Divider
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                  child: Text("Atau daftar dengan"),
                ),
                Expanded(child: Divider(color: Colors.grey)),
              ],
            ),
            SizedBox(height: screenHeight * 0.03),

            // Google Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                minimumSize: Size(double.infinity, screenHeight * 0.07),
              ),
              onPressed: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/devicon_google.svg',
                    width: screenWidth * 0.06,
                    height: screenWidth * 0.06,
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Flexible(
                    child: Text(
                      'Login with Google',
                      style: TextStyle(fontSize: screenWidth * 0.045),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.04),

            // Already have account
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Sudah punya akun?',
                  style: TextStyle(fontSize: screenWidth * 0.04),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => Signin()),
                    );
                  },
                  child: Text(
                    'Masuk',
                    style: TextStyle(fontSize: screenWidth * 0.04),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              'Dengan mendaftar, anda menyetujui Ketentuan Layanan dan Kebijakan Privasi Meksiko',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: screenWidth * 0.035),
            ),
            SizedBox(height: screenHeight * 0.03),
          ],
        ),
      ),
    );
  }
}
