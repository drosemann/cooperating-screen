/// First-run setup screen for registering and configuring the current device.
/// The UI collects essential metadata and routes the user into the pairing flow
/// once the local device is ready to connect to peers.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';

class DeviceSetupScreen extends StatefulWidget {
  const DeviceSetupScreen({Key? key}) : super(key: key);

  @override
  State<DeviceSetupScreen> createState() => _DeviceSetupScreenState();
}

class _DeviceSetupScreenState extends State<DeviceSetupScreen> {
  late TextEditingController _deviceNameController;
  String _selectedDeviceType = 'android';
  bool _isLoading = false;
  String? _errorMessage;

  // The setup flow initializes the local form state before the user enters the
  // registration details needed to create the device record in the backend.
  @override
  void initState() {
    super.initState();
    _deviceNameController = TextEditingController();
  }

  @override
  void dispose() {
    _deviceNameController.dispose();
    super.dispose();
  }

  // Registers the current device with the backend after validating the form fields.
  // If the operation succeeds, the app moves straight to the main dashboard and the
  // user can immediately start pairing or creating rooms.
  Future<void> _registerDevice() async {
    if (_deviceNameController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter a device name');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final supabaseService = context.read<SupabaseService>();
    
    final success = await supabaseService.registerDevice(
      deviceName: _deviceNameController.text,
      deviceType: _selectedDeviceType,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to register device. Please try again.';
      });
    }
  }

  // Renders the onboarding UI: a welcome header, device naming inputs, and a
  // registration action that transitions the app into its paired-device workflow.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Device'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.devices,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 32),
              const Text(
                'Welcome to Cooperating Screen',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Let\'s set up your device',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _deviceNameController,
                decoration: InputDecoration(
                  labelText: 'Device Name',
                  hintText: 'e.g., My Phone',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.edit),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedDeviceType,
                decoration: InputDecoration(
                  labelText: 'Device Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.category),
                ),
                items: const [
                  DropdownMenuItem(value: 'android', child: Text('Android')),
                  DropdownMenuItem(value: 'ios', child: Text('iOS')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedDeviceType = value);
                  }
                },
              ),
              const SizedBox(height: 24),
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
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _registerDevice,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
