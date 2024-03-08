import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';

class PlayAudioService extends ChangeNotifier{
  bool isPlaying = false;
  final audioPlayer = AssetsAudioPlayer.newPlayer();

  void changeIsPlaying(bool value){
    isPlaying= value;
    notifyListeners();
  }

}