import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email;
  final String generatedOTP;
  final Function(String) onVerified;
  final Function() onResend;

  const OTPVerificationScreen({
    super.key,
    required this.email,
    required this.generatedOTP,
    required this.onVerified,
    required this.onResend,
  });

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
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
                  activeColor: Theme.of(context).primaryColor,
                  selectedColor: Theme.of(context).primaryColor,
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
