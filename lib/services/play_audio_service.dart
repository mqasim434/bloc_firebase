import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';

class PlayAudioService extends ChangeNotifier{
  bool isPlaying = false;
  final audioPlayer = AssetsAudioPlayer.newPlayer();

  void playTune()async{
    if(!isPlaying){
      isPlaying = true;
      notifyListeners();
      audioPlayer.open(
          Audio("assets/sounds/tune.mp3"),
        showNotification: true,
      );
    }
  }

  void pauseTune(){
    if(isPlaying){
      audioPlayer.stop();
      isPlaying = false;
      notifyListeners();
    }
  }

}