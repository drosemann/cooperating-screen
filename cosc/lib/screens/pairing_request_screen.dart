/// Pairing request screen that presents an incoming or outgoing handshake request.
/// It exposes the verification state, code entry, and follow-up actions needed to
/// accept or reject a remote device request.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/pairing_service.dart';
import '../services/supabase_service.dart';
import '../utils/security_utils.dart';

class PairingRequestScreen extends StatefulWidget {
  const PairingRequestScreen({Key? key}) : super(key: key);

  @override
  State<PairingRequestScreen> createState() => _PairingRequestScreenState();
}

class _PairingRequestScreenState extends State<PairingRequestScreen> {
  late TextEditingController _remoteSerialController;
  late TextEditingController _passwordController;
  bool _showPassword = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _remoteSerialController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _remoteSerialController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Starts the pairing handshake by validating the remote serial and password, and
  // then submitting the pairing request to the backend. This is the first step in
  // establishing a trusted device relationship before any media session is created.
  Future<void> _initiatePariring() async {
    // Validate input
    if (_remoteSerialController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter the remote device serial');
      return;
    }

    if (_passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter a pairing password');
      return;
    }

    if (!SecurityUtils.isPasswordStrong(_passwordController.text)) {
      setState(() {
        _errorMessage =
            'Password must be at least 8 characters with uppercase, lowercase, and numbers';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final supabaseService = context.read<SupabaseService>();
      final pairingService = context.read<PairingService>();
      final localSerial = supabaseService.getDeviceSerial();

      if (localSerial == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Device not registered. Please set up device first.';
        });
        return;
      }

      final success = await pairingService.requestPairing(
        localDeviceSerial: localSerial,
        remoteDeviceSerial: _remoteSerialController.text.toUpperCase(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        setState(() {
          _isLoading = false;
          _successMessage = 'Pairing request sent! Waiting for confirmation...';
        });

        // Navigate to confirmation screen after 2 seconds
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/pairing-confirm');
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to send pairing request. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  // Renders the pairing form and shows validation feedback so the user can confirm
  // the target device and password before triggering the trust request.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pair Device'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter Remote Device Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ask the other device for their serial number',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            // Device Serial Input
            TextField(
              controller: _remoteSerialController,
              decoration: InputDecoration(
                labelText: 'Remote Device Serial',
                hintText: 'e.g., ABC123XYZ9',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.devices),
                counterText: '${_remoteSerialController.text.length}/12',
              ),
              maxLength: 12,
              textCapitalization: TextCapitalization.characters,
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: 20),
            // Password Input
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Pairing Password',
                hintText: 'Min 8 chars, uppercase, lowercase, number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() => _showPassword = !_showPassword);
                  },
                ),
              ),
              obscureText: !_showPassword,
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: 8),
            // Password strength indicator
            if (_passwordController.text.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      SecurityUtils.isPasswordStrong(_passwordController.text)
                          ? Icons.check_circle
                          : Icons.error,
                      color: SecurityUtils.isPasswordStrong(
                        _passwordController.text,
                      )
                          ? Colors.green
                          : Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      SecurityUtils.isPasswordStrong(_passwordController.text)
                          ? 'Strong password'
                          : 'Weak password',
                      style: TextStyle(
                        fontSize: 12,
                        color: SecurityUtils.isPasswordStrong(
                          _passwordController.text,
                        )
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ],
                ),
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
            // Success message
            if (_successMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _successMessage!,
                  style: TextStyle(color: Colors.green.shade900),
                ),
              ),
            const SizedBox(height: 24),
            // Send button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ||
                        _remoteSerialController.text.isEmpty ||
                        _passwordController.text.isEmpty
                    ? null
                    : _initiatePariring,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Send Pairing Request'),
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
