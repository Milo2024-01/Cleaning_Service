import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this import
import 'forgot_password_screen.dart';
import 'register_page.dart';
import 'service_booking.dart'; // Admin page
import 'home_service.dart'; // Regular user page

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
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _rememberMe = false; // Track "Remember Me" state

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials(); // Load saved credentials when the page loads
  }

  // Load saved email and password from SharedPreferences
  Future<void> _loadSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _emailController.text = prefs.getString('email') ?? '';
      _passwordController.text = prefs.getString('password') ?? '';
      _rememberMe = prefs.getBool('rememberMe') ?? false;
    });
  }

  // Save email and password to SharedPreferences
  Future<void> _saveCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
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

  Future<void> _signInWithEmail() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      User? user = userCredential.user;
      if (user != null) {
        // Save credentials if "Remember Me" is checked
        await _saveCredentials();

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login Successful')),
        );

        // Redirect based on user type
        if (user.email == "admincs@gmail.com") {
          Navigator.pushReplacement(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(builder: (context) => ServiceBookingPage()),
          );
        } else {
          Navigator.pushReplacement(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(builder: (context) => HomeServicePage()),
          );
        }
      }
    } catch (e) {
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
          // Yellow background
          Container(color: Colors.yellow),

          // Big and small blue circles
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
          Positioned(
            top: 100,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // ignore: deprecated_member_use
                color: const Color.fromARGB(255, 0, 139, 253).withOpacity(0.8),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // ignore: deprecated_member_use
                color: const Color.fromARGB(255, 0, 140, 255).withOpacity(0.8),
              ),
            ),
          ),

          // White curved background
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: CurvedWhiteBackgroundClipper(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.6,
                color: const Color.fromARGB(255, 245, 245, 245),
              ),
            ),
          ),

          // Login form
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40), // Space at the top
                  _buildLoginForm(),
                  const SizedBox(height: 40), // Space at the bottom
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
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cleaning_services,
              size: 60, color: const Color(0xFFE2CC01)), // Yellow icon
          const SizedBox(height: 20),
          Text(
            'Login',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFE2CC01), // Yellow text
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(_emailController, 'Enter your email', Icons.email),
          const SizedBox(height: 20),
          _buildTextField(
              _passwordController, 'Enter your password', Icons.lock,
              obscureText: true),
          const SizedBox(height: 10),
          // "Remember Me" checkbox
          Row(
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
                activeColor: const Color(0xFFE2CC01), // Yellow checkbox
              ),
              const Text('Remember Me'),
            ],
          ),
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
              () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => RegisterPage()))),
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
        prefixIcon: Icon(icon, color: const Color(0xFFE2CC01)), // Yellow icon
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: const Color(0xFFE2CC01)), // Yellow border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: const Color(0xFFE2CC01), width: 2), // Yellow border
        ),
      ),
      obscureText: obscureText,
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE2CC01), // Yellow button
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
              color: Colors.white, fontSize: 18), // White text on yellow button
        ),
      ),
    );
  }

  Widget _buildTextButton(String text, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: const Color(0xFFE2CC01), // Yellow text
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// Custom clipper for white curved background
class CurvedWhiteBackgroundClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path()
      ..moveTo(0, size.height * 0.3)
      ..quadraticBezierTo(
          size.width / 2, size.height * 0.1, size.width, size.height * 0.3)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
