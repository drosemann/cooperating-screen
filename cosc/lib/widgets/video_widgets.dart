/// Reusable video widgets that render local and remote media streams.
/// They provide the visual shell for WebRTC participants and encapsulate the
/// view logic needed for preview, portrait mode, and picture-in-picture layouts.
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class RemoteVideoWidget extends StatefulWidget {
  final RTCVideoRenderer remoteRenderer;
  final bool isMuted;
  final VoidCallback? onTap;

  const RemoteVideoWidget({
    Key? key,
    required this.remoteRenderer,
    this.isMuted = false,
    this.onTap,
  }) : super(key: key);

  @override
  State<RemoteVideoWidget> createState() => _RemoteVideoWidgetState();
}

class _RemoteVideoWidgetState extends State<RemoteVideoWidget> {
  bool _showOverlay = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap?.call();
        setState(() => _showOverlay = !_showOverlay);
      },
      child: Stack(
        children: [
          // Remote video stream
          RTCVideoView(
            widget.remoteRenderer,
            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
          ),
          // Overlay with mute indicator
          if (widget.isMuted)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.mic_off, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Muted',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          // Connection status
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.fiber_manual_record,
                      color: Colors.green, size: 8),
                  SizedBox(width: 6),
                  Text(
                    'Connected',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LocalVideoWidget extends StatelessWidget {
  final RTCVideoRenderer localRenderer;
  final bool isMirror;

  const LocalVideoWidget({
    Key? key,
    required this.localRenderer,
    this.isMirror = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: RTCVideoView(
        localRenderer,
        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
        mirror: isMirror,
      ),
    );
  }
}

class PictureInPictureWidget extends StatelessWidget {
  final RTCVideoRenderer remoteRenderer;
  final RTCVideoRenderer localRenderer;
  final bool isFullscreenLocal;
  final VoidCallback onSwapClick;

  const PictureInPictureWidget({
    Key? key,
    required this.remoteRenderer,
    required this.localRenderer,
    this.isFullscreenLocal = false,
    required this.onSwapClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main video (remote or local depending on isFullscreenLocal)
        if (isFullscreenLocal)
          LocalVideoWidget(localRenderer: localRenderer)
        else
          RTCVideoView(
            remoteRenderer,
            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
          ),
        // Picture-in-picture
        Positioned(
          bottom: 16,
          right: 16,
          child: GestureDetector(
            onTap: onSwapClick,
            child: Container(
              width: 120,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: isFullscreenLocal
                    ? RTCVideoView(
                        remoteRenderer,
                        objectFit:
                            RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      )
                    : LocalVideoWidget(
                        localRenderer: localRenderer,
                        isMirror: true,
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
