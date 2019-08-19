import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:not_at_home/newContact/newContactPermissions.dart';

void showImagePicker(BuildContext context, ValueNotifier<String> imageLocation, Function ifNewImage) {
  // flutter defined function
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // return object of type Dialog
      return Dialog(
        child: Row(
          children: <Widget>[
            bigIcon(context, imageLocation, ifNewImage, false, FontAwesomeIcons.images),
            bigIcon(context, imageLocation, ifNewImage, true, Icons.camera),
          ],
        ),
      );
    },
  );
}

Widget bigIcon(BuildContext context, ValueNotifier<String> imageLocation, Function ifNewImage, bool fromCamera, IconData icon){
  return Expanded(
    child: FittedBox(
      fit: BoxFit.fill,
      child: Container(
        padding: EdgeInsets.only(left: 4, right: 8, top: 4, bottom: 4),
        child: IconButton(
          onPressed: () => changeImage(context, imageLocation, ifNewImage, fromCamera),
          icon: Icon(icon),
        ),
      ),
    ),
  );
}

//return whether or not you should set state
changeImage(BuildContext context, ValueNotifier<String> imageLocation, Function ifNewImage, bool fromCamera) async {
  if(fromCamera){
    askPermission(
      context, 
      //from camera
      () => actuallyChangeImage(context, imageLocation, ifNewImage, true), 
      PermissionBeingRequested.camera,
    );
  }
  else{
    askPermission(
      context, 
      //not from camera
      () => actuallyChangeImage(context, imageLocation, ifNewImage, false), 
      PermissionBeingRequested.storage,
    );
  }
}

actuallyChangeImage(BuildContext context, ValueNotifier<String> imageLocation, Function ifNewImage, bool fromCamera) async {
  //NOTE: here we KNOW that we have already been given the permissions we need
  File tempImage = await ImagePicker.pickImage(
    source: (fromCamera) ? ImageSource.camera : ImageSource.gallery,
  );

  //if an image was actually selected
  if(tempImage != null){
    //pop the popup 
    Navigator.of(context).pop();

    //set the new image location
    imageLocation.value = tempImage.path;

    //set state in the widget that called this image picker
    ifNewImage(fromTheCamera: fromCamera);
  }
  //ELSE... we back out of selecting it
}