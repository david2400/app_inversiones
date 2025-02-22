import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:inversiones/ui/utils/flutter_flow_animations.dart';

List<Effect<dynamic>> createAnimationEffects({
  required double fadeBegin,
  required double fadeEnd,
  required Offset moveBegin,
  required Offset moveEnd,
  required Offset scaleBegin,
  required Offset scaleEnd,
  Duration duration = const Duration(microseconds: 600),
  Duration delay = const Duration(microseconds: 100),
  Curve curve = Curves.easeInOut,
}) {
  return [
    FadeEffect(
      curve: curve,
      delay: delay,
      duration: duration,
      begin: fadeBegin,
      end: fadeEnd,
    ),
    MoveEffect(
      curve: curve,
      delay: delay,
      duration: duration,
      begin: moveBegin,
      end: moveEnd,
    ),
    ScaleEffect(
      curve: curve,
      delay: delay,
      duration: duration,
      begin: scaleBegin,
      end: scaleEnd,
    ),
  ];
}

AnimationInfo? getAnimaciones(key) {
  final Map<String, AnimationInfo> animations = {
    'buttonOnPageLoadAnimation1': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effectsBuilder: () => createAnimationEffects(
          fadeBegin: 0.0,
          fadeEnd: 1.0,
          moveBegin: Offset(0.0, 40.0),
          moveEnd: Offset(0.0, 0.0),
          scaleBegin: Offset(1.0, 0.0),
          scaleEnd: Offset(1.0, 1.0),
          delay: Duration(milliseconds: 400),
          curve: Curves.bounceOut),
    ),
    'buttonOnPageLoadAnimation2': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effectsBuilder: () => createAnimationEffects(
          fadeBegin: 0.0,
          fadeEnd: 1.0,
          moveBegin: Offset(0.0, 40.0),
          moveEnd: Offset(0.0, 0.0),
          scaleBegin: Offset(1.0, 0.0),
          scaleEnd: Offset(1.0, 1.0),
          delay: Duration(milliseconds: 400),
          curve: Curves.bounceOut),
    ),
    'textOnPageLoadAnimation': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effectsBuilder: () => createAnimationEffects(
          fadeBegin: 0.0,
          fadeEnd: 1.0,
          moveBegin: Offset(0.0, 20.0),
          moveEnd: Offset(0.0, 0.0),
          scaleBegin: Offset(1.0, 0.0),
          scaleEnd: Offset(1.0, 1.0),
          delay: Duration(milliseconds: 50),
          curve: Curves.easeInOut),
    ),
    'circleImageOnPageLoadAnimation': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effectsBuilder: () => createAnimationEffects(
          fadeBegin: 0.0,
          fadeEnd: 1.0,
          moveBegin: Offset(0.0, 19.0),
          moveEnd: Offset(0.0, 0.0),
          scaleBegin: Offset(1.0, 0.0),
          scaleEnd: Offset(1.0, 1.0),
          delay: Duration(milliseconds: 0),
          curve: Curves.bounceOut),
    ),
    'listViewOnPageLoadAnimation': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effectsBuilder: () => createAnimationEffects(
        fadeBegin: 0.0,
        fadeEnd: 1.0,
        moveBegin: Offset(0.0, 26.0),
        moveEnd: Offset(0.0, 0.0),
        scaleBegin: Offset(1.0, 0.0),
        scaleEnd: Offset(1.0, 1.0),
        delay: Duration(milliseconds: 90),
        duration: Duration(milliseconds: 600),
      ),
    ),
    'containerOnPageLoadAnimation1': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effectsBuilder: () => createAnimationEffects(
        fadeBegin: 0.0,
        fadeEnd: 1.0,
        moveBegin: Offset(0.0, 60.0),
        moveEnd: Offset(0.0, 0.0),
        scaleBegin: Offset(1.0, 0.0),
        scaleEnd: Offset(1.0, 1.0),
        delay: Duration(milliseconds: 0),
      ),
    ),
    'containerOnPageLoadAnimation2': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effectsBuilder: () => createAnimationEffects(
        fadeBegin: 0.0,
        fadeEnd: 1.0,
        moveBegin: Offset(0.0, 90.0),
        moveEnd: Offset(0.0, 0.0),
        scaleBegin: Offset(1.0, 0.0),
        scaleEnd: Offset(1.0, 1.0),
        duration: Duration(milliseconds: 800),
        delay: Duration(milliseconds: 0),
      ),
    ),
    'containerOnPageLoadAnimation3': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effectsBuilder: () => createAnimationEffects(
        fadeBegin: 0.0,
        fadeEnd: 1.0,
        moveBegin: Offset(0.0, 60.0),
        moveEnd: Offset(0.0, 0.0),
        scaleBegin: Offset(1.0, 1.0),
        scaleEnd: Offset(1.0, 1.0),
        duration: Duration(milliseconds: 800),
        delay: Duration(milliseconds: 0),
      ),
    ),
    'columnOnPageLoadAnimation1': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effectsBuilder: () => createAnimationEffects(
        fadeBegin: 0.0,
        fadeEnd: 1.0,
        moveBegin: Offset(0.0, 60.0),
        moveEnd: Offset(0.0, 0.0),
        scaleBegin: Offset(1.0, 0.0),
        scaleEnd: Offset(1.0, 1.0),
        delay: Duration(milliseconds: 0),
      ),
    ),
    'columnOnPageLoadAnimation2': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effectsBuilder: () => createAnimationEffects(
        fadeBegin: 0.0,
        fadeEnd: 1.0,
        moveBegin: Offset(0.0, 60.0),
        moveEnd: Offset(0.0, 0.0),
        scaleBegin: Offset(1.0, 0.0),
        scaleEnd: Offset(1.0, 1.0),
        delay: Duration(milliseconds: 0),
      ),
    ),
    'rowOnPageLoadAnimation': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effectsBuilder: () => createAnimationEffects(
        fadeBegin: 0.0,
        fadeEnd: 1.0,
        moveBegin: Offset(0.0, 22.0),
        moveEnd: Offset(0.0, 0.0),
        scaleBegin: Offset(0.2, 0.0),
        scaleEnd: Offset(0.0, 0.0),
        delay: Duration(milliseconds: 0),
      ),
    ),
    'containerOnPageLoadAnimation': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effectsBuilder: () => createAnimationEffects(
        fadeBegin: 0.0,
        fadeEnd: 1.0,
        moveBegin: Offset(0.0, 30.0),
        moveEnd: Offset(0.0, 0.0),
        scaleBegin: Offset(0.4, 0.0),
        scaleEnd: Offset(1.0, 1.0),
        delay: Duration(milliseconds: 0),
      ),
    ),
    'buttonOnPageLoadAnimation': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effectsBuilder: () => createAnimationEffects(
        fadeBegin: 0.0,
        fadeEnd: 1.0,
        moveBegin: Offset(0.0, 47.0),
        moveEnd: Offset(0.0, 0.0),
        scaleBegin: Offset(1.0, 0.0),
        scaleEnd: Offset(1.0, 1.0),
        delay: Duration(milliseconds: 0),
      ),
    ),
    'textFieldOnPageLoadAnimation1': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effectsBuilder: () => createAnimationEffects(
        fadeBegin: 0.0,
        fadeEnd: 1.0,
        moveBegin: Offset(0.0, 40.0),
        moveEnd: Offset(0.0, 0.0),
        scaleBegin: Offset(1.0, 0.0),
        scaleEnd: Offset(1.0, 1.0),
        delay: Duration(milliseconds: 0),
      ),
    ),
    'textFieldOnPageLoadAnimation2': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effectsBuilder: () => createAnimationEffects(
        fadeBegin: 0.0,
        fadeEnd: 1.0,
        moveBegin: Offset(0.0, 40.0),
        moveEnd: Offset(0.0, 0.0),
        scaleBegin: Offset(1.0, 0.0),
        scaleEnd: Offset(1.0, 1.0),
        delay: Duration(milliseconds: 200),
      ),
    ),
    'textFieldOnPageLoadAnimation3': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effectsBuilder: () => createAnimationEffects(
        fadeBegin: 0.0,
        fadeEnd: 1.0,
        moveBegin: Offset(0.0, 60.0),
        moveEnd: Offset(0.0, 0.0),
        scaleBegin: Offset(1.0, 0.0),
        scaleEnd: Offset(1.0, 1.0),
        delay: Duration(milliseconds: 200),
      ),
    ),
    'dropDownOnPageLoadAnimation1': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effectsBuilder: () => createAnimationEffects(
        fadeBegin: 0.0,
        fadeEnd: 1.0,
        moveBegin: Offset(0.0, 60.0),
        moveEnd: Offset(0.0, 0.0),
        scaleBegin: Offset(1.0, 0.0),
        scaleEnd: Offset(1.0, 1.0),
      ),
    ),
  };

  return animations[key];
}
