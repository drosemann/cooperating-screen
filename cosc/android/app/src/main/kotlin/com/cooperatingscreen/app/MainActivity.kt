// Android entry point for the screen-capture bridge used by Flutter.
// The activity requests media projection permission and exposes the native
// capture API to the rest of the application through a method channel.
package com.cooperatingscreen.app

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.media.projection.MediaProjectionManager
import android.view.WindowManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: Activity() {
    private val CHANNEL = "com.cooperatingscreen.app/screen_capture"
    private var mediaProjectionManager: MediaProjectionManager? = null
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        mediaProjectionManager =
            getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startScreenCapture" -> {
                        startScreenCapture(result)
                    }
                    "stopScreenCapture" -> {
                        stopScreenCapture(result)
                    }
                    "isScreenCaptureSupported" -> {
                        result.success(true)
                    }
                    "getScreenDimensions" -> {
                        val windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
                        val displayMetrics = this.resources.displayMetrics
                        result.success(mapOf(
                            "width" to displayMetrics.widthPixels,
                            "height" to displayMetrics.heightPixels
                        ))
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
    }
    
    private fun startScreenCapture(result: MethodChannel.Result) {
        // Request screen capture permission using MediaProjectionManager
        // This requires API level 21+
        val intent = mediaProjectionManager?.createScreenCaptureIntent()
        startActivityForResult(intent, REQUEST_CODE_SCREEN_CAPTURE)
        result.success("Screen capture started")
    }
    
    private fun stopScreenCapture(result: MethodChannel.Result) {
        // Implement screen capture cleanup
        result.success(true)
    }
    
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        
        if (requestCode == REQUEST_CODE_SCREEN_CAPTURE && resultCode == RESULT_OK) {
            // Handle successful screen capture request
            // Pass the MediaProjection to WebRTC
        }
    }
    
    companion object {
        private const val REQUEST_CODE_SCREEN_CAPTURE = 1001
    }
}
