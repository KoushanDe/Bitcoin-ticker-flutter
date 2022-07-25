import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'coin_data.dart';
import 'dart:io';
import 'crypto_handler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class PriceScreen extends StatefulWidget {
  @override
  _PriceScreenState createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
  Crypto crypto = Crypto();
  String btc;
  String eth;
  String ltc;
  int loadingState = 1;
  String selectedCurr = 'USD';

  DropdownButton<String> androidDropDown() {
    List<DropdownMenuItem<String>> currencies = [];
    for (String curr in currenciesList) {
      currencies.add(new DropdownMenuItem(
        child: Text(curr),
        value: curr,
      ));
    }
    return DropdownButton<String>(
        value: selectedCurr,
        items: currencies,
        onChanged: (value) {
          setState(() {
            selectedCurr = value;
            btc = '??';
            eth = '??';
            ltc = '??';
            updateUI();
          });
        });
  }

  CupertinoPicker iosPicker() {
    List<Widget> currencies = [];
    for (String curr in currenciesList) {
      currencies.add(Text(curr));
    }
    return CupertinoPicker(
      itemExtent: 30.0,
      onSelectedItemChanged: (selectedIndex) {
        setState(() {
          selectedCurr = currenciesList[selectedIndex];
          btc = '??';
          eth = '??';
          ltc = '??';
          updateUI();
        });
      },
      children: currencies,
    );
  }

  void noNetwork() {
    btc = '??';
    eth = '??';
    ltc = '??';
    Widget okButton = ElevatedButton(
      child: Text(
        "OK",
        style: TextStyle(
          fontSize: 15.0,
        ),
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text('Unable to retrieve data'),
      content: Icon(
        Icons.wifi_off_rounded,
        size: 40.0,
      ),
      actions: [
        okButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void updateUI() async {
    loadingState = 1;
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
      }
    } on SocketException catch (_) {
      setState(() {
        loadingState = -1;
      });
      noNetwork();
      return;
    }
    var cryptoDataBTC = await crypto.getExchangeRate(selectedCurr, 'BTC');
    var cryptoDataETH = await crypto.getExchangeRate(selectedCurr, 'ETH');
    var cryptoDataLTC = await crypto.getExchangeRate(selectedCurr, 'LTC');
    setState(() {
      double rate = cryptoDataBTC['rate'];
      btc = rate.toStringAsFixed(2);
      rate = cryptoDataETH['rate'];
      eth = rate.toStringAsFixed(2);
      rate = cryptoDataLTC['rate'];
      ltc = rate.toStringAsFixed(2);
      loadingState = 0;
    });
  }

  @override
  void initState() {
    updateUI();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coin Ticker'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CryptoCard(
                crypto: 'BTC',
                cryptoCurr: btc,
                selectedCurr: selectedCurr,
                showLoading: loadingState,
              ),
              CryptoCard(
                crypto: 'ETH',
                cryptoCurr: eth,
                selectedCurr: selectedCurr,
                showLoading: loadingState,
              ),
              CryptoCard(
                crypto: 'LTC',
                cryptoCurr: ltc,
                selectedCurr: selectedCurr,
                showLoading: loadingState,
              ),
            ],
          ),
          Container(
            height: 150.0,
            alignment: Alignment.center,
            padding: EdgeInsets.only(bottom: 30.0),
            color: Colors.lightBlue,
            child: Platform.isIOS ? iosPicker() : androidDropDown(),
          ),
        ],
      ),
    );
  }
}

class CryptoCard extends StatelessWidget {
  const CryptoCard(
      {Key key,
      @required this.crypto,
      @required this.selectedCurr,
      @required this.cryptoCurr,
      this.showLoading})
      : super(key: key);

  final String crypto;
  final String cryptoCurr;
  final String selectedCurr;
  final int showLoading;

  Color selectSpinkitColour(int load) {
    if (load == 0)
      return Colors.lightBlueAccent;
    else if (load == 1)
      return Colors.blue[800];
    else
      return Colors.red[300];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 0),
      child: Card(
        color: Colors.lightBlueAccent,
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 28.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20.0,
              ),
              Text(
                '1 $crypto = ${cryptoCurr == null ? '??' : cryptoCurr} $selectedCurr',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.white,
                ),
              ),
              SpinKitCircle(
                color: selectSpinkitColour(showLoading),
                size: 20.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
