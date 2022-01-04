import 'package:bonako_mobile_app/components/custom_loader.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:async';

class Debouncer {
  final int milliseconds;
  var _timer;

  Debouncer({ this.milliseconds = 500 });

  run(VoidCallback action) {
    if (null != _timer) {
      (_timer as Timer).cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

class CustomSearchBar extends StatefulWidget {

  final String labelText;
  final String helperText;
  final Function onSearch;
  final EdgeInsetsGeometry margin;

  CustomSearchBar({ this.labelText: '', this.helperText: '', required this.onSearch, this.margin = const EdgeInsets.only(top: 10) });

  @override
  _CustomSearchBarState createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {

  var isLoading = false;

  void startLoader(){
    if(mounted){
      setState(() {
        isLoading = true;
      });
    }
  }

  void stopLoader(){
    if(mounted){
      setState(() {
        isLoading = false;
      });
    }
  }

  final _debouncer = Debouncer();
  TextEditingController searchWordController = new TextEditingController();

  @override
  void initState() {
    
    searchWordController.text = '';

    super.initState();
  }

  get hasSearchWord {
    return (searchWordController.text != '');
  }

  @override
  Widget build(BuildContext context) {

    return 
      Container(
        width: double.infinity,
        margin: widget.margin,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: TextField(
                controller: searchWordController,
                decoration: InputDecoration(
                  isDense: true,
                  labelText: widget.labelText,
                  helperText: widget.helperText,
                  labelStyle: TextStyle(
                    fontSize: 12
                  ),
                  border:OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  suffixIcon: GestureDetector(
                    child: isLoading ? Container(width: 10, child: CustomLoader(topMargin:0, size: 10, strokeWidth: 2.0)) : Icon(hasSearchWord ? Icons.cancel : Icons.search),
                    onTap: (){
                      if(hasSearchWord){
                        searchWordController.clear();
                        widget.onSearch(searchWordController.text);
                      }
                    },
                  )
                ),
                onChanged: (searchWord){
                  _debouncer.run(() {
                    startLoader();
                    (widget.onSearch(searchWord) as Future<http.Response>).whenComplete((){
                      stopLoader();
                    });
                  });
                },
              ),
            )
          ],
        ),
      );
  }
}