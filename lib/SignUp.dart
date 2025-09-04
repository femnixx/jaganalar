import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jaganalar/SignIn.dart';
import 'package:jaganalar/main_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Supabase.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Listen to auth state changes
    SupabaseService.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MyMainScreen()),
        );
      }
    });

    // Check current session on start
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkSession());
  }

  Future<void> _checkSession() async {
    final session = SupabaseService.client.auth.currentSession;
    if (session != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MyMainScreen()),
      );
    }
  }

  Future<void> signInWithEmail() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) return;

    try {
      final res = await SupabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final session = SupabaseService.client.auth.currentSession;
      if (session != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MyMainScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login gagal, coba lagi.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await SupabaseService.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutter://login-callback',
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login gagal: $e')));
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _usernameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _passwordController.text == _confirmPasswordController.text;
  }

  Future<void> _signUp() async {
    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All fields must be filled and passwords must match.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Sign up with Supabase Auth
      final res = await SupabaseService.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        data: {'username': _usernameController.text.trim()},
      );

      if (res.user != null) {
        // Insert user into `users` table
        await SupabaseService.client.from('users').insert({
          'uuid': res.user!.id,
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'timestamp': DateTime.now().toIso8601String(),
        });

        // Navigate to SignIn page
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Signin()),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $error')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool isPassword = false,
    bool hidePassword = false,
    VoidCallback? toggleHidePassword,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? hidePassword : false,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  hidePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: toggleHidePassword,
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text(''), scrolledUnderElevation: 0),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.03,
          ),
          children: [
            // Logo
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
            _buildTextField(
              controller: _usernameController,
              hint: 'Nama lengkap',
            ),
            SizedBox(height: screenHeight * 0.02),
            _buildTextField(controller: _emailController, hint: 'Email'),
            SizedBox(height: screenHeight * 0.02),
            _buildTextField(
              controller: _passwordController,
              hint: 'Kata sandi',
              isPassword: true,
              hidePassword: _hidePassword,
              toggleHidePassword: () =>
                  setState(() => _hidePassword = !_hidePassword),
            ),
            SizedBox(height: screenHeight * 0.02),
            _buildTextField(
              controller: _confirmPasswordController,
              hint: 'Konfirmasi Kata sandi',
              isPassword: true,
              hidePassword: _hideConfirmPassword,
              toggleHidePassword: () =>
                  setState(() => _hideConfirmPassword = !_hideConfirmPassword),
            ),
            SizedBox(height: screenHeight * 0.03),

            // Signup Button
            ElevatedButton(
              onPressed: _isFormValid && !_isLoading ? _signUp : null,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, screenHeight * 0.07),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: _isFormValid
                    ? const Color(0xff1C6EA4)
                    : Colors.grey,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Daftar Akun',
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        color: Colors.white,
                      ),
                    ),
            ),
            SizedBox(height: screenHeight * 0.03),

            // Or Divider
            Row(
              children: [
                const Expanded(child: Divider(color: Colors.grey)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                  child: const Text("Atau daftar dengan"),
                ),
                const Expanded(child: Divider(color: Colors.grey)),
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
                      MaterialPageRoute(builder: (_) => const Signin()),
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
