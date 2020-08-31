import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './widgets/chart.dart';
import './widgets/new_transaction.dart';

import './widgets/transaction_list.dart';
import './models/transaction.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [
      // DeviceOrientation.portraitUp,
      // DeviceOrientation.portraitDown,
    ],
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? CupertinoApp(
            theme: CupertinoThemeData(),
          )
        : MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Personal expenses',
            home: MyHomePage(),
            theme: ThemeData(
              primarySwatch: Colors.pink,
              accentColor: Colors.amber,
              fontFamily: 'Quicksand',
              textTheme: ThemeData.light().textTheme.copyWith(
                    headline6: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    button: TextStyle(color: Colors.white),
                  ),
              appBarTheme: AppBarTheme(
                textTheme: ThemeData.light().textTheme.copyWith(
                      headline6: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              ),
            ),
          );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  final List<Transaction> _userTransactions = [];

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Add new transaction
  void _addNewTransaction(
    String txTitle,
    double txAmount,
    DateTime chosenDate,
  ) {
    final newTx = Transaction(
      id: DateTime.now().toString(),
      title: txTitle,
      amount: txAmount,
      date: chosenDate,
    );

    setState(() {
      _userTransactions.add(newTx);
    });
  }

  // Delete transaction
  void _deleteTx(String id) {
    setState(() {
      _userTransactions.removeWhere((el) => el.id == id);
    });
  }

  // Modal bottom sheet
  void _startAddNewTransaction(BuildContext context) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      isScrollControlled: true,
      context: context,
      builder: (_) {
        return GestureDetector(
          child: NewTransaction(_addNewTransaction),
          onTap: () {},
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }

  // List of 7 days transactions
  List<Transaction> get _recentTransaction {
    return _userTransactions.where(
      (tx) {
        return tx.date.isAfter(
          DateTime.now().subtract(
            Duration(days: 7),
          ),
        );
      },
    ).toList();
  }

  // Show chart switch value
  bool _showChart = false;

  // Landscape mode builder
  List<Widget> _builderLandscapeMode(
    double availableSpace,
    Container txList,
  ) {
    return [
      // Switch
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Show chart: ',
            style: Theme.of(context).textTheme.headline6,
          ),
          Switch.adaptive(
            value: _showChart,
            onChanged: (val) {
              setState(() {
                _showChart = val;
              });
            },
          ),
        ],
      ),
      // Chart or list of transactions
      _showChart
          ? Container(
              height: availableSpace * 0.7,
              child: Chart(_recentTransaction),
            )
          : txList,
    ];
  }

  // Portrait mode builder
  List<Widget> _builderPortraitMode(
    double availableSpace,
    Container txList,
  ) {
    return [
      // Chart
      Container(
        height: availableSpace * 0.3,
        child: Chart(_recentTransaction),
      ),
      // Tx list
      txList,
    ];
  }

  @override
  Widget build(BuildContext context) {
    // App bar
    final PreferredSizeWidget appBar = Platform.isIOS
        ? CupertinoNavigationBar(
            middle: Text('Personal expenses'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => _startAddNewTransaction(context),
                  child: Icon(CupertinoIcons.add),
                ),
              ],
            ),
          )
        : AppBar(
            title: Text('Personal expenses'),
            actions: [
              IconButton(
                icon: Icon(Icons.add_box),
                onPressed: () => _startAddNewTransaction(context),
              ),
            ],
          );

    // Media query
    final mediaQuery = MediaQuery.of(context);

    // Calc free height on the screen
    final availableSpace = mediaQuery.size.height -
        appBar.preferredSize.height -
        mediaQuery.padding.top;

    // Check landscape orientation
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    // List of transactions
    final txList = Container(
      height: availableSpace * 0.7,
      child: TransactionList(_userTransactions, _deleteTx),
    );

    // Application body (main page)
    final appBody = SafeArea(
      child: SingleChildScrollView(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // For landscape mode
            if (isLandscape) ..._builderLandscapeMode(availableSpace, txList),

            // For portrait mode

            // Chart
            if (!isLandscape) ..._builderPortraitMode(availableSpace, txList),
          ],
        ),
      ),
    );

    // Scaffold (Home page)
    return Platform.isIOS
        ? CupertinoPageScaffold(
            navigationBar: appBar,
            child: appBody,
          )
        : Scaffold(
            // App bar
            appBar: appBar,
            // Main page
            body: appBody,
            // Floating action button
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () => _startAddNewTransaction(context),
            ),
          );
  }
}
