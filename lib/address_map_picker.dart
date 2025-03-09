import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

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
      print('Error fetching address: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
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
            style: TextStyle(
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
