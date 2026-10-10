/// WebRTC call screen responsible for the active media session between peers.
/// It manages the live stream experience, call controls, and the visual state of
/// an in-progress audio or video exchange.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/webrtc_service.dart';
import '../providers/connection_state.dart';
import '../widgets/video_widgets.dart';

class WebRTCCallScreen extends StatefulWidget {
  final String remoteDeviceName;
  final String remoteDeviceSerial;

  const WebRTCCallScreen({
    Key? key,
    required this.remoteDeviceName,
    required this.remoteDeviceSerial,
  }) : super(key: key);

  @override
  State<WebRTCCallScreen> createState() => _WebRTCCallScreenState();
}

class _WebRTCCallScreenState extends State<WebRTCCallScreen> {
  bool _isFullscreenLocal = false;
  late ConnectionState _connectionState;

  @override
  void initState() {
    super.initState();
    _connectionState = context.read<ConnectionState>();
  }

  // Confirms the call shutdown so the user has a final chance to cancel before the
  // active WebRTC session is dismissed from the UI.
  void _endCall() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Call'),
        content: const Text('Do you want to end this call?'),
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
            child: const Text('End Call'),
          ),
        ],
      ),
    );
  }

  // Renders the live call interface, including the remote stream area, top status
  // strip, and call controls that manage microphone, camera, and end-of-call actions.
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _endCall();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Consumer<ConnectionState>(
          builder: (context, connectionState, _) {
            return Stack(
              children: [
                // Video area
                if (connectionState.webRtcService?.remoteRenderer != null)
                  PictureInPictureWidget(
                    remoteRenderer:
                        connectionState.webRtcService!.remoteRenderer!,
                    localRenderer:
                        connectionState.webRtcService!.localRenderer!,
                    isFullscreenLocal: _isFullscreenLocal,
                    onSwapClick: () {
                      setState(
                        () => _isFullscreenLocal = !_isFullscreenLocal,
                      );
                    },
                  )
                else
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.phone,
                          size: 64,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Connecting to ${widget.remoteDeviceName}...',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 32),
                        const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.blue),
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
                              connectionState.isConnected
                                  ? 'Connected'
                                  : 'Connecting...',
                              style: TextStyle(
                                color: connectionState.isConnected
                                    ? Colors.green
                                    : Colors.orange,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        if (connectionState.errorMessage != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade900,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              connectionState.errorMessage!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
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
                        // Call duration (placeholder)
                        const Text(
                          '00:45',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Control buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Microphone toggle
                            FloatingActionButton(
                              onPressed: () {
                                connectionState.toggleAudio(
                                  !connectionState.isAudioEnabled,
                                );
                              },
                              backgroundColor: connectionState.isAudioEnabled
                                  ? Colors.blue
                                  : Colors.red,
                              child: Icon(
                                connectionState.isAudioEnabled
                                    ? Icons.mic
                                    : Icons.mic_off,
                                color: Colors.white,
                              ),
                            ),
                            // Camera toggle
                            FloatingActionButton(
                              onPressed: () {
                                connectionState.toggleVideo(
                                  !connectionState.isVideoEnabled,
                                );
                              },
                              backgroundColor: connectionState.isVideoEnabled
                                  ? Colors.blue
                                  : Colors.red,
                              child: Icon(
                                connectionState.isVideoEnabled
                                    ? Icons.videocam
                                    : Icons.videocam_off,
                                color: Colors.white,
                              ),
                            ),
                            // Switch camera
                            FloatingActionButton(
                              onPressed: () {
                                connectionState.switchCamera();
                              },
                              backgroundColor: Colors.blue,
                              child: const Icon(
                                Icons.flip_camera_ios,
                                color: Colors.white,
                              ),
                            ),
                            // End call
                            FloatingActionButton(
                              onPressed: _endCall,
                              backgroundColor: Colors.red,
                              child: const Icon(
                                Icons.call_end,
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
