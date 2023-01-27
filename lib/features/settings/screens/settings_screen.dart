import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key}) : super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                      label: Text('Loan interest rate'),
                      suffixText: '%',
                      border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                  ],
                ),
              ),
              SizedBox(width: 32,),
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                      label: Text('Incidental fee rate'),
                      suffixText: '%',
                      border: OutlineInputBorder(),),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                  ],
                ),
              ),
              SizedBox(width: 32,),
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                      label: Text('Reservation fee'),
                      border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                  ],
                ),
              ),
              SizedBox(width: 32,),
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                      label: Text('Lot categories'),
                      border: OutlineInputBorder()),
                ),
              ),
            ],
          ),
          SizedBox(height: 56,),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => print('pressed'),
                  style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(24),
                      backgroundColor: Theme.of(context).colorScheme.primary),
                  child: Text(
                    'Update settings',
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
