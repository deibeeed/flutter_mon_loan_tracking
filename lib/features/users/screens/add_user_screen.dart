import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddUserScreen extends StatelessWidget {
  const AddUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(
                label: Text('Last name'),
                border: OutlineInputBorder()
            ),
          ),
          SizedBox(
            height: 32,
          ),
          TextFormField(
            decoration: InputDecoration(
                label: Text('First name'),
                border: OutlineInputBorder()
            ),
          ),
          SizedBox(
            height: 32,
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    label: Text('Birthdate'),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(width: 32,),
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    label: Text('Civil status'),
                    border: OutlineInputBorder(),),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 32,
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    label: Text('Email'),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(width: 32,),
              Expanded(
                child: TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    label: Text('Password'),
                    border: OutlineInputBorder(),),
                ),
              ),
              SizedBox(width: 32,),
              Expanded(
                child: TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    label: Text('Confirm password'),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 32,
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => print('pressed'),
                  style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(24),
                      backgroundColor: Theme.of(context).colorScheme.primary),
                  child: Text(
                    'Add User',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.apply(color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

}