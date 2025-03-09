import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'forgot_password_screen.dart';
import 'register_page.dart';
import 'home_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyCSSitFz96eDcNwWtpWtOqtQs5z0gshTZw",
        authDomain: "cleaningservice-3b253.firebaseapp.com",
        projectId: "cleaningservice-3b253",
        storageBucket: "cleaningservice-3b253.firebasestorage.app",
        messagingSenderId: "422323760236",
        appId: "1:422323760236:web:c93f39b9b2c3465fc97c49",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signInWithEmail() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _usernameController.text,
        password: _passwordController.text,
      );
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Successful')),
      );
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => HomeServicePage()),
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error during login: $e");
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Login failed. Please check your credentials")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Yellow Background
          Container(color: const Color.fromARGB(255, 250, 225, 0)),

          // White & Blue Curved Design
          Positioned(
            top: -MediaQuery.of(context).size.height * 0.2,
            left: -MediaQuery.of(context).size.width * 0.2,
            child: CustomPaint(
              size: Size(MediaQuery.of(context).size.width * 1.5,
                  MediaQuery.of(context).size.height * 0.6),
              painter: CurvePainter(),
            ),
          ),

          // Login Form
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cleaning_services,
                        size: 80, color: Colors.yellow.shade700),
                    const SizedBox(height: 20),
                    Text('Login',
                        style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    const SizedBox(height: 30),
                    _buildTextField(
                        _usernameController, 'Enter your email', Icons.email),
                    const SizedBox(height: 20),
                    _buildTextField(
                        _passwordController, 'Enter your password', Icons.lock,
                        obscureText: true),
                    const SizedBox(height: 20),
                    _buildButton('Login', _signInWithEmail),
                    const SizedBox(height: 20),
                    _buildTextButton(
                        'Forgot Password?',
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ForgotPasswordScreen()))),
                    const SizedBox(height: 10),
                    _buildTextButton(
                        'Don\'t have an account? Sign up',
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegisterPage()))),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hint, IconData icon,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.yellow.shade700),
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      obscureText: obscureText,
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.yellow.shade700,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5,
      ),
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildTextButton(String text, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(color: Colors.black87, fontSize: 16),
      ),
    );
  }
}

class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final bluePaint = Paint()
      ..color = Colors.blue.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    // White Background Shape
    final path = Path()
      ..moveTo(0, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.4, size.width * 0.6,
          size.height * 0.6)
      ..quadraticBezierTo(
          size.width * 0.9, size.height * 0.8, size.width, size.height * 0.6)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, whitePaint);

    // Multiple Blue Lines for a Wavy Effect
    for (double i = 0.55; i <= 0.7; i += 0.05) {
      final bluePath = Path()
        ..moveTo(0, size.height * i)
        ..quadraticBezierTo(size.width * 0.3, size.height * (i - 0.2),
            size.width * 0.6, size.height * i)
        ..quadraticBezierTo(size.width * 0.9, size.height * (i + 0.2),
            size.width, size.height * i);
      canvas.drawPath(bluePath, bluePaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
