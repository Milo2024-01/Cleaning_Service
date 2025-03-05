import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

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
        if (kIsWeb) {
          // Web: Store file bytes & name (No File path)
          setState(() {
            _fileBytes = result.files.first.bytes;
            _fileName = result.files.first.name;
          });
        } else {
          // Mobile: Use file path
          setState(() {
            _selectedFile = File(result.files.single.path!);
          });
        }

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File selected successfully!')),
        );
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File selection canceled.')),
        );
      }
    } catch (e) {
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

    if (kIsWeb) {
      // Web: Show a message that email sending is not supported
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Email sending is not supported on the web.')),
      );
      setState(() {
        _isSending = false;
      });
      return;
    }

    // Mobile: Use the mailer package to send the email
    final smtpServer = gmail('your-email@gmail.com', 'your-app-password');

    final message = Message()
      ..from = Address('your-email@gmail.com', 'Cleaning Service')
      ..recipients.add('laurapresley4@gmail.com') // Admin email
      ..subject = 'Payment Proof - Cleaning Service'
      ..text =
          'Attached is the proof of payment. Total Cost: ₱${widget.totalCost}';

    if (_selectedFile != null) {
      message.attachments.add(FileAttachment(_selectedFile!));
    }

    try {
      await send(message, smtpServer);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment proof sent successfully!')),
      );
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Upload Payment Proof',
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
                      Text(
                        'File selected: $_fileName',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade800,
                        ),
                      )
                    else if (!kIsWeb && _selectedFile != null)
                      Image.file(_selectedFile!, height: 200)
                    else
                      const Text(
                        'No file selected',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 117, 115, 115),
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
              onPressed: _isSending ? null : _sendEmail,
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
