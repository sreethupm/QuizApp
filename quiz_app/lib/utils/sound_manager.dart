import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> play(String fileName) async {
    try {
      // Use AssetSource with path relative to pubspec assets folder
      await _player.play(AssetSource('sounds/$fileName'));
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  static Future<void> stop() async {
    await _player.stop();
  }
}
