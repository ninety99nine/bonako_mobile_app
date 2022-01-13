import 'package:flutter/material.dart';

class CustomMultiWidgetSeparator extends StatelessWidget {

  final separator;
  final List texts;
  final EdgeInsetsGeometry separatorMargin;

  CustomMultiWidgetSeparator({ 
    this.texts = const [], 
    this.separator = '|', 
    this.separatorMargin = const EdgeInsets.symmetric(horizontal: 5) 
  });

  List<Widget> multipleTextWidgets(){

    //  Filter the empty texts
    texts.removeWhere((text){

      /**
       *  If the text provided is a String
       *  E.g 'Text 1' 
       */
      if( (text is String?) ){

        return (text == '') || (text == null);

      /**
       *  If the text provided is a Map
       *  E.g {
       *    'widget': CustomWidget(text: 'Text 2'),
       *    'value': 'Text 2'
       *  }
       */
      }else if(text is Map){

        return (text['value'] == '') || (text['value'] == null);

      }

      //  Otherwise do not return it at all
      return false;

    });

    //  Initialize an empty widget list
    final List<Widget> widgets = [];

    for (var i = 0; i < texts.length; i++) {

      var result = texts[i];

      /**
       *  If the result provided is a String
       *  E.g 'Text 1' 
       */
      if( (result is String?) ){
        
        //  Add the result as a Text Widget
        widgets.add( Text(result!) );

      /**
       *  If the result provided is a Map
       *  E.g {
       *    'widget': CustomWidget(text: 'Text 2'),
       *    'value': 'Text 2'
       *  }
       */
      }else if(result is Map){
        
        //  Add the result as a Text Widget
        widgets.add( result['widget'] );

      }

      //  If this is not the last item on the list
      if( (i + 1) < texts.length){

        //  Add a separator
        widgets.add(
          Container(
            margin: separatorMargin,
            child: (separator is Widget) ? separator : Text('|', style: TextStyle(color: Colors.grey),),
          )
        );

      }

    }

    return widgets;

  }

  @override
  Widget build(BuildContext context) {

    return Row(
      children: [
        ...multipleTextWidgets()
      ],
    );
  }
}