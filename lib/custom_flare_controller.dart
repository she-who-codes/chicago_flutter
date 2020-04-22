import 'package:flare_dart/math/mat2d.dart';
import 'dart:math';
import 'package:flare_flutter/flare.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controller.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';

///this will be a custom controller for our Flare Actor
///It extends the FlareController class, so there will be some required overrides
class CustomFlareController extends FlareController {
  ///artboard
  FlutterActorArtboard _artboard;

  ///can the pop up animate in
  bool _animatePopUp = false;
  ///can the pop up be visible or should the other be visible?
  bool _showPopUp = false;

  ///how much we increment each tap
  double _incrementAmt;
  ///gets increased by increment amount
  double _myFill = 0;
  ///what we'll use to smooth the fill
  double _currentFill = 0;
  ///time used to smooth the fill line movement
  double _smoothTime = 5;
  ///time for playing the pop up animation
  double _animTime = 0;

  ///fill animation
  FlareAnimationLayer _baseAnimation;
  ///pop up animation
  ActorAnimation _popUpAnimation;
  ///for playing audio
  AudioCache audioCache = AudioCache();

  ///where we get a ref to our artboard and animations that we'll be translating
  void initialize(FlutterActorArtboard artboard)
  {
      _artboard = artboard;

      _baseAnimation = FlareAnimationLayer()
        ..animation = _artboard.getAnimation("Fill_Up");


      _popUpAnimation = _artboard.getAnimation("End_Pop_Up");

      ///math based on how many taps we want before radial is full.
      _incrementAmt = _baseAnimation.animation.duration/29;

  }

  ///required since we extended FlareController, but not used
  void setViewTransform(Mat2D viewTransform)
  {
  }

  void onCompleted(String name) {
    if(name.compareTo("End_Pop_Up") == 0){
      _animatePopUp = false;
    }
  }
  ///required since we extended FlareController, also where the magic happens!
  bool advance(FlutterActorArtboard artboard, double elapsed)
  {
    ///pop up animation
    if(_showPopUp == true) {

      if(_animatePopUp == true){
        _animTime += elapsed * 1;
      }
      _popUpAnimation.apply(_animTime % _popUpAnimation.duration, _artboard, 1);

      if ((_animTime % _popUpAnimation.duration + .04) >
          _popUpAnimation.duration) {
        onCompleted(_popUpAnimation.name);
      }

    } else {///filling animation

      _currentFill += (_myFill-_currentFill) * min(1, elapsed *
          _smoothTime);

      _baseAnimation.animation.apply( _currentFill * _baseAnimation.animation.duration,
          artboard, 1);

      ///EventTrigger
      List<AnimationEventArgs> _animationEvents = [];

      double currLayerAnim = _baseAnimation.time;
      _baseAnimation.time =
      (_currentFill * _baseAnimation.animation.duration);

      _baseAnimation.animation.triggerEvents(
          artboard.components, currLayerAnim, _baseAnimation.time, _animationEvents);

      for (var event in _animationEvents) {
        switch (event.name) {
          case "Event":
            _animatePopUp = true;

            _showPopUp = true;
            _playSound();
            break;
        }
      }
    }
    return true;
  }

  ///called from tapping the button
  void incrementFill()
  {
    if(isFull() == false){
      _myFill += _incrementAmt;

    } else {
      _myFill = 0;
      _showPopUp = false;

    }
  }

  ///checks to see if our radial is full
  ///also used in button tap to set icon image
  bool isFull()
  {
    if(_myFill > 1){
      return true;
    }
    return false;
  }

  ///called on animation event
  void _playSound()
  {
    audioCache.play('audio/mineral_pickup.wav', mode: PlayerMode.LOW_LATENCY);
  }
}
