/// Screen-capture integration used when a device needs to share its display.
/// It is responsible for starting and stopping the capture pipeline and reporting
/// any platform-level limitations to the rest of the app.
import 'dart:io';
import 'package:flutter/services.dart';

class ScreenCaptureService {
  static const platform = MethodChannel('com.cooperatingscreen.app/screen_capture');

  /// Start screen capture (requires native implementation)
  /// For Android: Use MediaProjection API
  /// For iOS: Use ReplayKit
  static Future<String?> startScreenCapture() async {
    try {
      if (Platform.isAndroid) {
        return await platform.invokeMethod<String>('startScreenCapture');
      } else if (Platform.isIOS) {
        return await platform.invokeMethod<String>('startReplayKit');
      }
      return null;
    } catch (e) {
      print('Error starting screen capture: $e');
      return null;
    }
  }

  /// Stop screen capture
  static Future<bool> stopScreenCapture() async {
    try {
      if (Platform.isAndroid) {
        return await platform.invokeMethod<bool>('stopScreenCapture') ?? false;
      } else if (Platform.isIOS) {
        return await platform.invokeMethod<bool>('stopReplayKit') ?? false;
      }
      return false;
    } catch (e) {
      print('Error stopping screen capture: $e');
      return false;
    }
  }

  /// Check if screen capture is supported
  static Future<bool> isScreenCaptureSupported() async {
    try {
      return await platform.invokeMethod<bool>('isScreenCaptureSupported') ?? false;
    } catch (e) {
      print('Error checking screen capture support: $e');
      return false;
    }
  }

  /// Get screen dimensions
  static Future<Map<String, dynamic>?> getScreenDimensions() async {
    try {
      final result = await platform.invokeMethod<Map<dynamic, dynamic>>('getScreenDimensions');
      if (result != null) {
        return {
          'width': result['width'] as int?,
          'height': result['height'] as int?,
        };
      }
      return null;
    } catch (e) {
      print('Error getting screen dimensions: $e');
      return null;
    }
  }
}
