/// Settings screen exposing app personalization and connection preferences.
/// It allows administrators to adjust visual appearance, networking, and device
/// behavior without leaving the main application flow.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Loads the persisted application settings when the screen is created so the
  // controls reflect the latest video, audio, and theme preferences.
  Future<void> _loadSettings() async {
    final settings = context.read<AppSettings>();
    await settings.loadSettings();
  }

  // Builds the settings screen and organizes the user preferences into grouped
  // sections for display, connection, appearance, and notification behavior.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: Consumer<AppSettings>(
        builder: (context, settings, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Video Quality Section
              const Text(
                'Video & Display',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Video Quality'),
                      subtitle: Text(_getQualityLabel(settings.videoQuality)),
                      trailing: DropdownButton<VideoQuality>(
                        value: settings.videoQuality,
                        items: VideoQuality.values
                            .map((quality) => DropdownMenuItem(
                                  value: quality,
                                  child: Text(_getQualityLabel(quality)),
                                ))
                            .toList(),
                        onChanged: (quality) {
                          if (quality != null) {
                            settings.setVideoQuality(quality);
                          }
                        },
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Frame Rate'),
                      subtitle: Text('${settings.videoFrameRate} fps'),
                      trailing: Slider(
                        value: settings.videoFrameRate.toDouble(),
                        min: 15,
                        max: 60,
                        divisions: 9,
                        onChanged: (value) {
                          settings.setVideoFrameRate(value.toInt());
                        },
                      ),
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('Mirror Local Video'),
                      subtitle: const Text('Flip front camera view'),
                      value: settings.mirrorLocalVideo,
                      onChanged: (value) {
                        settings.setMirrorLocalVideo(value);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Audio & Connection Section
              const Text(
                'Audio & Connection',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Audio'),
                      subtitle: const Text('Enable microphone'),
                      value: settings.audioEnabled,
                      onChanged: (value) {
                        settings.setAudioEnabled(value);
                      },
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('Auto-Reconnect'),
                      subtitle: const Text('Automatically reconnect if connection drops'),
                      value: settings.autoReconnect,
                      onChanged: (value) {
                        settings.setAutoReconnect(value);
                      },
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Connection Timeout'),
                      subtitle: Text('${settings.connectionTimeoutSeconds} seconds'),
                      trailing: Slider(
                        value: settings.connectionTimeoutSeconds.toDouble(),
                        min: 10,
                        max: 120,
                        divisions: 11,
                        onChanged: (value) {
                          settings.setConnectionTimeout(value.toInt());
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Appearance Section
              const Text(
                'Appearance',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  title: const Text('Theme'),
                  subtitle: Text(_getThemeModeLabel(settings.themeMode)),
                  trailing: DropdownButton<ThemeMode>(
                    value: settings.themeMode,
                    items: ThemeMode.values
                        .map((mode) => DropdownMenuItem(
                              value: mode,
                              child: Text(_getThemeModeLabel(mode)),
                            ))
                        .toList(),
                    onChanged: (mode) {
                      if (mode != null) {
                        settings.setThemeMode(mode);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Notifications Section
              const Text(
                'Notifications & Feedback',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Notifications'),
                      subtitle: const Text('Receive call and message notifications'),
                      value: settings.enableNotifications,
                      onChanged: (value) {
                        settings.setEnableNotifications(value);
                      },
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('Vibration'),
                      subtitle: const Text('Haptic feedback on interactions'),
                      value: settings.vibrationEnabled,
                      onChanged: (value) {
                        settings.setVibrationEnabled(value);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Actions
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Reset to Defaults'),
                      content: const Text(
                        'Are you sure you want to reset all settings to their default values?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            settings.resetToDefaults();
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Settings reset to defaults'),
                              ),
                            );
                          },
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Reset to Defaults'),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  String _getQualityLabel(VideoQuality quality) {
    switch (quality) {
      case VideoQuality.auto:
        return 'Auto';
      case VideoQuality.hd:
        return 'HD (720p)';
      case VideoQuality.sd:
        return 'SD (480p)';
    }
  }

  String _getThemeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System Default';
    }
  }
}
