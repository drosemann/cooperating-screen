// Generated Flutter plugin registrar for the iOS screen-capture bridge.
// It registers platform implementations so the Flutter app can access native
// capture and display features through the method channel contract.
import UIKit
import Flutter
import ReplayKit

@UIApplicationMain
@objc class GeneratedPluginRegistrant: NSObject {
}

class ScreenCaptureHandler: NSObject, RPScreenRecorderDelegate {
    private let methodChannel: FlutterMethodChannel
    
    init(with controller: FlutterViewController) {
        self.methodChannel = FlutterMethodChannel(
            name: "com.cooperatingscreen.app/screen_capture",
            binaryMessenger: controller.binaryMessenger
        )
        super.init()
        
        self.methodChannel.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call, result: result)
        }
    }
    
    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startReplayKit":
            startReplayKit(result: result)
        case "stopReplayKit":
            stopReplayKit(result: result)
        case "isScreenCaptureSupported":
            result(RPScreenRecorder.shared().isAvailable)
        case "getScreenDimensions":
            let screen = UIScreen.main.bounds
            result([
                "width": Int(screen.width),
                "height": Int(screen.height)
            ])
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func startReplayKit(result: @escaping FlutterResult) {
        if RPScreenRecorder.shared().isAvailable {
            RPScreenRecorder.shared().startCapture { error in
                if let error = error {
                    result(FlutterError(
                        code: "SCREEN_CAPTURE_ERROR",
                        message: error.localizedDescription,
                        details: nil
                    ))
                } else {
                    result("Screen capture started")
                }
            }
        } else {
            result(FlutterError(
                code: "NOT_SUPPORTED",
                message: "Screen capture not supported on this device",
                details: nil
            ))
        }
    }
    
    private func stopReplayKit(result: @escaping FlutterResult) {
        RPScreenRecorder.shared().stopCapture { error in
            if let error = error {
                result(FlutterError(
                    code: "SCREEN_CAPTURE_ERROR",
                    message: error.localizedDescription,
                    details: nil
                ))
            } else {
                result(true)
            }
        }
    }
}
