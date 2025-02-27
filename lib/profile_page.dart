import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String _selectedGender = 'Male'; // Default selected gender
  bool _isEditing = false;

  // Fetch user data from Firestore
  Future<void> _getUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      // Populate the fields with the current data
      _firstNameController.text = userDoc['first_name'] ?? '';
      _lastNameController.text = userDoc['last_name'] ?? '';
      _selectedGender = userDoc['gender'] ?? 'Male'; // Update gender field
      _contactController.text = userDoc['contact'] ?? '';
      _addressController.text = userDoc['address'] ?? '';
    }
  }

  // Update user data in Firestore
  Future<void> _updateUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'gender': _selectedGender, // Save the selected gender
        'contact': _contactController.text,
        'address': _addressController.text,
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile updated successfully!")));
      setState(() {
        _isEditing = false; // Set editing mode off after update
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserData(); // Get the user data when the profile page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor:
            Colors.yellow.shade700, // Use yellow for app bar background
        actions: [
          _isEditing
              ? IconButton(
                  icon: Icon(Icons.save),
                  onPressed: _updateUserData,
                )
              : IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    setState(() {
                      _isEditing = true; // Enable editing mode
                    });
                  },
                )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.yellow.shade200, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // First Name Field
              _buildTextFormField(
                controller: _firstNameController,
                label: 'First Name',
              ),
              SizedBox(height: 16),
              // Last Name Field
              _buildTextFormField(
                controller: _lastNameController,
                label: 'Last Name',
              ),
              SizedBox(height: 16),
              // Gender Field (Dropdown for Male/Female)
              _buildGenderDropdown(),
              SizedBox(height: 16),
              // Contact Field
              _buildTextFormField(
                controller: _contactController,
                label: 'Contact',
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),
              // Address Field
              _buildTextFormField(
                controller: _addressController,
                label: 'Address',
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build text fields
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      enabled: _isEditing, // Allow editing if in edit mode
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.yellow.shade700),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.yellow.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.yellow.shade700, width: 2),
        ),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
    );
  }

  // Gender dropdown method
  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      items: ['Male', 'Female']
          .map((gender) => DropdownMenuItem<String>(
                value: gender,
                child: Text(gender),
              ))
          .toList(),
      onChanged: _isEditing
          ? (String? newValue) {
              setState(() {
                _selectedGender = newValue!;
              });
            }
          : null, // Disable dropdown when not in edit mode
      decoration: InputDecoration(
        labelText: 'Gender',
        labelStyle: TextStyle(color: Colors.yellow.shade700),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.yellow.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.yellow.shade700, width: 2),
        ),
      ),
    );
  }
}
