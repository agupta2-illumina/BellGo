import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';

enum PhoneEnrollmentStep {
  enterPhone,
  verifyOtp,
  verified,
}

class PhoneEnrollmentScreen extends ConsumerStatefulWidget {
  const PhoneEnrollmentScreen({super.key});

  @override
  ConsumerState<PhoneEnrollmentScreen> createState() =>
      _PhoneEnrollmentScreenState();
}

class _PhoneEnrollmentScreenState extends ConsumerState<PhoneEnrollmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  PhoneEnrollmentStep _currentStep = PhoneEnrollmentStep.enterPhone;
  String _verificationId = '';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Phone Number'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_currentStep == PhoneEnrollmentStep.enterPhone)
                _buildPhoneStep()
              else if (_currentStep == PhoneEnrollmentStep.verifyOtp)
                _buildOtpStep()
              else
                _buildVerifiedStep(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.phone_android,
          size: 64,
          color: Color(0xFF5B21B6),
        ),
        const SizedBox(height: 24),
        Text(
          'Enter your phone number',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'We\'ll send you a verification code via SMS',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
        ),
        const SizedBox(height: 32),
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            hintText: '(555) 123-4567',
            prefixText: '+1 ',
            prefixIcon: Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your phone number';
            }
            if (value.length != 10) {
              return 'Please enter a valid 10-digit phone number';
            }
            return null;
          },
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.error, color: Color(0xFFEF4444), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Color(0xFFEF4444)),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _isLoading ? null : _sendOTP,
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Send Code'),
        ),
      ],
    );
  }

  Widget _buildOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.message,
          size: 64,
          color: Color(0xFF5B21B6),
        ),
        const SizedBox(height: 24),
        Text(
          'Enter verification code',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'We sent a 6-digit code to +1 ${_formatPhoneNumber(_phoneController.text)}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
        ),
        const SizedBox(height: 32),
        TextFormField(
          controller: _otpController,
          decoration: const InputDecoration(
            labelText: 'Verification Code',
            hintText: '000000',
            prefixIcon: Icon(Icons.pin),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 8,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the verification code';
            }
            if (value.length != 6) {
              return 'Please enter the complete 6-digit code';
            }
            return null;
          },
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.error, color: Color(0xFFEF4444), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Color(0xFFEF4444)),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        Center(
          child: TextButton(
            onPressed: _isLoading ? null : _resendOTP,
            child: const Text('Resend Code'),
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _isLoading ? null : _verifyOTP,
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Verify'),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: _isLoading
              ? null
              : () {
                  setState(() {
                    _currentStep = PhoneEnrollmentStep.enterPhone;
                    _errorMessage = null;
                    _otpController.clear();
                  });
                },
          child: const Text('Change Number'),
        ),
      ],
    );
  }

  Widget _buildVerifiedStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(
          Icons.check_circle,
          size: 80,
          color: Color(0xFF10B981),
        ),
        const SizedBox(height: 24),
        Text(
          'Phone Verified!',
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'You\'ll receive SMS notifications at:\n+1 ${_formatPhoneNumber(_phoneController.text)}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => context.pop(),
          child: const Text('Done'),
        ),
      ],
    );
  }

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final phoneVerificationService =
          ref.read(phoneVerificationServiceProvider);
      final phoneNumber = '+1${_phoneController.text}';

      _verificationId = await phoneVerificationService.sendOTP(phoneNumber);

      setState(() {
        _currentStep = PhoneEnrollmentStep.verifyOtp;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to send code. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyOTP() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final phoneVerificationService =
          ref.read(phoneVerificationServiceProvider);

      final isValid = await phoneVerificationService.verifyOTP(
        _verificationId,
        _otpController.text,
      );

      if (isValid) {
        final phoneNumber = '+1${_phoneController.text}';
        await phoneVerificationService.savePhoneNumber(phoneNumber);

        final smsService = ref.read(smsNotificationServiceProvider);
        await smsService.sendTestSms(phoneNumber);

        setState(() {
          _currentStep = PhoneEnrollmentStep.verified;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Invalid code. Please try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Verification failed. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _resendOTP() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final phoneVerificationService =
          ref.read(phoneVerificationServiceProvider);
      final phoneNumber = '+1${_phoneController.text}';

      _verificationId = await phoneVerificationService.resendOTP(phoneNumber);

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Code resent successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to resend code. Please try again.';
        _isLoading = false;
      });
    }
  }

  String _formatPhoneNumber(String phone) {
    if (phone.length == 10) {
      return '(${phone.substring(0, 3)}) ${phone.substring(3, 6)}-${phone.substring(6)}';
    }
    return phone;
  }
}
