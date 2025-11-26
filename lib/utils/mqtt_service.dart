import 'dart:convert';
import 'dart:io';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:mqtt5_client/mqtt5_server_client.dart';

class MqttService {
  late MqttServerClient client;
  final clientId = 'flutter1';
  final String broker = "vcf1fa18.ala.us-east-1.emqxsl.com";
  final int port = 8883;
  final String username = "emqx_online_test_1a611861";
  final String password = "031ff86Q?496T6bbP\$0e&2b61KG3b64e";

  Future<void> connect() async {
    client = MqttServerClient(broker, clientId);
    client.port = port;
    client.secure = true;
    client.logging(on: false);

    // Usa el certificado raíz (igual al de tu ESP32)
    final context = SecurityContext.defaultContext;
    context.setTrustedCertificatesBytes(_caCertificate.codeUnits);
    client.securityContext = context;

    client.keepAlivePeriod = 20;
    client.onDisconnected = onDisconnected;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .authenticateAs(username, password)
        .startClean(); // nada más

    client.connectionMessage = connMessage;

    try {
      print("🔌 Conectando al broker...");
      await client.connect();
      print("✅ Conectado!");
    } catch (e) {
      print("❌ Error conectando: $e");
      client.disconnect();
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print("⚡ Suscribiendo al tópico...");
      client.subscribe("hydrolink/entry", MqttQos.atLeastOnce);

      client.updates.listen((messages) {
        final recMess = messages[0].payload as MqttPublishMessage;
        final payload = MqttUtilities.bytesToStringAsString(
          recMess.payload.message!,
        );

        print("📩 Mensaje recibido: $payload en ${messages[0].topic}");
      });
    }
  }

  void publish(String topic, String message) {
    final builder = MqttPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  void publishJson(String topic, Map<String, dynamic> data) {
    final builder = MqttPayloadBuilder();
    final jsonString = jsonEncode(data);
    builder.addString(jsonString);
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  void onDisconnected() {
    print("🔌 Desconectado del broker");
  }

  static const String _caCertificate = """
-----BEGIN CERTIFICATE-----
MIIDjjCCAnagAwIBAgIQAzrx5qcRqaC7KGSxHQn65TANBgkqhkiG9w0BAQsFADBh
MQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3
d3cuZGlnaWNlcnQuY29tMSAwHgYDVQQDExdEaWdpQ2VydCBHbG9iYWwgUm9vdCBH
MjAeFw0xMzA4MDExMjAwMDBaFw0zODAxMTUxMjAwMDBaMGExCzAJBgNVBAYTAlVT
MRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5j
b20xIDAeBgNVBAMTF0RpZ2lDZXJ0IEdsb2JhbCBSb290IEcyMIIBIjANBgkqhkiG
9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuzfNNNx7a8myaJCtSnX/RrohCgiN9RlUyfuI
2/Ou8jqJkTx65qsGGmvPrC3oXgkkRLpimn7Wo6h+4FR1IAWsULecYxpsMNzaHxmx
1x7e/dfgy5SDN67sH0NO3Xss0r0upS/kqbitOtSZpLYl6ZtrAGCSYP9PIUkY92eQ
q2EGnI/yuum06ZIya7XzV+hdG82MHauVBJVJ8zUtluNJbd134/tJS7SsVQepj5Wz
tCO7TG1F8PapspUwtP1MVYwnSlcUfIKdzXOS0xZKBgyMUNGPHgm+F6HmIcr9g+UQ
vIOlCsRnKPZzFBQ9RnbDhxSJITRNrw9FDKZJobq7nMWxM4MphQIDAQABo0IwQDAP
BgNVHRMBAf8EBTADAQH/MA4GA1UdDwEB/wQEAwIBhjAdBgNVHQ4EFgQUTiJUIBiV
5uNu5g/6+rkS7QYXjzkwDQYJKoZIhvcNAQELBQADggEBAGBnKJRvDkhj6zHd6mcY
1Yl9PMWLSn/pvtsrF9+wX3N3KjITOYFnQoQj8kVnNeyIv/iPsGEMNKSuIEyExtv4
NeF22d+mQrvHRAiGfzZ0JFrabA0UWTW98kndth/Jsw1HKj2ZL7tcu7XUIOGZX1NG
Fdtom/DzMNU+MeKNhJ7jitralj41E6Vf8PlwUHBHQRFXGU7Aj64GxJUTFy8bJZ91
8rGOmaFvE7FBcf6IKshPECBV1/MUReXgRPTqh5Uykw7+U0b6LJ3/iyK5S9kJRaTe
pLiaWN0bfVKfjllDiIGknibVb63dDcY3fe0Dkhvld1927jyNxF1WW6LZZm6zNTfl
MrY=
-----END CERTIFICATE-----
""";
}
