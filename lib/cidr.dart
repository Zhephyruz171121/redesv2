import 'dart:math';

int bitsRed = 0;
int bitsSubRed = 0;
int bistSR = 0;
int smBase = 0;
int smGeneral = 0;
List<String> ipCad = [];
List<int> ipdec = [];
List<int> smdec = [];
List<int> smdec2 = [];
List<String> ipBin = [];
List<List<String>> ipRed = [];
List<List<String>> ipBroadcast = [];
List<String> smBin = [];

List<List> llamarCIDR(String ipE, String smE, int usersE) {
  List<List> salida = [];
  List<String> auxOctetos;
  String ip = ipE;
  auxOctetos = ip.split('.');
  String sm = smE;
  if (sm.isEmpty) {
    if (sm.isEmpty) {
      if (int.parse(auxOctetos[0]) >= 192) {
        sm = '24';
      } else if (int.parse(auxOctetos[1]) >= 172 &&
          int.parse(auxOctetos[0]) < 192) {
        sm = '16';
      } else {
        sm = '8';
      }
    }
  }

  smGeneral = int.parse(sm);

  int users = usersE;
  if (users == 0) {
  } else if (users > (pow(2, users) - 2)) {
  } else {
    calcular(ip, sm, users);
  }
  salida.add(ipRed);
  salida.add(ipBroadcast);
  return salida;
}

void calcular(String ip, String sm, int users) {
  //smBase = int.parse(sm);
  ipCad = ip.split('.');
  for (var element in ipCad) {
    ipdec.add(int.parse(element));
  }
  for (var element in ipdec) {
    ipBin.add(decimalABinario(element));
  }
  smBinario(int.parse(sm));
  for (var element in smBin) {
    smdec.add(binarioDecimal(element));
  }
  while (pow(2, bitsRed) - 2 <= users) {
    bitsRed++;
  }
  bitsSubRed = 32 - bitsRed - smBase;
  smBin = [];
  smBinario(bitsSubRed);
  for (var element in smBin) {
    smdec2.add(binarioDecimal(element));
  }
  redes(sm);
}

void smBinario(int smr) {
  int sm = 0;
  if (smr > 24) {
    sm = smr + 2;
  } else if (smr > 16) {
    sm = smr + 1;
  } else {
    sm = smr;
  }
  String binario = '';
  for (var i = 0; i <= sm + smBase; i++) {
    if (binario.length < 8) {
      binario += '1';
    } else if (binario.length == 8) {
      smBin.add(binario);
      binario = '';
    }
  }
  while (binario.length < 8) {
    if (binario.length < 8) {
      binario += '0';
    } else if (binario.length == 8) {
      smBin.add(binario);
      binario = '';
    }
  }

  smBin.add(binario);
  while (smBin.length < 4) {
    smBin.add('00000000');
  }
  //print(smBin.length);
}

String decimalABinario(int decimal) {
  String binario = decimal.toRadixString(2);
  while (binario.length < 8) {
    binario = '0$binario';
  }
  return binario;
}

int binarioDecimal(String binario) {
  int decimal = int.parse(binario, radix: 2);
  return decimal;
}

void redes(String sm) {
  String ipaux = ipBin.join();
  ipaux = ipaux.substring(0, smGeneral);
  ipaux = ipaux.padRight(32, "0");
  String aux = ipaux;
  String aux2 = "";
  String aux31 = "";
  int cont = 0;
  //int pos = 0;
  /*
  while (pos < pow(2, bitsSubRed - int.parse(sm))) {
    aux2 = aux.substring(0, bitsSubRed);
    aux2 = binarySum(aux2, cont);
    cont++;
    aux31 = aux2;
    aux2 = aux2.padRight(32, "0");
    ipRed.add(dividirCadena(aux2, 8));
    aux31 = aux31.padRight(32, "1");
    ipBroadcast.add(dividirCadena(aux31, 8));
    pos++;
  }*/
  aux2 = aux.substring(0, bitsSubRed);
  aux2 = binarySum(aux2, cont);
  cont++;
  aux31 = aux2;
  aux2 = aux2.padRight(32, "0");
  ipRed.add(dividirCadena(aux2, 8));
  aux31 = aux31.padRight(32, "1");
  ipBroadcast.add(dividirCadena(aux31, 8));
}

List binDec(List<String> lista) {
  List aux = [];
  for (var value in lista) {
    aux.add(binarioDecimal(value));
  }
  return aux;
}

String binarySum(String binary1, int cont) {
  int num1 = binarioDecimal(binary1);
  int num2 = cont;

  int sum = num1 + num2;

  return decimalABinario(sum);
}

List<String> dividirCadena(String cadena, int tamanoSubcadena) {
  List<String> subcadenas = [];
  for (int i = 0; i < cadena.length; i += tamanoSubcadena) {
    int finalIndex = i + tamanoSubcadena;
    if (finalIndex > cadena.length) {
      finalIndex = cadena.length;
    }
    subcadenas.add(cadena.substring(i, finalIndex));
  }
  return subcadenas;
}
