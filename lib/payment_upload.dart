import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore for user data
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage for file uploads
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart'; // For logging errors
import 'package:mime/mime.dart'; // For MIME type detection

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Payment Proof Upload',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: PaymentUploadScreen(totalCost: 3120),
    );
  }
}

class PaymentUploadScreen extends StatefulWidget {
  final int totalCost;

  const PaymentUploadScreen({super.key, required this.totalCost});

  @override
  _PaymentUploadScreenState createState() => _PaymentUploadScreenState();
}

class _PaymentUploadScreenState extends State<PaymentUploadScreen> {
  File? _selectedFile;
  Uint8List? _fileBytes; // Store bytes for Web
  String? _fileName; // Store file name
  bool _isSending = false;
  bool _isPickingFile = false;

  final Logger _logger = Logger(); // Logger for error handling
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> _pickFile() async {
    setState(() {
      _isPickingFile = true; // Show loading indicator while picking file
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true, // Important for Web (gets bytes instead of path)
      );

      if (result != null) {
        final file = result.files.first;

        // Validate file type
        if (!file.name.toLowerCase().endsWith('.jpg') &&
            !file.name.toLowerCase().endsWith('.jpeg') &&
            !file.name.toLowerCase().endsWith('.png')) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Please select a valid image file (JPG, JPEG, PNG).')),
          );
          return;
        }

        // Validate file size (5 MB limit)
        if (file.size > 5 * 1024 * 1024) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('File size should be less than 5 MB.')),
          );
          return;
        }

        if (kIsWeb) {
          // Web: Store file bytes & name (No File path)
          setState(() {
            _fileBytes = file.bytes;
            _fileName = file.name;
          });
        } else {
          // Mobile: Use file path
          setState(() {
            _selectedFile = File(file.path!);
            _fileName = file.name;
          });
        }

        // Show success message
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File selected successfully!')),
        );
      } else {
        // User canceled file selection
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File selection canceled.')),
        );
      }
    } catch (e) {
      // Log and show error
      _logger.e('Error picking file: $e');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    } finally {
      setState(() {
        _isPickingFile = false; // Hide loading indicator
      });
    }
  }

  Future<String> uploadFileToFirebaseStorage(
      Uint8List fileBytes, String fileName) async {
    final Reference storageRef =
        _storage.ref().child('payment_proofs/$fileName');
    final UploadTask uploadTask = storageRef.putData(fileBytes);
    final TaskSnapshot snapshot = await uploadTask;
    final String downloadURL = await snapshot.ref.getDownloadURL();
    return downloadURL;
  }

  Future<void> _sendEmail() async {
    if (_selectedFile == null && _fileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload proof of payment')),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      Uint8List fileBytes;
      String fileMimeType;

      if (kIsWeb && _fileBytes != null) {
        fileBytes = _fileBytes!;
        fileMimeType = _getMimeType(_fileName);
      } else if (_selectedFile != null) {
        fileBytes = await _selectedFile!.readAsBytes();
        fileMimeType = _getMimeType(_fileName);
      } else {
        throw Exception('No file selected');
      }

      // Upload file to Firebase Storage
      final String fileUrl =
          await uploadFileToFirebaseStorage(fileBytes, _fileName!);

      // Fetch user data from Firebase
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Fetch the user's first name from Firestore
      final DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      final String firstName = userDoc.get('first_name') ?? 'User';

      // Send email using EmailService
      await EmailService.sendEmail(
        totalCost: widget.totalCost,
        fileUrl: fileUrl, // Send the file URL instead of Base64
        fileName: _fileName ?? 'payment_proof.jpg',
        fileMimeType: fileMimeType,
        email: user.email!, // Email from Firebase Authentication
        firstName: firstName, // First name from Firestore
      );

      // Show success message and navigate back
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment proof sent successfully!')),
      );
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } catch (e) {
      // Log and show error
      _logger.e('Error sending email: $e');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending email: $e')),
      );
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  // Helper function to get MIME type based on file extension
  String _getMimeType(String? fileName) {
    if (fileName == null) return 'application/octet-stream'; // Default fallback
    final mimeType = lookupMimeType(fileName);
    return mimeType ?? 'application/octet-stream';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Proof Payment',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Total Cost Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Total Cost',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '₱${widget.totalCost}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // File Upload Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (_isPickingFile)
                      const CircularProgressIndicator()
                    else if (kIsWeb && _fileBytes != null)
                      Image.memory(_fileBytes!, height: 200)
                    else if (!kIsWeb && _selectedFile != null)
                      Image.file(_selectedFile!, height: 200)
                    else
                      const Text(
                        'No file selected',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 109, 108, 108),
                        ),
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isPickingFile ? null : _pickFile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Choose File',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Send Payment Proof Button
            ElevatedButton(
              onPressed: (_isSending || _isPickingFile) ? null : _sendEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isSending
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Send Payment Proof',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmailService {
  static const String serviceId = 'service_2329r2d';
  static const String templateId = 'template_4ggkiqv';
  static const String userId = 'iftJdd3HapoZq9bzR';

  static Future<void> sendEmail({
    required int totalCost,
    required String fileUrl,
    required String fileName,
    required String fileMimeType,
    required String email,
    required String firstName,
  }) async {
    final requestBody = {
      'service_id': serviceId,
      'template_id': templateId,
      'user_id': userId,
      'template_params': {
        'totalCost': totalCost.toString(),
        'fileUrl': fileUrl, // Send the file URL
        'fileName': fileName,
        'fileMimeType': fileMimeType,
        'email': email,
        'first_name': firstName,
      },
    };

    final response = await http.post(
      Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send email: ${response.body}');
    }
  }
}
