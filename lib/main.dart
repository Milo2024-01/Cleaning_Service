import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'forgot_password_screen.dart';
import 'register_page.dart';
import 'service_booking.dart' as admin;
import 'home_service.dart' as user;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCSSitFz96eDcNwWtpWtOqtQs5z0gshTZw",
        authDomain: "cleaningservice-3b253.firebaseapp.com",
        projectId: "cleaningservice-3b253",
        storageBucket: "cleaningservice-3b253.appspot.com",
        messagingSenderId: "422323760236",
        appId: "1:422323760236:web:c93f39b9b2c3465fc97c49",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2CC01)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2CC01), width: 2),
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _emailController.text = prefs.getString('email') ?? '';
      _passwordController.text = prefs.getString('password') ?? '';
      _rememberMe = prefs.getBool('rememberMe') ?? false;
    });
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('email', _emailController.text);
      await prefs.setString('password', _passwordController.text);
      await prefs.setBool('rememberMe', true);
    } else {
      await prefs.remove('email');
      await prefs.remove('password');
      await prefs.setBool('rememberMe', false);
    }
  }

  String _generateOTP() {
    final now = DateTime.now();
    return (now.millisecondsSinceEpoch % 900000 + 100000).toString();
  }

  Future<void> _verifyCredentials() async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        final otp = _generateOTP();
        
        if (!mounted) return;
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('OTP Generated'),
            content: Text('Your OTP is: $otp\n\n(For OTP NGANI!!!, this would be sent to your email)'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );

        if (!mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPVerificationPage(
              email: _emailController.text.trim(),
              generatedOTP: otp,
              onVerified: (enteredOTP) {
                if (enteredOTP == otp) {
                  _completeLogin(userCredential);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid OTP')),
                  );
                }
              },
              onResend: () {
                final newOtp = _generateOTP();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('New OTP generated: $newOtp')),
                );
                return newOtp;
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login failed. Please check credentials")),
      );
    }
  }

  void _completeLogin(UserCredential userCredential) async {
    await _saveCredentials();
    
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => userCredential.user!.email == "admincs@gmail.com"
            ? const admin.ServiceBookingPage()
            : const user.HomeServicePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.yellow),
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // ignore: deprecated_member_use
                color: const Color.fromARGB(255, 0, 137, 250).withOpacity(0.8),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  _buildLoginForm(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.cleaning_services, size: 60, color: Color(0xFFE2CC01)),
          const SizedBox(height: 20),
          const Text('Login', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildTextField(_emailController, 'Enter your email', Icons.email),
          const SizedBox(height: 20),
          _buildTextField(_passwordController, 'Enter your password', Icons.lock, obscureText: true),
          const SizedBox(height: 10),
          Row(
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: (value) => setState(() => _rememberMe = value ?? false),
                activeColor: const Color(0xFFE2CC01),
              ),
              const Text('Remember Me'),
            ],
          ),
          const SizedBox(height: 20),
          _buildButton('Login', _verifyCredentials),
          const SizedBox(height: 20),
          _buildTextButton(
            'Forgot Password?',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
            ),
          ),
          const SizedBox(height: 10),
          _buildTextButton(
            'Don\'t have an account? Sign up',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterPage()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFFE2CC01)),
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2CC01)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2CC01), width: 2),
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE2CC01),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildTextButton(String text, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFFE2CC01),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class OTPVerificationPage extends StatefulWidget {
  final String email;
  final String generatedOTP;
  final Function(String) onVerified;
  final Function() onResend;

  const OTPVerificationPage({
    super.key,
    required this.email,
    required this.generatedOTP,
    required this.onVerified,
    required this.onResend,
  });

  @override
  _OTPVerificationPageState createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  int _resendTimer = 60;
  late Timer _timer;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
      } else {
        timer.cancel();
      }
    });
  }

  void _verifyOTP() {
    final enteredOTP = _otpController.text;
    
    if (enteredOTP.length != 6) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Please enter a valid 6-digit OTP';
      });
      return;
    }

    if (enteredOTP != widget.generatedOTP) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Incorrect OTP. Please try again.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    // Call the verification callback
    widget.onVerified(enteredOTP);
  }

  void _resendOTP() {
    widget.onResend();
    setState(() {
      _resendTimer = 60;
      _hasError = false;
      _otpController.clear();
    });
    _startResendTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Verification'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Enter the 6-digit code sent to',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 5),
              Text(
                widget.email,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 30),
              PinCodeTextField(
                appContext: context,
                length: 6,
                controller: _otpController,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(5),
                  fieldHeight: 50,
                  fieldWidth: 40,
                  activeFillColor: Colors.white,
                  activeColor: Colors.blue,
                  selectedColor: Colors.blue,
                  inactiveColor: Colors.grey,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _hasError = false;
                  });
                },
              ),
              if (_hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _verifyOTP,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Verify OTP',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
              const SizedBox(height: 20),
              Center(
                child: _resendTimer > 0
                    ? Text(
                        'Resend OTP in $_resendTimer seconds',
                        style: const TextStyle(color: Colors.grey),
                      )
                    : TextButton(
                        onPressed: _resendOTP,
                        child: Text(
                          'Resend OTP',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}