import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';
import 'package:mime/mime.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart'; // Optional for modern fonts

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Payment Proof Upload',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme), // Modern font
      ),
      home: const PaymentUploadScreen(totalCost: 3120),
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
  Uint8List? _fileBytes;
  String? _fileName;
  bool _isSending = false;
  bool _isPickingFile = false;
  LatLng? _selectedLocation;
  String? _selectedAddress;

  final Logger _logger = Logger();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _pickFile() async {
    setState(() => _isPickingFile = true);

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null) {
        final file = result.files.first;
        final String extension = file.name.split('.').last.toLowerCase();

        if (!['jpg', 'jpeg', 'png'].contains(extension)) {
          _showMessage('Please select a valid image file (JPG, JPEG, PNG).');
          return;
        }

        if (file.size > 5 * 1024 * 1024) {
          _showMessage('File size should be less than 5 MB.');
          return;
        }

        setState(() {
          if (kIsWeb) {
            _fileBytes = file.bytes;
            _fileName = file.name;
          } else {
            _selectedFile = File(file.path!);
            _fileName = file.name;
          }
        });

        _showMessage('File selected successfully!');
      } else {
        _showMessage('File selection canceled.');
      }
    } catch (e) {
      _logger.e('Error picking file: $e');
      _showMessage('Error picking file: $e');
    } finally {
      setState(() => _isPickingFile = false);
    }
  }

  Future<void> _sendEmail() async {
    if (_selectedFile == null && _fileBytes == null) {
      _showMessage('Please upload proof of payment');
      return;
    }

    if (_selectedLocation == null || _selectedAddress == null) {
      _showMessage('Please select a location and enter an address');
      return;
    }

    setState(() => _isSending = true);

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

      final img.Image? image = img.decodeImage(fileBytes);
      if (image != null) {
        fileBytes = Uint8List.fromList(img.encodeJpg(image, quality: 50));
      }

      final String base64File = base64Encode(fileBytes);

      if (base64File.length > 50 * 1024) {
        throw Exception('File size exceeds 50 KB after compression');
      }

      final User? user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      final String firstName = userDoc.get('first_name') ?? 'User';

      await EmailService.sendEmail(
        totalCost: widget.totalCost,
        fileBase64: base64File,
        fileName: _fileName ?? 'payment_proof.jpg',
        fileMimeType: fileMimeType,
        email: user.email!,
        firstName: firstName,
        address: _selectedAddress!,
        location: _selectedLocation!,
      );

      _showMessage('Payment proof sent successfully!', success: true);
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } catch (e) {
      _logger.e('Error sending email: $e');
      _showMessage('Error sending email: $e');
    } finally {
      setState(() => _isSending = false);
    }
  }

  String _getMimeType(String? fileName) {
    return fileName != null
        ? lookupMimeType(fileName) ?? 'application/octet-stream'
        : 'application/octet-stream';
  }

  void _showMessage(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proof Payment'),
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTotalCostCard(),
            const SizedBox(height: 20),
            _buildFileUploadCard(),
            const SizedBox(height: 20),
            AddressMapPicker(
              onAddressSelected: (LatLng location, String address) {
                setState(() {
                  _selectedLocation = location;
                  _selectedAddress = address;
                });
              },
            ),
            const SizedBox(height: 20),
            _buildSendButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCostCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Total Cost',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '₱${widget.totalCost}',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileUploadCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              Text(
                'No file selected',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isPickingFile ? null : _pickFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Choose File',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return ElevatedButton(
      onPressed: (_isSending || _isPickingFile) ? null : _sendEmail,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: _isSending
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(
              'Send Payment Proof',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
    );
  }
}

class AddressMapPicker extends StatefulWidget {
  final Function(LatLng, String) onAddressSelected;

  const AddressMapPicker({super.key, required this.onAddressSelected});

  @override
  _AddressMapPickerState createState() => _AddressMapPickerState();
}

class _AddressMapPickerState extends State<AddressMapPicker> {
  final MapController _mapController = MapController();
  final TextEditingController _addressController = TextEditingController();
  LatLng? _selectedLocation;

  Future<void> _fetchAddress(LatLng location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        String address =
            '${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}';
        _addressController.text = address;
      } else {
        _addressController.text = 'Address not found';
      }
    } catch (e) {
      _addressController.text = 'Failed to fetch address';
      if (kDebugMode) {
        print('Error fetching address: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200, // Smaller map height
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: LatLng(14.5995, 120.9842),
              zoom: 13.0,
              onTap: (_, LatLng latlng) async {
                setState(() {
                  _selectedLocation = latlng;
                });
                await _fetchAddress(latlng);
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  if (_selectedLocation != null)
                    Marker(
                      point: _selectedLocation!,
                      builder: (ctx) =>
                          const Icon(Icons.location_on, color: Colors.red),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _addressController,
          decoration: InputDecoration(
            labelText: 'Enter your address',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            if (_selectedLocation != null &&
                _addressController.text.isNotEmpty) {
              widget.onAddressSelected(
                  _selectedLocation!, _addressController.text);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('Please select a location and enter an address')),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(
            'Confirm Address',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class EmailService {
  static const String serviceId = 'service_2329r2d';
  static const String templateId = 'template_4ggkiqv';
  static const String userId = 'iftJdd3HapoZq9bzR';

  static Future<void> sendEmail({
    required int totalCost,
    required String fileBase64,
    required String fileName,
    required String fileMimeType,
    required String email,
    required String firstName,
    required String address,
    required LatLng location,
  }) async {
    final requestBody = {
      'service_id': serviceId,
      'template_id': templateId,
      'user_id': userId,
      'template_params': {
        'totalCost': totalCost.toString(),
        'fileBase64': fileBase64,
        'fileName': fileName,
        'fileMimeType': fileMimeType,
        'email': email,
        'first_name': firstName,
        'address': address,
        'latitude': location.latitude.toString(),
        'longitude': location.longitude.toString(),
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
