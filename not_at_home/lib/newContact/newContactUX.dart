import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:not_at_home/newContact/categorySelect.dart';
import 'package:not_at_home/newContact/newContactHelper.dart';
import 'package:page_transition/page_transition.dart';

//phones, emails, work (job title, company), addresses, note

double titleRightPadding = 16;
double iconRightPadding = 32;

class NewContactUX extends StatelessWidget {
  NewContactUX({
    @required this.bottomBarHeight,
    @required this.namesSpread,
    //handle names
    @required this.nameField,
    @required this.nameFields,
    @required this.nameLabels,
    //TODO... add phones here
    //TODO... add emails here
    //handle work
    @required this.jobTitleField,
    @required this.companyField,
    @required this.workOpen,
    //TODO... add addresses here
    @required this.noteField,
    @required this.noteOpen,
  });

  final double bottomBarHeight;
  final ValueNotifier<bool> namesSpread;
  //handle names
  final FieldData nameField;
  final List<FieldData> nameFields;
  final List<String> nameLabels;
  //TODO... add phones here
  //TODO... add emails here
  //handle work
  final FieldData jobTitleField;
  final FieldData companyField;
  final ValueNotifier<bool> workOpen;
  //TODO... add addresses here
  final FieldData noteField;
  final ValueNotifier<bool> noteOpen;

