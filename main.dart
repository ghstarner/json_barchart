import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:charts_flutter/flutter.dart' as charts;

class Load {
  final double oneMin;
  final double fiveMin;
  final double fifteenMin;

  Load({this.oneMin, this.fiveMin, this.fifteenMin});

  Load.fromJson(Map<String, dynamic> json) :
        oneMin = json['oneMin'],
        fiveMin = json['fiveMin'],
        fifteenMin = json['fifteenMin'];

}

class LoadPerInterval {
  final int minutes;
  final double load;

  LoadPerInterval(this.minutes, this.load);
}

Widget _createBarChart(Load l) {
  final data = <LoadPerInterval>[
    LoadPerInterval(1, l.oneMin),
    LoadPerInterval(5, l.fiveMin),
    LoadPerInterval(15, l.fifteenMin),
  ];

  final List<charts.Series<LoadPerInterval, String>> seriesList =  [
    charts.Series<LoadPerInterval, String>(
      id: 'Load',
      colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      domainFn: (LoadPerInterval l, _) => l.minutes.toString(),
      measureFn: (LoadPerInterval l, _) => l.load,
      data: data,
    )
  ];

  final chart = charts.BarChart(
    seriesList,
    animate: false,
  );

  final chartWidget = Padding(
    padding: EdgeInsets.all(32.0),
    child: SizedBox(
      height: 200.0,
      child: chart,
    ),
  );

  return chartWidget;
}

void main() => runApp(JsonBarChartEx());

class JsonBarChartEx extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => JsonBarChartExState();
}

class JsonBarChartExState extends State<JsonBarChartEx> {
  bool isLoading = false;
  Load linuxLoad;

  @override
  void initState() {
    super.initState();

    _fetchLoad();
  }

  _fetchLoad() async {
    setState(() {
      isLoading = true;
    });

    http.Response response;

    try {
      response = await http.get('http://10.0.2.2:5000/load');
    }  catch(e) {
      print(e);
      return;
    }

    if (response.statusCode == 200) {
      setState(() {
        linuxLoad = Load.fromJson(json.decode(response.body));
        isLoading = false;
      }
      );
    } else {
      print('Invalid status code: ' + response.statusCode.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JSON Text Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('JSON Barchart Example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              linuxLoad != null ?
              _createBarChart(linuxLoad) : Container(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: isLoading ?
                CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation(Colors.black),
                ) :
                RaisedButton(
                    onPressed: _fetchLoad,
                    child: Text(
                      'Refresh',
                      style: TextStyle(fontSize: 20),
                    )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
