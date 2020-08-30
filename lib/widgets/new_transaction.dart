import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:module_2/widgets/adaptive_flat_button.dart';

class NewTransaction extends StatefulWidget {
  final Function newTx;

  NewTransaction(this.newTx);

  @override
  _NewTransactionState createState() => _NewTransactionState();
}

class _NewTransactionState extends State<NewTransaction> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  DateTime _chosenDate;

  void _onSubmitted() {
    if (_amountController.text.isEmpty) return;
    final title = _titleController.text;
    final amount = double.parse(_amountController.text);
    if (title.isEmpty || amount <= 0 || _chosenDate == null) return;

    widget.newTx(title, amount, _chosenDate);

    Navigator.of(context).pop();
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ).then((date) {
      if (date == null) return;
      setState(() {
        _chosenDate = date;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          top: 10,
          left: 10,
          right: 10,
          bottom: MediaQuery.of(context).viewInsets.bottom + 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            // Text field (title)
            TextField(
              decoration: InputDecoration(labelText: 'Title'),
              controller: _titleController,
              onSubmitted: (_) => _onSubmitted(),
            ),
            // Text field (amount)
            TextField(
              decoration: InputDecoration(labelText: 'Amount'),
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onSubmitted: (_) => _onSubmitted(),
            ),
            Container(
              height: 70,
              child: Row(
                children: [
                  Expanded(
                    child: Text(_chosenDate == null
                        ? 'No date chosen!'
                        : 'Chosen date: ${DateFormat.yMd().format(_chosenDate)}'),
                  ),
                  // Choose date button
                  AdaptiveFlatButton('Choose date: ', _presentDatePicker),
                ],
              ),
            ),

            // Add Transaction button
            FlatButton(
              child: Text('Add Transaction'),
              color: Theme.of(context).primaryColor,
              textColor: Theme.of(context).textTheme.button.color,
              onPressed: _onSubmitted,
            ),
          ],
        ),
      ),
    );
  }
}
