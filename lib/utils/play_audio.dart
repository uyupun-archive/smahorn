import 'package:audioplayers/audioplayers.dart';

void playAudio(String tone) {
  print('🤖 $tone');
  final player = AudioPlayer();
  player.play(AssetSource('tones/$tone.mp3'));
}
