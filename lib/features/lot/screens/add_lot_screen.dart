import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/lot/bloc/lot_bloc.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';

class AddLotScreen extends StatelessWidget {
  AddLotScreen({super.key});

  final lotCategoryController = TextEditingController();
  final tcpController = TextEditingController();
  final blockLotNumberController = TextEditingController();
  final lotDescriptionController = TextEditingController();
  final areaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final lotBloc = BlocProvider.of<LotBloc>(context);
    lotBloc.initialize();

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lot category',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(
            height: 8,
          ),
          SizedBox(
            width: double.infinity,
            child: BlocBuilder<LotBloc, LotState>(
              builder: (context, state) {
                String dropdownValue = lotBloc.lotCategories.first;

                if (state is SelectedLotCategoryLotState) {
                  dropdownValue = state.selectedLotCategory;
                }

                return DropdownButton<String>(
                  value: dropdownValue,
                  items: lotBloc.lotCategories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) => lotBloc.selectLotCategory(
                    lotCategory: value,
                  ),
                );
              },
            ),
          ),
          const SizedBox(
            height: 32,
          ),
          TextFormField(
            controller: tcpController,
            decoration: InputDecoration(
              label: Text('Total contract price'),
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
            ],
          ),
          const SizedBox(
            height: 32,
          ),
          TextFormField(
            controller: areaController,
            decoration: InputDecoration(
              label: Text('Area'),
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
            ],
          ),
          SizedBox(
            height: 32,
          ),
          TextFormField(
            controller: blockLotNumberController,
            decoration: InputDecoration(
                label: Text('Block and lot numbers'),
                border: OutlineInputBorder()),
          ),
          SizedBox(
            height: 32,
          ),
          TextFormField(
            controller: lotDescriptionController,
            maxLines: 8,
            decoration: InputDecoration(
                label: Text('Lot description'), border: OutlineInputBorder()),
          ),
          SizedBox(
            height: 96,
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => lotBloc.addLot(
                      lotCategory: lotCategoryController.text,
                      totalContractPrice: tcpController.text,
                      area: areaController.text,
                      blockLotNos: blockLotNumberController.text,
                      description: lotDescriptionController.text),
                  style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(24),
                      backgroundColor: Theme.of(context).colorScheme.primary, ),
                  child: Text(
                    'Add lot',
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
