import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;//requisiçao http
import 'dart:async'; //requisiçao assincrona
import 'dart:convert'; //transforma dados em json
import 'dart: ffi';

//constante
const request = "https://api.hgbrasil.com/finance?format=json&key=9a31ddf6";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(//tema do app geral
      hintColor: Colors.amber,
      primaryColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder:
        OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        focusedBorder:
        OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
        hintStyle: TextStyle(color: Colors.amber),
    )),
  ));
}

//retorna um dado atualizado
Future<Map> getData() async {
  http.Response response = await http.get(request);//get na api
  return json.decode(response.body);
}
//comando stful
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  //final não vai mudar > controldores = manipular dados digitados
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar;
  double euro;

  void _clearAll(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  //mudança no campo já atualiza os demais
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

  //estrutura visual do app
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$ Conversor \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
          future: getData(), //costruindo tela com os dados
          builder: (context, snapshot) {
            switch(snapshot.connectionState){//opções de status da conexao
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                    child: Text("Carregando Dados...",
                      style: TextStyle(
                          color: Colors.amber,
                          fontSize: 25.0),
                    textAlign: TextAlign.center,)
                );
              default:
                if(snapshot.hasError){
                  return Center(
                      child: Text("Erro ao Carregar Dados :(",
                        style: TextStyle(
                            color: Colors.amber,
                            fontSize: 25.0),
                        textAlign: TextAlign.center,)
                  );
                } else {
                  dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];//caminho > dado especifico json
                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                  return SingleChildScrollView( //scroll
                    padding: EdgeInsets.all(10.0),
                    child: Column( //filho de scroll - item na vertical
                      crossAxisAlignment: CrossAxisAlignment.stretch, //alinhamento coluna
                      children: <Widget>[ //filho de column
                        Icon(Icons.monetization_on, size: 150.0, color: Colors.amber),
                        buildTextField("Reais", "R\$", realController, _realChanged),
                        Divider(),
                        buildTextField("Dólares", "US\$", dolarController, _dolarChanged),
                        Divider(),
                        buildTextField("Euros", "€", euroController, _euroChanged),
                      ],
                    ),
                  );
                }
            }
          })
    );
  }
}
//funcao de config texto
//O controlador é anexado ao TextField e nos permite ouvir e controlar o texto do TextField também. obs: dar controle ao widget pai sobre o estado do seu filho.
Widget buildTextField(String label, String prefix, TextEditingController c, Function f){
  return TextField(
    controller: c,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefix
    ),
    style: TextStyle(
        color: Colors.amber, fontSize: 25.0
    ),
    onChanged: f,
    keyboardType: TextInputType.numberWithOptions(decimal: true),//tipo de input de dados decimal
  );
}









