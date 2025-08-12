import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_library/changepassword.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isButtonDisabled = true;
  int _timerSeconds = 60;
  late Timer _timer;
  bool _otpSent = false;
  bool _isLoading = false;

  void _startResendTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() {
          _timerSeconds--;
        });
      } else {
        setState(() {
          _isButtonDisabled = false;
        });
        _timer.cancel();
      }
    });
  }

  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid email')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final String apiUrl = "${dotenv.env['BASE_URL']}/auth/forgot-password/";
    final response = await http.post(
      Uri.parse(apiUrl),
      body: json.encode({"email": email}),
      headers: {"accept": "application/json", "Content-Type": "application/json"},
    );
    print(response.body);

    setState(() => _isLoading = false);

    if (response.statusCode == 200) {
      setState(() {
        _otpSent = true;
        _isButtonDisabled = true;
        _timerSeconds = 60;
      });
      _startResendTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP sent to your email')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${jsonDecode(response.body)['detail']}')),
      );
    }
  }

  Future<void> _verifyOtp() async {
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid 6-digit OTP')),
      );
      return;
    }

    final String baseurl = "${dotenv.env['BASE_URL']}";

    print("Sending request to: $baseurl/auth/verify-otp");

    final response = await http.post(
      Uri.parse("$baseurl/auth/verify-otp"),
      body: jsonEncode({
        "email": email,
        "otp": otp,
      }),
      headers: {"Content-Type": "application/json"},
    );

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final reset_token = json.decode(response.body)['reset_token'];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Changepass(reset_token: reset_token),
        ),
      );
    } else if (response.statusCode == 307) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Redirect detected, please check server config')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${jsonDecode(response.body)['detail']}')),
      );
    }
  }



  @override
  void dispose() {
    _timer.cancel();
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: const Icon(Icons.email),
                suffixIcon: _emailController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => _emailController.clear(),
                )
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            if (!_otpSent)
              ElevatedButton(
                onPressed: _sendOtp,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Send OTP'),
              ),
            if (_otpSent) ...[
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: 'Enter OTP',
                  counterText: '',
                  border: OutlineInputBorder(),
                ),
              ),
              ElevatedButton(
                onPressed: _verifyOtp,
                child: const Text('Verify OTP'),
              ),
              TextButton(
                onPressed: _isButtonDisabled ? null : _sendOtp,
                child: Text(
                  _isButtonDisabled
                      ? 'Resend OTP in $_timerSeconds seconds'
                      : 'Resend OTP',
                  style: TextStyle(color: _isButtonDisabled ? Colors.grey : Colors.blue),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
