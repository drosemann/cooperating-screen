/// Confirmation step of the pairing workflow.
/// This screen helps the user verify that the remote device is the intended peer
/// before the session becomes active and the two endpoints are linked.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/pairing_service.dart';
import '../services/supabase_service.dart';

class PairingConfirmationScreen extends StatefulWidget {
  const PairingConfirmationScreen({Key? key}) : super(key: key);

  @override
  State<PairingConfirmationScreen> createState() =>
      _PairingConfirmationScreenState();
}

class _PairingConfirmationScreenState extends State<PairingConfirmationScreen> {
  late TextEditingController _codeController;
  bool _isLoading = false;
  String? _errorMessage;
  int _remainingTime = 30;
  late DateTime _expiryTime;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    _expiryTime = DateTime.now().add(const Duration(seconds: 30));
    _startCountdown();
  }

  // Starts the countdown that limits how long the pairing code remains valid. This
  // prevents stale or abandoned trust requests from lingering indefinitely.
  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;

      setState(() {
        _remainingTime = _expiryTime.difference(DateTime.now()).inSeconds;
      });

      if (_remainingTime <= 0) {
        if (mounted) {
          _showTimeoutDialog();
        }
        return false;
      }
      return true;
    });
  }

  void _showTimeoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Pairing Expired'),
        content: const Text('The pairing request has expired. Please try again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Verifies the pairing code entered by the user against the active session and
  // only finalizes the trust relationship once the code is valid and still within
  // the expiration window.
  Future<void> _confirmPairing() async {
    if (_codeController.text.isEmpty || _codeController.text.length != 6) {
      setState(() => _errorMessage = 'Please enter a valid 6-digit code');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final pairingService = context.read<PairingService>();

      // In a real implementation, you would get the session ID from the previous step
      // For now, this is a placeholder
      final success = await pairingService.confirmPairing(
        sessionId: 'session_id_from_request',
        confirmedPairingCode: _codeController.text,
      );

      if (!mounted) return;

      if (success) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Pairing Successful!'),
            content: const Text('Device paired successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed('/home');
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Invalid code. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Pairing'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            Icon(
              Icons.devices_other,
              size: 80,
              color: Colors.blue.shade300,
            ),
            const SizedBox(height: 32),
            const Text(
              'Enter Pairing Code',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check the remote device for the 6-digit code',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Countdown timer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.schedule, color: Colors.blue.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Expires in $_remainingTime seconds',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Code input
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: '6-Digit Code',
                hintText: '000000',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.vpn_key),
                counterText: '${_codeController.text.length}/6',
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                letterSpacing: 8,
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: 24),
            // Error message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade900),
                ),
              ),
            const SizedBox(height: 24),
            // Confirm button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed:
                    _isLoading || _codeController.text.length != 6 ? null : _confirmPairing,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Confirm Pairing'),
              ),
            ),
            const SizedBox(height: 16),
            // Cancel button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
