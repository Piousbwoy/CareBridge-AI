import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

class LocalAudioService {
  static final LocalAudioService _instance = LocalAudioService._internal();
  factory LocalAudioService() => _instance;
  LocalAudioService._internal();

  AudioPlayer? _player;
  bool _isPlaying = false;
  String? _currentAudioKey;

  bool get isPlaying => _isPlaying;
  String? get currentAudioKey => _currentAudioKey;

  /// Map of clinical parameters to Dagbani audio prompt asset names
  static const Map<String, String> dagbaniAudioPrompts = {
    'muac': 'muac_instruction_dagbani.mp3',
    'oedema': 'oedema_check_dagbani.mp3',
    'breathing': 'breathing_timer_dagbani.mp3',
    'danger_signs': 'danger_signs_dagbani.mp3',
    'maternal_hb': 'maternal_anaemia_dagbani.mp3',
    'fetal_movement': 'fetal_movement_dagbani.mp3',
  };

  Future<void> playDagbaniAudio(String promptKey, {VoidCallback? onComplete}) async {
    final fileName = dagbaniAudioPrompts[promptKey];
    if (fileName == null) return;

    _currentAudioKey = promptKey;
    _isPlaying = true;
    if (kDebugMode) {
      print('🔊 Playing pre-recorded Dagbani audio prompt: $promptKey ($fileName)');
    }

    try {
      _player ??= AudioPlayer();
      await _player!.stop();
      await _player!.play(AssetSource('audio/$fileName'));
      _player!.onPlayerComplete.first.then((_) {
        _isPlaying = false;
        _currentAudioKey = null;
        if (onComplete != null) onComplete();
      });
    } catch (e) {
      if (kDebugMode) print('🔊 Audio playback notice ($promptKey): $e');
      // Graceful fallback for web/desktop environments where audio device might not be initialized
      await Future.delayed(const Duration(seconds: 2));
      _isPlaying = false;
      _currentAudioKey = null;
      if (onComplete != null) onComplete();
    }
  }

  Future<void> playDagbaniInstruction(String promptKey) async {
    await playDagbaniAudio(promptKey);
  }

  Future<void> stopAudio() async {
    try {
      await _player?.stop();
    } catch (_) {}
    _isPlaying = false;
    _currentAudioKey = null;
  }
}
