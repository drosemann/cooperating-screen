/// Screen-share session screen for streaming one device's display to another.
/// It composes the media pipeline and runtime controls needed to start,
/// monitor, and stop remote sharing from the current device.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/webrtc_service.dart';
import '../services/screen_capture_service.dart';
import '../providers/connection_state.dart';
import '../widgets/video_widgets.dart';

class ScreenShareScreen extends StatefulWidget {
  final String remoteDeviceName;
  final String remoteDeviceSerial;

  const ScreenShareScreen({
    Key? key,
    required this.remoteDeviceName,
    required this.remoteDeviceSerial,
  }) : super(key: key);

  @override
  State<ScreenShareScreen> createState() => _ScreenShareScreenState();
}

class _ScreenShareScreenState extends State<ScreenShareScreen> {
  bool _isScreenSharing = false;
  bool _showRemoteScreen = false;
  late ConnectionState _connectionState;

  @override
  void initState() {
    super.initState();
    _connectionState = context.read<ConnectionState>();
  }

  // Starts or stops the screen-capture workflow and updates the UI state so the
  // user sees whether the current device is actively sharing its display.
  Future<void> _toggleScreenShare() async {
    if (_isScreenSharing) {
      final success = await ScreenCaptureService.stopScreenCapture();
      if (success) {
        setState(() => _isScreenSharing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Screen sharing stopped')),
        );
      }
    } else {
      final result = await ScreenCaptureService.startScreenCapture();
      if (result != null) {
        setState(() => _isScreenSharing = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Screen sharing started')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to start screen sharing')),
        );
      }
    }
  }

  // Confirms whether the user wants to terminate the current sharing session, as
  // screen sharing is a long-lived operation that should be explicitly stopped.
  void _endScreenShare() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Screen Share'),
        content: const Text('Do you want to end this screen share session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('End'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _endScreenShare();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Consumer<ConnectionState>(
          builder: (context, connectionState, _) {
            return Stack(
              children: [
                // Main content area
                Center(
                  child: _showRemoteScreen &&
                          connectionState.webRtcService?.remoteRenderer != null
                      ? RemoteVideoWidget(
                          remoteRenderer:
                              connectionState.webRtcService!.remoteRenderer!,
                          onTap: () {
                            setState(
                              () => _showRemoteScreen = !_showRemoteScreen,
                            );
                          },
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isScreenSharing
                                  ? Icons.screen_share
                                  : Icons.screen_share_off,
                              size: 64,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _isScreenSharing
                                  ? 'Sharing your screen with ${widget.remoteDeviceName}'
                                  : 'Ready to share screen',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            if (!_isScreenSharing)
                              ElevatedButton.icon(
                                onPressed: _toggleScreenShare,
                                icon: const Icon(Icons.screen_share),
                                label: const Text('Start Sharing'),
                              ),
                          ],
                        ),
                ),
                // Top status bar
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.black87,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.remoteDeviceName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isScreenSharing
                                  ? 'Screen Sharing Active'
                                  : 'Ready',
                              style: TextStyle(
                                color: _isScreenSharing
                                    ? Colors.green
                                    : Colors.orange,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade900,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.fiber_manual_record,
                                  color: Colors.red, size: 8),
                              SizedBox(width: 6),
                              Text(
                                'LIVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Bottom controls
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.black87,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        if (_showRemoteScreen)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              'Tap to hide remote view',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // View remote screen
                            FloatingActionButton(
                              onPressed: () {
                                setState(
                                  () => _showRemoteScreen = !_showRemoteScreen,
                                );
                              },
                              backgroundColor: _showRemoteScreen
                                  ? Colors.blue
                                  : Colors.blue.shade700,
                              child: Icon(
                                _showRemoteScreen
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white,
                              ),
                            ),
                            // Start/Stop screen share
                            FloatingActionButton(
                              onPressed: _toggleScreenShare,
                              backgroundColor: _isScreenSharing
                                  ? Colors.green
                                  : Colors.orange,
                              child: Icon(
                                _isScreenSharing
                                    ? Icons.stop_circle
                                    : Icons.play_circle,
                                color: Colors.white,
                              ),
                            ),
                            // End session
                            FloatingActionButton(
                              onPressed: _endScreenShare,
                              backgroundColor: Colors.red,
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
