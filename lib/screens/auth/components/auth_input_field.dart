import 'package:flutter/material.dart';

class AuthInputField extends StatelessWidget {
  
  final String title;
  final Map serverErrors;
  final bool hidePassword;
  final String? initialValue;
  final Function(String?)? onSaved;
  final Function(String)? onChanged;
  final Function()? onTogglePasswordVisibility;

  AuthInputField({ 
    required this.title, required this.initialValue, required this.serverErrors,
    required this.onChanged, required this.onSaved, this.hidePassword = true,
    this.onTogglePasswordVisibility
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),

          //  If an first name text field
          if(title == 'First Name')
            TextFormField(
              key: ValueKey('first_name'),
              initialValue: initialValue,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                filled: true,
                hintText: 'Katlego',
                border: InputBorder.none,
                fillColor: Colors.black.withOpacity(0.05),
              ),
              validator: (value){
                if(value == null || value.isEmpty){
                  return 'Please enter your first name';
                }else if(serverErrors.containsKey('first_name')){
                  return serverErrors['first_name'];
                }
              },
              onChanged: (value){
                if( onChanged != null ){
                  onChanged!(value);
                }
              },
              onSaved: (value){
                if( onSaved != null ){
                  onSaved!(value);
                }
              },
            ),

          //  If an last name text field
          if(title == 'Last Name')
            TextFormField(
              key: ValueKey('last_name'),
              initialValue: initialValue,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                filled: true,
                hintText: 'Warona',
                border: InputBorder.none,
                fillColor: Colors.black.withOpacity(0.05),
              ),
              validator: (value){
                if(value == null || value.isEmpty){
                  return 'Please enter your last name';
                }else if(serverErrors.containsKey('last_name')){
                  return serverErrors['last_name'];
                }
              },
              onChanged: (value){
                if( onChanged != null ){
                  onChanged!(value);
                }
              },
              onSaved: (value){
                if( onSaved != null ){
                  onSaved!(value);
                }
              },
            ),

          //  If a mobile text field
          if(title == 'Mobile')
            TextFormField(
              key: ValueKey('mobile'),
              initialValue: initialValue,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'e.g 72000123',
                border: InputBorder.none,
                  fillColor: Colors.black.withOpacity(0.05),
                filled: true
              ),
              validator: (value){
                if(value == null || value.isEmpty){
                  return 'Please enter your mobile number';
                }else if(value.length != 8 && value.length != 11){
                  return 'Please enter a valid 8 digit mobile number e.g 72000123';
                }else if(value.toString().startsWith('7') == false && value.toString().startsWith('267') == false){
                  return 'Please enter a valid mobile number e.g 72000123';
                }else if(serverErrors['mobile_number'] != ''){
                  return serverErrors['mobile_number'];
                }
              },
              onChanged: (value){
                if( onChanged != null ){
                  onChanged!(value);
                }
              },
              onSaved: (value){
                if( onSaved != null ){
                  onSaved!(value);
                }
              },
            ),

          //  If a password text field
          if(title == 'Password')
            TextFormField(
              key: ValueKey('password'),
              initialValue: initialValue,
              keyboardType: TextInputType.text,
              obscureText: hidePassword,
              decoration: InputDecoration(
                  fillColor: Colors.black.withOpacity(0.05),
                border: InputBorder.none,
                filled: true,
                suffixIcon: IconButton(
                  icon: Icon(
                    // Based on hidePassword state choose the icon
                    hidePassword ? Icons.visibility : Icons.visibility_off,
                    color: Theme.of(context).primaryColorDark,
                  ),
                  onPressed: onTogglePasswordVisibility,
                ),
              ),
              validator: (value){
                if(value == null || value.isEmpty){
                  return 'Please enter your password';
                }else if(serverErrors.containsKey('password')){
                  return serverErrors['password'];
                }
              },
              onChanged: (value){
                if( onChanged != null ){
                  onChanged!(value);
                }
              },
              onSaved: (value){
                if( onSaved != null ){
                  onSaved!(value);
                }
              },
            ),

          //  If a password text field
          if(title == 'Confirm Password')
            TextFormField(
              key: ValueKey('confirm_password'),
              initialValue: initialValue,
              keyboardType: TextInputType.text,
              obscureText: hidePassword,
              decoration: InputDecoration(
                  fillColor: Colors.black.withOpacity(0.05),
                border: InputBorder.none,
                filled: true,
                suffixIcon: IconButton(
                  icon: Icon(
                    // Based on hidePassword state choose the icon
                    hidePassword ? Icons.visibility : Icons.visibility_off,
                    color: Theme.of(context).primaryColorDark,
                  ),
                  onPressed: onTogglePasswordVisibility,
                ),
              ),
              validator: (value){
                if(value == null || value.isEmpty){
                  return 'Please confirm your password';
                }else if(serverErrors.containsKey('password_confirmation')){
                  return serverErrors['password_confirmation'];
                }
              },
              onChanged: (value){
                if( onChanged != null ){
                  onChanged!(value);
                }
              },
              onSaved: (value){
                if( onSaved != null ){
                  onSaved!(value);
                }
              },
            ),

        ],
      ),
    );
  }
}
