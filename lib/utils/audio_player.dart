
import 'package:audioplayers/audioplayers.dart';

void playClickSound() {
  final player = AudioPlayer();
  player.play(AssetSource('sounds/click.mp3'));
}
