import 'package:redesv2/CIDR.dart';

List<String> direccionesRed = [];
List<String> direccionesDifucion = [];
List<String> capacidadRed = [];

List<String> vlsm(String ip, String sm, int subredes, List<int> hosts) {
  List<String> lista = [];
  for (var element in hosts) {
    lista.addAll(llamarCIDR(ip, sm, element));
  }

  return lista;
}

String decimalABinario(int decimal) {
  String binario = decimal.toRadixString(2);
  while (binario.length < 8) {
    binario = '0$binario';
  }
  return binario;
}
