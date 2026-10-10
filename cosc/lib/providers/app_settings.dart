/// App-level configuration provider for theme, video preferences, and behavior.
/// This state container centralizes the UI settings used by the Flutter screens
/// so the application remains consistent across the navigation flow.
import 'package:flutter/material.dart';
import '../utils/local_storage_service.dart';

enum VideoQuality { auto, hd, sd }

enum ThemeMode { light, dark, system }

class AppSettings extends ChangeNotifier {
  // Video settings
  VideoQuality _videoQuality = VideoQuality.auto;
  bool _audioEnabled = true;
  int _videoFrameRate = 30;
  
  // Display settings
  bool _mirrorLocalVideo = true;
  bool _showRemoteVideoFullscreen = false;
  int _displayTimeoutSeconds = 60;
  
  // Theme settings
  ThemeMode _themeMode = ThemeMode.system;
  
  // General settings
  bool _autoReconnect = true;
  int _connectionTimeoutSeconds = 30;
  bool _enableNotifications = true;
  bool _vibrationEnabled = true;
  
  // Getters
  VideoQuality get videoQuality => _videoQuality;
  bool get audioEnabled => _audioEnabled;
  int get videoFrameRate => _videoFrameRate;
  bool get mirrorLocalVideo => _mirrorLocalVideo;
  bool get showRemoteVideoFullscreen => _showRemoteVideoFullscreen;
  int get displayTimeoutSeconds => _displayTimeoutSeconds;
  ThemeMode get themeMode => _themeMode;
  bool get autoReconnect => _autoReconnect;
  int get connectionTimeoutSeconds => _connectionTimeoutSeconds;
  bool get enableNotifications => _enableNotifications;
  bool get vibrationEnabled => _vibrationEnabled;

