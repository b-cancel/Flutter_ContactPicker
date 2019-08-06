import 'package:vibration/vibration.dart';

bool hasVibrationChecked = false;
bool hasVibration = false;
vibrate()async{
  //check
  if(hasVibrationChecked == false){
    hasVibrationChecked = true;
    hasVibration = await Vibration.hasVibrator();
  }

  //vibrate if we can
  if(hasVibration){
    Vibration.vibrate(
      duration: 100,
    );
  }
}