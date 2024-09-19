import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:redesv2/vlsm2.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
        useMaterial3: true,
        textTheme: GoogleFonts.robotoTextTheme(),
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Geberacion de direcciones IP VLSM'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _maskController = TextEditingController();
  final TextEditingController _cantidadHosts = TextEditingController();
  List<String> listadireccionesRed = [];
  List<String> listadireccionesDifucion = [];
  List<String> aux = [];
  List<String> listacantidadHosts = [];
  List<Subnet> subnets = [];
  List<String> letras = [];

  void mensajeError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
      ),
    );
  }

  void ordenRedesLetras() {
    List<MapEntry<String, int>> hostsWithLetters = listacantidadHosts
        .asMap()
        .entries
        .map((entry) => MapEntry(
            String.fromCharCode(97 + entry.key), int.parse(entry.value)))
        .toList();

    hostsWithLetters.sort((a, b) => b.value.compareTo(a.value));

    letras = hostsWithLetters.map((entry) => entry.key).toList();
  }

  void mensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.blue,
      ),
    );
  }

  /// Funcion que ejecuta el calculo de las subredes
  /// Aqui se obtiene la direccion de red, direccion de difucion, mascara de red
  /// y cantidad de direcciones.
  /// Ademas de las validaciones de los campos de texto
  void ejecutar() {
    if (_ipController.text.isEmpty ||
        _maskController.text.isEmpty ||
        _cantidadHosts.text.isEmpty) {
      mensajeError('Por favor, complete todos los campos.');
      return;
    }
    if (int.parse(_maskController.text) < 0 ||
        int.parse(_maskController.text) > 32) {
      mensajeError('La mascara de red es incorrecta ${_maskController.text}');
      return;
    }
    int auxH = 0;
    for (var element in listacantidadHosts) {
      auxH += int.parse(element);
    }
    if (auxH > pow(2, 32 - int.parse(_maskController.text))) {
      mensajeError(
          'Se exedio la cantidad de usuarios para esta mascara de red ${_maskController.text}, solicitados: $auxH, disponibles: ${pow(2, 32 - int.parse(_maskController.text))}');
      return;
    }
    setState(() {
      subnets = calculateVLSM(
          _ipController.text,
          int.parse(_maskController.text),
          listacantidadHosts.map(int.parse).toList());
    });
    mensaje('Subredes generadas correctamente');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  "Captura los datos de la red/s",
                  style: TextStyle(fontSize: 25),
                ),
                Container(
                  padding: const EdgeInsets.all(1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.all(10),
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _ipController,
                              decoration: const InputDecoration(
                                  labelText: "Direccion IP",
                                  hintText: "Ejem: 192.168.0.0"),
                            ),
                            TextFormField(
                              controller: _maskController,
                              decoration: const InputDecoration(
                                labelText: "Mascara de red",
                                hintText: "Ejem: 24",
                              ),
                            ),
                            /*TextFormField(
                              controller: _cantidadSubredes,
                              decoration: const InputDecoration(
                                labelText: "Cantidad de subredes",
                                hintText: "Ejem: 4",
                              ),
                            ),*/
                            TextFormField(
                              controller: _cantidadHosts,
                              decoration: const InputDecoration(
                                labelText: "Cantidad de hosts",
                                hintText:
                                    "Ejem: 100, 50, 25, 10 o 500,10,1000,15",
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(20),
                        width: MediaQuery.of(context).size.width * 0.55,
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: Table(
                          border: const TableBorder.symmetric(
                            inside: BorderSide(color: Colors.black),
                          ),
                          children: [
                            TableRow(
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                    border: Border.all(color: Colors.black),
                                    borderRadius: BorderRadius.circular(8)),
                                children: const [
                                  Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      "Subred",
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Text("Direccion de red",
                                        textAlign: TextAlign.center),
                                  ),
                                  Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Text("Direccion de broadcast",
                                          textAlign: TextAlign.center)),
                                  Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Text("Mascara de red",
                                          textAlign: TextAlign.center)),
                                  Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Text("Cantidad de direcciones",
                                          textAlign: TextAlign.center)),
                                ]),
                            for (var i = 0; i < listacantidadHosts.length; i++)
                              TableRow(children: [
                                Text("Subred ${letras[i]}"),
                                Text(subnets[i].networkAddress),
                                Text(subnets[i].broadcastAddress),
                                Text(subnets[i].subnetMask),
                                Text(subnets[i].subnetSize.toString()),
                              ]),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(10),
                  child: ElevatedButton(
                    onPressed: () {
                      listacantidadHosts = _cantidadHosts.text.split(",");
                      ordenRedesLetras();
                      ejecutar();
                    },
                    child: const Text("Generar"),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