  @override
  Widget build(BuildContext context) {
    //create all the needed rows
    List<Widget> nameRows = new List<Widget>();
    for(int i = 0; i < nameLabels.length; i++){
      FieldData thisField = nameFields[i];
      nameRows.add(
        new TheField(
          bottomBarHeight: bottomBarHeight,
          focusNode: thisField.focusNode,
          controller: thisField.controller,
          nextFunction: thisField.nextFunction,
          label: nameLabels[i],
          noPadding: true,
        ), 
      );
    }

    //build
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        new Title(
          icon: Icons.person,
          name: "Name",
          onTapped: null,
        ),
        //displayName, givenName, middleName, prefix, suffix, familyName;
        //Name prefix(prefix), Name suffix(suffix)
        //First name (givenName), Middle name (middleName), Last name (familyName)
        //display name = prefix, first name, middle name, last name, ',' suffix
        //NAME START-------------------------
        Visibility(
          visible: (namesSpread.value == false),
          child: TheField(
            bottomBarHeight: bottomBarHeight,
            label: "Name",
            focusNode: nameField.focusNode,
            controller: nameField.controller,
            nextFunction: nameField.nextFunction,
            rightIconButton: RightIconButton(
              onTapped: (){
                namesSpread.value = !namesSpread.value;
              },
              icon: Icon(Icons.keyboard_arrow_down),
            ),
          ),
        ),
        Visibility(
          visible: namesSpread.value,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: Column(
                  children: nameRows,
                ),
              ),
              Container(
                //color: Colors.orange,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: (){
                    namesSpread.value = !namesSpread.value;
                  },
                  child: IgnorePointer(
                    child: Container(
                      height: 49.0 * 5,
                      alignment: Alignment.topCenter,
                      child: RightIconButton(
                        icon: Icon(
                          Icons.keyboard_arrow_up,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        //NAME END-------------------------
        new Title( 
          icon: Icons.phone,
          name: "Phone",
          onTapped: (){
            print("tapped phone");
          },
          rightIconButton: RightIconButton(
            icon: Icon(
              Icons.add,
              color: Colors.green,
            ),
          ),
        ),
        //PHONE START-------------------------
        Column(
          children: <Widget>[
            TheField(
              focusNode: jobTitleField.focusNode, 
              controller: jobTitleField.controller, 
              bottomBarHeight: bottomBarHeight, 
              nextFunction: jobTitleField.nextFunction, 
              label: "Phone 1",
              labelField: CategorySelector(
                labelType: LabelType.phone,
              ),
              rightIconButton: RightIconButton(
                onTapped: (){
                  print("right icon button pressed");
                },
                icon: Icon(
                  FontAwesomeIcons.minus,
                  color: Colors.red,
                  size: 16,
                ),
              ),
            ),
            TheField(
              focusNode: jobTitleField.focusNode, 
              controller: jobTitleField.controller, 
              bottomBarHeight: bottomBarHeight, 
              nextFunction: jobTitleField.nextFunction, 
              label: "Phone 2",
              labelField: CategorySelector(
                labelType: LabelType.email,
              ),
              rightIconButton: RightIconButton(
                onTapped: (){
                  print("right icon button pressed");
                },
                icon: Icon(
                  FontAwesomeIcons.minus,
                  color: Colors.red,
                  size: 16,
                ),
              ),
            ),
            TheField(
              focusNode: jobTitleField.focusNode, 
              controller: jobTitleField.controller, 
              bottomBarHeight: bottomBarHeight, 
              nextFunction: jobTitleField.nextFunction, 
              label: "Phone 3",
              labelField: CategorySelector(
                labelType: LabelType.address,
              ),
              rightIconButton: RightIconButton(
                onTapped: (){
                  print("right icon button pressed");
                },
                icon: Icon(
                  FontAwesomeIcons.minus,
                  color: Colors.red,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
        //PHONE END-------------------------
        new Title( 
          icon: Icons.email,
          name: "Email",
          onTapped: (){
            print("tapped email");
          },
          rightIconButton: RightIconButton(
            icon: Icon(
              Icons.add,
              color: Colors.green,
            ),
          ),
        ),
        new Title( 
          icon: Icons.work,
          name: "Work",
          onTapped: (){
            workOpen.value = true;
          }
        ),
        Visibility(
          visible: workOpen.value,
          child: Column(
            children: <Widget>[
              TheField(
                  focusNode: jobTitleField.focusNode, 
                  controller: jobTitleField.controller, 
                  bottomBarHeight: bottomBarHeight, 
                  nextFunction: jobTitleField.nextFunction, 
                  label: "Job title",
                ),
              TheField(
                focusNode: companyField.focusNode, 
                controller: companyField.controller, 
                bottomBarHeight: bottomBarHeight, 
                nextFunction: companyField.nextFunction, 
                label: "Company",
              ),
            ],
          ),
        ),
        new Title( 
          icon: Icons.location_on,
          name: "Address",
          onTapped: (){
            print("tapped address");
          },
          rightIconButton: RightIconButton(
            icon: Icon(
              Icons.add,
              color: Colors.green,
            ),
          ),
        ),
        new Title( 
          icon: Icons.note,
          name: "Note",
          onTapped: (){
            noteOpen.value = true;
          }
        ),
        Visibility(
          visible: noteOpen.value,
          child: TheField(
            focusNode: noteField.focusNode, 
            controller: noteField.controller, 
            bottomBarHeight: bottomBarHeight, 
            nextFunction: noteField.nextFunction, 
            label: "Note",
          ),
        ),
      ],
    );
  }
}

class Title extends StatelessWidget {
  final IconData icon;
  final String name;
  final Function onTapped;
  final Widget rightIconButton;

  const Title({
    @required this.icon,
    @required this.name,
    this.onTapped,
    this.rightIconButton,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget theTitle = Container(
      //color: Colors.red,
      child: Row(
        children: <Widget>[
          LeftIcon(
            icon: icon,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Padding(
                padding: EdgeInsets.only(
                  right: (rightIconButton == null) ? titleRightPadding : 0,
                ),
                child: Text(
                  name,
                  style: TextStyle(
                    color: Theme.of(context).primaryColorLight,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
          rightIconButton ?? Container(),
        ],
      ),
    );

    //whether or not the area is clickable
    if(onTapped == null) return theTitle;
    else{
      return GestureDetector(
        onTap: onTapped,
        child: theTitle,
      );
    }
  }
}

class TheField extends StatelessWidget {
  const TheField({
    @required this.label,
    @required this.focusNode,
    @required this.controller,
    @required this.nextFunction,
    @required this.bottomBarHeight,
    this.labelField,
    this.rightIconButton,
    this.noPadding: false,
  });

  final String label;
  final FocusNode focusNode;
  final TextEditingController controller;
  final Function nextFunction;
  final double bottomBarHeight;
  final Widget labelField;
  final Widget rightIconButton;
  final bool noPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Colors.purple,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          LeftIcon(),
          Flexible(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Padding(
                padding: EdgeInsets.only(
                  right: (rightIconButton == null) 
                  ? ((noPadding) ? 0 : iconRightPadding)
                  : 0,
                ),
                child: TextFormField(
                  focusNode: focusNode,
                  controller: controller,
                  scrollPadding: EdgeInsets.only(bottom: bottomBarHeight * 2 + 8),
                  autofocus: true,
                  style: TextStyle(
                    fontSize: 18,
                  ),
                  onEditingComplete: (nextFunction == null)
                  ? null
                  : (){
                    nextFunction();
                  },
                  textInputAction: (nextFunction == null)
                  ? TextInputAction.done
                  : TextInputAction.next,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(bottom: 4),
                    hintText: label,
                    hintStyle: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),
          labelField ?? Container(),
          rightIconButton ?? Container(),
        ],
      ),
    );
  }
}

class CategorySelector extends StatelessWidget {
  CategorySelector({
    @required this.labelType,
  });

  final LabelType labelType;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: (){
          Navigator.push(
            context, PageTransition(
              type: PageTransitionType.downToUp,
              child: CategorySelectionPage(
                labelType: labelType,
              ),
            ),
          );
        },
        child: Container(
          width: 86,
          height: 8 + 32.0 + 8,
          alignment: Alignment.bottomCenter,
          padding: EdgeInsets.only(
            left: 16,
            bottom: 11,
          ),
          child: Container(
            width: 78,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).primaryColorLight,
                )
              )
            ),
            child: Text(
              "Mobile",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//-------------------------CAN OPTIMIZE-------------------------

class LeftIcon extends StatelessWidget {
  final IconData icon;

  LeftIcon({
    this.icon,
  });

  @override
  Widget build(BuildContext context) { 
    Color iconColor;
    if(icon == null){
      iconColor = Colors.transparent;
    }
    else{
      iconColor = Theme.of(context).primaryColorLight;
    }

    //return widget
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
      ),
      child: SizedBox(
        width: 24,
        child: Icon(
          icon ?? Icons.lock,
          color: iconColor,
        ),
      ),
    );
  }
}

class RightIconButton extends StatelessWidget {
  RightIconButton({
    @required this.icon,
    this.onTapped,
    this.height,
  });

  final Icon icon;
  final Function onTapped;
  final double height;

  @override
  Widget build(BuildContext context) {
    Widget child = Container(
      //color: Colors.grey,
      height: 8 + 8 + 32.0,
      padding: EdgeInsets.symmetric(
        horizontal: iconRightPadding,
        vertical: 0,
      ),
      child: SizedBox(
        child: Container(
          //color: Colors.blue,
          child: SizedBox(
            width: 24,
            height: 24,
            child: icon,
          ),
        ),
      ),
    );

    //button or no button
    if(onTapped == null){
      return child;
    }
    else{
      return GestureDetector(
        onTap: onTapped,
        child: child,
      );
    } 
  }
}