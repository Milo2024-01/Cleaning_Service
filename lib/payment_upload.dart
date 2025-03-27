import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';
import 'package:mime/mime.dart';
import 'package:image/image.dart' as img;
import 'package:google_fonts/google_fonts.dart';
import 'address_map_picker.dart';
import 'email_service.dart';
import 'home_service.dart';

class PaymentUploadScreen extends StatefulWidget {
  final int totalCost;
  final DateTime selectedDate;
  final TimeOfDay? selectedTime;
  final int itemSize;
  final String serviceLabel;

  const PaymentUploadScreen({
    super.key,
    required this.totalCost,
    required this.selectedDate,
    required this.selectedTime,
    required this.itemSize,
    required this.serviceLabel,
  });

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
  List<Map<String, dynamic>> _availableCleaners = [];
  final List<String> _selectedCleanerIds = [];
  bool _isLoadingCleaners = false;

  final Logger _logger = Logger();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _standardizeString(String input) {
    return input.toLowerCase().trim();
  }

  @override
  void initState() {
    super.initState();
    _loadAvailableCleaners();
  }

  Future<void> _loadAvailableCleaners() async {
    setState(() => _isLoadingCleaners = true);
    try {
      final serviceSkill = _standardizeString(widget.serviceLabel);
      
      // Get all available cleaners first
      final snapshot = await _firestore.collection('Cleaner')
          .where('status', isEqualTo: 'available')
          .get();

      // Filter locally for skills match (case insensitive)
      final availableCleaners = snapshot.docs.where((doc) {
        final skills = List<String>.from(doc['skills'] ?? []);
        return skills.any((skill) => 
            _standardizeString(skill) == serviceSkill);
      }).map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Unknown Cleaner',
          'photoUrl': data['photoUrl'],
          'rating': data['rating'] ?? 0.0,
          'status': data['status'] ?? 'unavailable',
        };
      }).toList();

      setState(() => _availableCleaners = availableCleaners);
      
      if (availableCleaners.isEmpty) {
        _logger.w('No cleaners found for service: $serviceSkill');
      }
    } catch (e) {
      _logger.e('Error loading cleaners', error: e);
      _showMessage('Error loading cleaners. Please try again.');
    } finally {
      setState(() => _isLoadingCleaners = false);
    }
  }

  Future<void> _selectCleaner(String cleanerId) async {
    if (_selectedCleanerIds.length >= 2 && !_selectedCleanerIds.contains(cleanerId)) {
      _showMessage('You can only select up to 2 cleaners');
      return;
    }

    setState(() {
      if (_selectedCleanerIds.contains(cleanerId)) {
        _selectedCleanerIds.remove(cleanerId);
      } else {
        _selectedCleanerIds.add(cleanerId);
      }
    });
  }

  void _showMessage(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Widget _buildCleanerSelectionCard() {
    if (_isLoadingCleaners) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_availableCleaners.isEmpty) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No available cleaners for ${widget.serviceLabel}',
            style: GoogleFonts.poppins(fontSize: 16),
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Cleaners (Max 2)',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ..._availableCleaners.map((cleaner) => ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(cleaner['photoUrl'] ?? ''),
                radius: 20,
              ),
              title: Text(cleaner['name']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rating: ${cleaner['rating']?.toStringAsFixed(1) ?? 'N/A'}'),
                  Text(
                    'Status: ${cleaner['status']}',
                    style: TextStyle(
                      color: cleaner['status'] == 'available' 
                          ? Colors.green 
                          : Colors.red,
                    ),
                  ),
                ],
              ),
              trailing: Icon(
                _selectedCleanerIds.contains(cleaner['id']) 
                    ? Icons.check_circle 
                    : Icons.radio_button_unchecked,
                color: _selectedCleanerIds.contains(cleaner['id']) 
                    ? Colors.green 
                    : Colors.grey,
              ),
              onTap: () => _selectCleaner(cleaner['id']),
            )),
          ],
        ),
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
            _buildServiceDetailsCard(),
            const SizedBox(height: 20),
            _buildTotalCostCard(),
            const SizedBox(height: 20),
            _buildCleanerSelectionCard(),
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

  Widget _buildServiceDetailsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Service Details',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Service: ${widget.serviceLabel}',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Date: ${widget.selectedDate.toLocal().toString().split(' ')[0]}',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Time: ${widget.selectedTime?.format(context) ?? "Not selected"}',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
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

    if (_selectedCleanerIds.isEmpty) {
      _showMessage('Please select at least one cleaner');
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
        serviceLabel: widget.serviceLabel,
      );

      await _saveBookingDetails(user.uid, firstName, user.email!);

      _showMessage('Payment proof sent successfully!', success: true);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeServicePage(),
        ),
      );
    } catch (e) {
      _logger.e('Error sending email: $e');
      _showMessage('Error sending email: $e');
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _saveBookingDetails(
      String userId, String firstName, String email) async {
    try {
      final bookingDetails = {
        'userId': userId,
        'firstName': firstName,
        'email': email,
        'serviceLabel': _standardizeString(widget.serviceLabel),
        'displayServiceLabel': widget.serviceLabel,
        'selectedDate': widget.selectedDate.toIso8601String(),
        'selectedTime': widget.selectedTime?.format(context),
        'itemSize': widget.itemSize,
        'totalCost': widget.totalCost,
        'address': _selectedAddress,
        'location': GeoPoint(
          _selectedLocation!.latitude,
          _selectedLocation!.longitude,
        ),
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
        'assignedCleaners': _selectedCleanerIds,
        'paymentProof': _fileName,
      };

      await _firestore.collection('bookings').add(bookingDetails);
      _logger.i('Booking details saved to Firestore');
    } catch (e) {
      _logger.e('Error saving booking details: $e');
      throw Exception('Failed to save booking details: $e');
    }
  }

  String _getMimeType(String? fileName) {
    return fileName != null
        ? lookupMimeType(fileName) ?? 'application/octet-stream'
        : 'application/octet-stream';
  }
}