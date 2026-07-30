import 'package:flutter/foundation.dart';

class LocalAudioService {
  static final LocalAudioService _instance = LocalAudioService._internal();
  factory LocalAudioService() => _instance;
  LocalAudioService._internal();

  bool _isPlaying = false;
  String? _currentAudioKey;

  bool get isPlaying => _isPlaying;
  String? get currentAudioKey => _currentAudioKey;

  /// Map of clinical parameters to Dagbani audio prompt names
  static const Map<String, String> dagbaniAudioPrompts = {
    'muac': 'muac_instruction_dagbani.mp3',
    'oedema': 'oedema_check_dagbani.mp3',
    'breathing': 'breathing_timer_dagbani.mp3',
    'danger_signs': 'child_danger_signs_dagbani.mp3',
    'maternal_hb': 'maternal_anaemia_dagbani.mp3',
    'fetal_movement': 'fetal_movement_dagbani.mp3',
  };

  Future<void> playDagbaniAudio(String promptKey, {VoidCallback? onComplete}) async {
    _currentAudioKey = promptKey;
    _isPlaying = true;
    if (kDebugMode) {
      print('🔊 Playing pre-recorded Dagbani audio prompt for: $promptKey (${dagbaniAudioPrompts[promptKey]})');
    }
    // Simulate playback audio duration in local environment
    await Future.delayed(const Duration(seconds: 3));
    _isPlaying = false;
    _currentAudioKey = null;
    if (onComplete != null) onComplete();
  }

  Future<void> playDagbaniInstruction(String promptKey) async {
    await playDagbaniAudio(promptKey);
  }

  Future<void> stopAudio() async {
    _isPlaying = false;
    _currentAudioKey = null;
  }
}
