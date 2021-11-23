import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = 'https://api.hgbrasil.com/finance?format=json&key=fc93c534';

void main() async {
  runApp(MaterialApp(
    home: const HomePage(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(Uri.parse(request));
  return json.decode(response.body);
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double? dolar;
  double? euro;

  void _clearAll(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  void _realChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double dReal = double.parse(text);
    dolarController.text = (dReal / (dolar ?? 0)).toStringAsFixed(2);
    euroController.text = (dReal / (euro ?? 0)).toStringAsFixed(2);
  }

  void _dolarChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double dDolar = double.parse(text);
    realController.text = (dDolar * (this.dolar ?? 0)).toStringAsFixed(2);
    euroController.text = ((dDolar * (this.dolar ?? 0)) / (euro ?? 0)).toStringAsFixed(2);
  }

  void _euroChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro * (this.euro ?? 0)).toStringAsFixed(2);
    dolarController.text = ((euro * (this.euro ?? 0)) / (this.dolar ?? 0)).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('\$Conversor\$'),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(
                child: Text(
                  'Carregando dados...',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 25,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Erro ao obter dados: ${snapshot.error!.toString()}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 25,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dolar =
                    snapshot.data!['results']['currencies']['USD']['buy'] ?? 0;
                euro =
                    snapshot.data!['results']['currencies']['EUR']['buy'] ?? 0;

                return SingleChildScrollView(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        size: 150,
                        color: Colors.amber,
                      ),
                      const Divider(),
                      getCampo('Reais', 'R\$ ', realController, _realChanged),
                      const Divider(),
                      getCampo('Dolares', 'US\$ ', dolarController, _dolarChanged),
                      const Divider(),
                      getCampo('Euros', '€ ', euroController, _euroChanged),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget getCampo(String label, String prefix, TextEditingController controller, Function f){
  return TextField(
    keyboardType: TextInputType.numberWithOptions(decimal: true),
    controller: controller,
    cursorColor: Colors.amber,
    style: TextStyle(
      color: Colors.amber,
    ),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.amber),
      border: const OutlineInputBorder(),
      prefixText: prefix,
    ),

    onChanged: (text) {
      f(text);
    },
  );
}