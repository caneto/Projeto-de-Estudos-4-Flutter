import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

var request = Uri.parse('https://api.hgbrasil.com/finance?format=json&key=xxxxxxxx'); /// xxxxxx = sua key do site

void main() async {

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: const InputDecorationTheme(
          enabledBorder:
          OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
          OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  late double dolar;
  late double euro;

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
    double real = double.parse(text);
    dolarController.text = (real/dolar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text("\$ Conversor de Moedas \$"),
          backgroundColor: Colors.amber,
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              onPressed: _clearAll,
              icon: Icon(Icons.refresh),
            )
          ],
        ),
        body: FutureBuilder<Map>(
          future: getData(),
          builder: (context,snapshot) {
            switch(snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return const Center(
                  child: Text("Carregando Dados...",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ),
                );
              default:
                if(snapshot.hasError){
                  return const Center(
                    child: Text("Erro ao Carregando Dados :(...",
                      style: TextStyle(
                          color: Colors.amber,
                          fontSize: 25.0),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  dolar = snapshot.data!["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data!["results"]["currencies"]["EUR"]["buy"];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const Icon(Icons.monetization_on,size: 150.0,color: Colors.amber),
                        buildTextField("Reais", "R\$", realController, _realChanged),
                        const Divider(),
                        buildTextField("D??lares", "US\$", dolarController, _dolarChanged),
                        const Divider(),
                        buildTextField("Euros", "???", euroController, _euroChanged),
                      ],
                    ),
                  );
                }
            }
          },
        )
    );
  }
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

Widget buildTextField(String label, String prefix, TextEditingController controller, Function f){
  return TextField(
    controller: controller,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.amber),
        border: const OutlineInputBorder(),
        prefixText: prefix
    ),
    style: const TextStyle(
        color: Colors.amber, fontSize: 25.0
    ),
    onChanged: (texto) {
      f(texto);
    },
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
  );
}
