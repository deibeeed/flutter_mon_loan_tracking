import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class LoanCalculatorScreen extends StatelessWidget {
  const LoanCalculatorScreen({ super.key }): super();

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
                    label: Text('Block no.'),
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
                    label: Text('Lot no.'),
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
                      label: Text('Downpayment'),
                      border: OutlineInputBorder()),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 24,
          ),
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
                    label: Text('Incidental fee'),
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
                    label: Text('Total contract price'),
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
                      label: Text('Payment terms'),
                      border: OutlineInputBorder()),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                  ],
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
                    'Calculate',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.apply(color: Colors.white),
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: 32,
          ),
          Divider(),
          SizedBox(
            height: 32,
          ),
          Text('Some computation here'),
          SizedBox(
            height: 32,
          ),
          Divider(),
          SizedBox(
            height: 32,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('result')
            ],
          )
        ],
      ),
    );
  }

}