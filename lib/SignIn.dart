import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:jaganalar/Dashboard.dart';
import 'package:jaganalar/ForgotPassword.dart';
import 'package:jaganalar/SignIn.dart';
import 'package:jaganalar/SignUp.dart';
import 'package:jaganalar/home_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Supabase.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Signin extends StatefulWidget {
  Signin({Key? key}) : super(key: key);

  @override
  _SigninState createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  bool _hidePassword = true;
  bool _rememberMe = false;

  // handle remember me
  Future<void> saveRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', value);
  }

  Future<bool> loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('rememberMe') ?? false;
  }

  @override
  void didChangeAppLifeCycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      if (_rememberMe == false) {
        SupabaseService.client.auth.signOut();
      }
    }
  }

  // sign in
  void signIn() async {
    String password = passwordController.text;
    String email = emailController.text;

    // supabase function
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
        SnackBar(content: Text('Error: $error'));
        print(error);
      }
    }
  }

  void forgotPassword() async {}

  @override
  void dispose() {
    super.dispose();
    passwordController.dispose();
    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // checker
    bool allValid =
        passwordController.text != '' &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text('')),
      body: SafeArea(
        top: true,
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo and name
              Padding(
                padding: const EdgeInsets.only(top: 32.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset('assets/Logo.svg', width: 80, height: 80),
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Text(
                        'JagaNalar',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 70),
              Text(
                'Selamat Datang!',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Masuk ke akun anda untuk melanjutkann',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 20),
              TextField(
                onChanged: (text) => setState(() {}),
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  iconColor: Color(0xff8B8F90),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xff8B8F90)),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                onChanged: (text) => setState(() {}),
                controller: passwordController,
                obscureText: _hidePassword,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _hidePassword = !_hidePassword;
                      });
                    },
                    icon: Icon(
                      _hidePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                  ),
                  hintText: 'Kata sandi',
                  iconColor: Color(0xff8B8F90),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xff8B8F90)),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Remember me option
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        checkColor: Colors.white,
                        activeColor: Color(0xff1C6EA4),
                        onChanged: (bool? newValue) {
                          setState(() {
                            _rememberMe = newValue!;
                          });
                        },
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Remember me',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ForgotPassword(),
                        ),
                      );
                    },
                    child: Text(
                      'Lupa Password?',
                      style: TextStyle(fontSize: 16, color: Colors.blueAccent),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  allValid
                      ? signIn()
                      : ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('All fields must be completed'),
                          ),
                        );
                },
                style: ButtonStyle(
                  minimumSize: WidgetStateProperty.all(
                    Size(double.infinity, 50),
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  backgroundColor: WidgetStateProperty.all(
                    allValid ? Color(0xff1C6EA4) : Color(0xffD7D7D7),
                  ),
                  shadowColor: WidgetStateColor.transparent,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    'Masuk',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: (allValid ? Colors.white : Colors.grey[800]),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey, thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      "Atau masuk dengan",
                      style: TextStyle(fontSize: 16),
                    ), // Your text
                  ),
                  Expanded(child: Divider(color: Colors.grey, thickness: 1)),
                ],
              ),
              SizedBox(height: 24),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.white),
                  shadowColor: WidgetStateProperty.all(Colors.white),
                ),
                onPressed: () {
                  // implement later im tired
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/devicon_google.svg'),
                      SizedBox(width: 5),
                      Text(
                        'Login with Google',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 45),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Belum punya akun?', style: TextStyle(fontSize: 16)),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Signup()),
                      );
                    },
                    child: Text(
                      'Daftar',
                      style: TextStyle(color: Colors.blue, fontSize: 14),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Dengan mendaftar, anda menyetujui Ketentuan \n Layanan dan Kebijakan Privasi Meksiko',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
