import 'dart:math';

class Subnet {
  String networkAddress;
  String broadcastAddress;
  String subnetMask;
  int subnetSize;

  Subnet(this.networkAddress, this.broadcastAddress, this.subnetMask,
      this.subnetSize);
}

String intToIp(int ip) {
  return '${(ip >> 24) & 0xFF}.${(ip >> 16) & 0xFF}.${(ip >> 8) & 0xFF}.${ip & 0xFF}';
}

int ipToInt(String ip) {
  var parts = ip.split('.').map(int.parse).toList();
  return (parts[0] << 24) + (parts[1] << 16) + (parts[2] << 8) + parts[3];
}

List<Subnet> calculateVLSM(String baseIp, int baseMask, List<int> hosts) {
  hosts.sort((a, b) => b.compareTo(a)); // Ordenar de mayor a menor
  List<Subnet> subnets = [];
  int baseIpInt = ipToInt(baseIp);
  int currentIpInt = baseIpInt;

  for (int host in hosts) {
    int requiredHosts = host + 2; // Hosts + Network + Broadcast
    int subnetBits = (log(requiredHosts) / log(2)).ceil();
    int subnetMask = 32 - subnetBits;
    int subnetSize = pow(2, subnetBits).toInt();

    String networkAddress = intToIp(currentIpInt);
    String broadcastAddress = intToIp(currentIpInt + subnetSize - 1);
    String subnetMaskStr = intToIp(~((1 << (32 - subnetMask)) - 1));

    subnets.add(
        Subnet(networkAddress, broadcastAddress, subnetMaskStr, subnetSize));

    currentIpInt += subnetSize;
  }

  return subnets;
}

void main() {
  String baseIp = '192.168.1.0';
  int baseMask = 24;
  List<int> hosts = [100, 10];

  List<Subnet> subnets = calculateVLSM(baseIp, baseMask, hosts);

  for (var subnet in subnets) {
    print('Network Address: ${subnet.networkAddress}');
    print('Broadcast Address: ${subnet.broadcastAddress}');
    print('Subnet Mask: ${subnet.subnetMask}');
    print('Subnet Size: ${subnet.subnetSize}');
    print('---');
  }
}
