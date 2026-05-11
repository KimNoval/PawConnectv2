import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _emailFound = false;
  bool _isLoading = false;

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _checkEmail() async {
    setState(() => _isLoading = true);
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showErrorDialog('Please enter your email');
      setState(() => _isLoading = false);
      return;
    }

    final userData = await _authService.getUserDataByEmail(email);
    if (userData == null) {
      _showErrorDialog('No account found with this email');
      setState(() => _isLoading = false);
      return;
    }

    setState(() {
      _emailFound = true;
      _isLoading = false;
    });
  }

  Future<void> _resetPassword() async {
    setState(() => _isLoading = true);
    final newPass = _newPasswordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    if (newPass.isEmpty || confirmPass.isEmpty) {
      _showErrorDialog('Please fill in both password fields');
      setState(() => _isLoading = false);
      return;
    }

    if (newPass != confirmPass) {
      _showErrorDialog('Passwords do not match');
      setState(() => _isLoading = false);
      return;
    }

    if (newPass.length < 6) {
      _showErrorDialog('Password must be at least 6 characters');
      setState(() => _isLoading = false);
      return;
    }

    final result = await _authService.resetPassword(
      _emailController.text.trim(),
      newPass,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Success'),
          content: const Text(
            'Your password has been reset. You can now log in with your new password.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      _showErrorDialog(result['message'] ?? 'Failed to reset password');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Forgot Password',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              _emailFound ? 'Create a new password' : 'Reset your password',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _emailFound
                  ? 'Enter a new password for your account'
                  : 'Enter your email address and we will help you reset your password',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            if (!_emailFound)
              CustomTextField(
                controller: _emailController,
                hintText: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
            if (_emailFound) ...[
              const SizedBox(height: 16),
              CustomTextField(
                controller: _newPasswordController,
                hintText: 'New Password',
                isPassword: true,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _confirmPasswordController,
                hintText: 'Confirm Password',
                isPassword: true,
              ),
            ],
            const SizedBox(height: 32),
            CustomButton(
              text: _isLoading
                  ? 'Please wait...'
                  : (_emailFound ? 'Reset Password' : 'Continue'),
              onPressed: _isLoading
                  ? () {}
                  : (_emailFound ? _resetPassword : _checkEmail),
            ),
          ],
        ),
      ),
    );
  }
}
