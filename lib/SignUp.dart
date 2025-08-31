import 'package:flutter/material.dart';
import 'package:jaganalar/SignIn.dart';
import 'package:jaganalar/home_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Supabase.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Signup extends StatefulWidget {
  Signup({Key? key}) : super(key: key);

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _hidePassword = true;
  bool _hidePassword2 = true;
  
  // sign up
  void signUp() async {
    String username = usernameController.text;
    String password = passwordController.text;
    String email = emailController.text;
    String confirmPassword = confirmPasswordController.text;
    
    // supabase function
    if (username.isNotEmpty && password.isNotEmpty && email.isNotEmpty) {
      try {
        final AuthResponse res = await SupabaseService.client.auth.signUp(
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
          MaterialPageRoute(builder: (context) => Signin()),
        );
      } catch (error) {
        SnackBar(content: Text('Error: $error'));
        print(error);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    usernameController.dispose();
    passwordController.dispose();
    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
     // checker
    bool allValid = 
    usernameController.text.isNotEmpty && 
    passwordController.text != '' && 
    emailController.text.isNotEmpty && 
    passwordController.text.isNotEmpty && 
    confirmPasswordController.text.isNotEmpty && 
    (passwordController.text == confirmPasswordController.text);


    return Scaffold(
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
                padding: const EdgeInsets.only(top: 86.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xff1C6EA4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10),
                        child: Text(
                          'Logo',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Text(
                        'Nama',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 20
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 70),
              Text(
                'Buat Akun',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Daftarkan akun anda untuk mengakses aplikasi',
                style: TextStyle(
                  fontSize: 14
                ),
              ),
              SizedBox(height: 20,),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  hintText: 'Nama lengkap',
                  iconColor: Color(0xff8B8F90),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Color(0xff8B8F90)
                    )
                  )
                ),
              ),
              SizedBox(height: 20,),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  iconColor: Color(0xff8B8F90),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Color(0xff8B8F90)
                    )
                  )
                ),
              ),
              SizedBox(height: 20,),
              TextField(
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
                      _hidePassword ? Icons.visibility_off : Icons.visibility 
                    )),
                  hintText: 'Kata sandi',
                  iconColor: Color(0xff8B8F90),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Color(0xff8B8F90)
                    )
                  )
                ),
              ),
              SizedBox(height: 20,),
              TextField(
                controller: confirmPasswordController,
                obscureText: _hidePassword2,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: () {
                    setState(() {
                      _hidePassword2 = !_hidePassword2;
                    });
                    }, 
                    icon: Icon(
                      _hidePassword2 ? Icons.visibility_off : Icons.visibility 
                    )),
                  hintText: 'Konfirmasi Kata sandi',
                  iconColor: Color(0xff8B8F90),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Color(0xff8B8F90)
                    )
                  )
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {

                },
                style: ButtonStyle(
                  minimumSize: WidgetStateProperty.all(Size(double.infinity, 50)),
                  shape: WidgetStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)
                  )),
                  backgroundColor: WidgetStateProperty.all(allValid ? Color(0xff1C6EA4) : Color(0xffD7D7D7)),
                  shadowColor: WidgetStateColor.transparent
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    'Daftar Akun',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: (allValid ? Colors.white : Colors.grey[800] )
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Row(
              children: [
                Expanded(
                  child: Divider(
                    color: Colors.grey,
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text("Atau daftar dengan"), // Your text
                ),
                Expanded(
                  child: Divider(
                    color: Colors.grey,
                    thickness: 1,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.white),
                shadowColor: WidgetStateProperty.all(Colors.white)
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
                        color: Colors.black
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
                Text(
                  'Sudah punya akun?',
                  style: TextStyle(
                    fontSize: 14
                  ),
                  ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Signin())
                    );
                  }, 
                  child: Text(
                    'Masuk',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 14,
                    ),
                    )
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
                  ),
              ],
            )
            ],
          ),
        ),
      ),
    );
  }
}