  /// Load settings from storage
  Future<void> loadSettings() async {
    try {
      final videoQualityValue =
          await LocalStorageService.getSetting('videoQuality') as String?;
      if (videoQualityValue != null) {
        _videoQuality = VideoQuality.values
            .firstWhere((e) => e.toString() == videoQualityValue);
      }

      final audioEnabledValue =
          await LocalStorageService.getSetting('audioEnabled') as bool?;
      if (audioEnabledValue != null) {
        _audioEnabled = audioEnabledValue;
      }

      final videoFrameRateValue =
          await LocalStorageService.getSetting('videoFrameRate') as int?;
      if (videoFrameRateValue != null) {
        _videoFrameRate = videoFrameRateValue;
      }

      final mirrorLocalVideoValue =
          await LocalStorageService.getSetting('mirrorLocalVideo') as bool?;
      if (mirrorLocalVideoValue != null) {
        _mirrorLocalVideo = mirrorLocalVideoValue;
      }

      final themeModeValue =
          await LocalStorageService.getSetting('themeMode') as String?;
      if (themeModeValue != null) {
        _themeMode =
            ThemeMode.values.firstWhere((e) => e.toString() == themeModeValue);
      }

      final autoReconnectValue =
          await LocalStorageService.getSetting('autoReconnect') as bool?;
      if (autoReconnectValue != null) {
        _autoReconnect = autoReconnectValue;
      }

      final connectionTimeoutValue =
          await LocalStorageService.getSetting('connectionTimeout') as int?;
      if (connectionTimeoutValue != null) {
        _connectionTimeoutSeconds = connectionTimeoutValue;
      }

      notifyListeners();
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  // Setters with persistence
  Future<void> setVideoQuality(VideoQuality quality) async {
    _videoQuality = quality;
    await LocalStorageService.saveSetting('videoQuality', quality.toString());
    notifyListeners();
  }

  Future<void> setAudioEnabled(bool enabled) async {
    _audioEnabled = enabled;
    await LocalStorageService.saveSetting('audioEnabled', enabled);
    notifyListeners();
  }

  Future<void> setVideoFrameRate(int frameRate) async {
    _videoFrameRate = frameRate;
    await LocalStorageService.saveSetting('videoFrameRate', frameRate);
    notifyListeners();
  }

  Future<void> setMirrorLocalVideo(bool mirror) async {
    _mirrorLocalVideo = mirror;
    await LocalStorageService.saveSetting('mirrorLocalVideo', mirror);
    notifyListeners();
  }

  Future<void> setShowRemoteVideoFullscreen(bool show) async {
    _showRemoteVideoFullscreen = show;
    await LocalStorageService.saveSetting('showRemoteFullscreen', show);
    notifyListeners();
  }

  Future<void> setDisplayTimeout(int seconds) async {
    _displayTimeoutSeconds = seconds;
    await LocalStorageService.saveSetting('displayTimeout', seconds);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await LocalStorageService.saveSetting('themeMode', mode.toString());
    notifyListeners();
  }

  Future<void> setAutoReconnect(bool enabled) async {
    _autoReconnect = enabled;
    await LocalStorageService.saveSetting('autoReconnect', enabled);
    notifyListeners();
  }

  Future<void> setConnectionTimeout(int seconds) async {
    _connectionTimeoutSeconds = seconds;
    await LocalStorageService.saveSetting('connectionTimeout', seconds);
    notifyListeners();
  }

  Future<void> setEnableNotifications(bool enabled) async {
    _enableNotifications = enabled;
    await LocalStorageService.saveSetting('enableNotifications', enabled);
    notifyListeners();
  }

  Future<void> setVibrationEnabled(bool enabled) async {
    _vibrationEnabled = enabled;
    await LocalStorageService.saveSetting('vibrationEnabled', enabled);
    notifyListeners();
  }

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    _videoQuality = VideoQuality.auto;
    _audioEnabled = true;
    _videoFrameRate = 30;
    _mirrorLocalVideo = true;
    _showRemoteVideoFullscreen = false;
    _displayTimeoutSeconds = 60;
    _themeMode = ThemeMode.system;
    _autoReconnect = true;
    _connectionTimeoutSeconds = 30;
    _enableNotifications = true;
    _vibrationEnabled = true;

    // Clear all settings
    await LocalStorageService.saveSetting('videoQuality', null);
    await LocalStorageService.saveSetting('audioEnabled', null);
    await LocalStorageService.saveSetting('videoFrameRate', null);
    await LocalStorageService.saveSetting('mirrorLocalVideo', null);
    await LocalStorageService.saveSetting('showRemoteFullscreen', null);
    await LocalStorageService.saveSetting('displayTimeout', null);
    await LocalStorageService.saveSetting('themeMode', null);
    await LocalStorageService.saveSetting('autoReconnect', null);
    await LocalStorageService.saveSetting('connectionTimeout', null);

    notifyListeners();
  }

  /// Export settings as JSON
  Map<String, dynamic> exportSettings() {
    return {
      'videoQuality': _videoQuality.toString(),
      'audioEnabled': _audioEnabled,
      'videoFrameRate': _videoFrameRate,
      'mirrorLocalVideo': _mirrorLocalVideo,
      'showRemoteVideoFullscreen': _showRemoteVideoFullscreen,
      'displayTimeoutSeconds': _displayTimeoutSeconds,
      'themeMode': _themeMode.toString(),
      'autoReconnect': _autoReconnect,
      'connectionTimeoutSeconds': _connectionTimeoutSeconds,
      'enableNotifications': _enableNotifications,
      'vibrationEnabled': _vibrationEnabled,
    };
  }

  /// Import settings from JSON
  Future<void> importSettings(Map<String, dynamic> settings) async {
    try {
      if (settings.containsKey('videoQuality')) {
        final value = settings['videoQuality'] as String;
        _videoQuality =
            VideoQuality.values.firstWhere((e) => e.toString() == value);
      }
      if (settings.containsKey('audioEnabled')) {
        _audioEnabled = settings['audioEnabled'] as bool;
      }
      if (settings.containsKey('videoFrameRate')) {
        _videoFrameRate = settings['videoFrameRate'] as int;
      }
      if (settings.containsKey('mirrorLocalVideo')) {
        _mirrorLocalVideo = settings['mirrorLocalVideo'] as bool;
      }
      if (settings.containsKey('themeMode')) {
        final value = settings['themeMode'] as String;
        _themeMode =
            ThemeMode.values.firstWhere((e) => e.toString() == value);
      }
      if (settings.containsKey('autoReconnect')) {
        _autoReconnect = settings['autoReconnect'] as bool;
      }

      notifyListeners();
    } catch (e) {
      print('Error importing settings: $e');
    }
  }
}
