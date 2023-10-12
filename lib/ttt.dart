import 'package:flutter/material.dart';
import 'package:vlc_flutter/vlcplayer.dart';
void arko (){
  VLCController _controller = VLCController(args:["-vvv"]);

 /// Listening to the status of the player:

  _controller.onPlayerState.listen((event) {
    debugPrint("=*= $event =*=");
  });
 // Listening to player events:

  _controller.onEvent.listen((event) {
    if(event.type == EventType.PositionChanged){
      debugPrint("==[${event.positionChanged}]==");
    }
  });
}