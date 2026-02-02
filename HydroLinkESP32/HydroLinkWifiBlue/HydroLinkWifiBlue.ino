//WIFI
#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <PubSubClient.h>
//Tiempo
#include <time.h>
//Bluetooth
#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
//Convertir a json
#include <ArduinoJson.h>
//Para el sensor dth11 de la humedad y temperatura
#include "DHT.h"

//Certificado para concectarse a mqtt
const char* ca_cert =
"-----BEGIN CERTIFICATE-----\n"
"MIIDjjCCAnagAwIBAgIQAzrx5qcRqaC7KGSxHQn65TANBgkqhkiG9w0BAQsFADBh\n"
"MQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3\n"
"d3cuZGlnaWNlcnQuY29tMSAwHgYDVQQDExdEaWdpQ2VydCBHbG9iYWwgUm9vdCBH\n"
"MjAeFw0xMzA4MDExMjAwMDBaFw0zODAxMTUxMjAwMDBaMGExCzAJBgNVBAYTAlVT\n"
"MRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5j\n"
"b20xIDAeBgNVBAMTF0RpZ2lDZXJ0IEdsb2JhbCBSb290IEcyMIIBIjANBgkqhkiG\n"
"9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuzfNNNx7a8myaJCtSnX/RrohCgiN9RlUyfuI\n"
"2/Ou8jqJkTx65qsGGmvPrC3oXgkkRLpimn7Wo6h+4FR1IAWsULecYxpsMNzaHxmx\n"
"1x7e/dfgy5SDN67sH0NO3Xss0r0upS/kqbitOtSZpLYl6ZtrAGCSYP9PIUkY92eQ\n"
"q2EGnI/yuum06ZIya7XzV+hdG82MHauVBJVJ8zUtluNJbd134/tJS7SsVQepj5Wz\n"
"tCO7TG1F8PapspUwtP1MVYwnSlcUfIKdzXOS0xZKBgyMUNGPHgm+F6HmIcr9g+UQ\n"
"vIOlCsRnKPZzFBQ9RnbDhxSJITRNrw9FDKZJobq7nMWxM4MphQIDAQABo0IwQDAP\n"
"BgNVHRMBAf8EBTADAQH/MA4GA1UdDwEB/wQEAwIBhjAdBgNVHQ4EFgQUTiJUIBiV\n"
"5uNu5g/6+rkS7QYXjzkwDQYJKoZIhvcNAQELBQADggEBAGBnKJRvDkhj6zHd6mcY\n"
"1Yl9PMWLSn/pvtsrF9+wX3N3KjITOYFnQoQj8kVnNeyIv/iPsGEMNKSuIEyExtv4\n"
"NeF22d+mQrvHRAiGfzZ0JFrabA0UWTW98kndth/Jsw1HKj2ZL7tcu7XUIOGZX1NG\n"
"Fdtom/DzMNU+MeKNhJ7jitralj41E6Vf8PlwUHBHQRFXGU7Aj64GxJUTFy8bJZ91\n"
"8rGOmaFvE7FBcf6IKshPECBV1/MUReXgRPTqh5Uykw7+U0b6LJ3/iyK5S9kJRaTe\n"
"pLiaWN0bfVKfjllDiIGknibVb63dDcY3fe0Dkhvld1927jyNxF1WW6LZZm6zNTfl\n"
"MrY=\n"
"-----END CERTIFICATE-----\n";

// WiFi
const char* ssid = "Pixel";
const char* password = "andres12345";

// MQTT
const char* mqtt_server = "vcf1fa18.ala.us-east-1.emqxsl.com";
const int mqtt_port = 8883;
const char* mqtt_user = "emqx_online_test_1a611861";
const char* mqtt_pass = "031ff86Q?496T6bbP$0e&2b61KG3b64e";

WiFiClientSecure secureClient;
PubSubClient client(secureClient);

BLEServer* pServer;
BLECharacteristic* pCharacteristic;

//Led de pruebas
const int led = 4;
const int ledBlue = 22;
const int ledMqtt = 23;

//Para el sensor de humedad y temperatura
#define DHTPIN 14       
#define DHTTYPE DHT11
DHT dht(DHTPIN, DHTTYPE);

//Valores apra la bomba de agua
const int waterPumpPin = 26;
unsigned long pumpEndTime = 0;
const unsigned long pumpDuration = 20000;

// Para evitar riego doble el mismo día
int lastWateredDay = -1;

// Para controlar duración de la bomba sin delay
unsigned long pumpStartTime = 0;
bool pumpRunning = false;
unsigned long lastActivationTime = 0;  
const unsigned long cooldown = 3600000;

//Para el sensor yl69 de la humedad en el suelo
const int dirtHumidity = 33;

//Valores para el sensor de luz
const int sensorLrd = 19;

//Valores para el ventilador
const int fanPin = 22;
unsigned long fanEndTime = 0;

//Valores para el sensor de nivel de agua
const int waterRemainingPin = 32;

//Valores para que haga cosas si es que llega a esos valores
int minHumidity = 0;
int maxTemperature = 0;

//Dias de regado Domingo-Lunes
bool water_days[7] = {false,false,false,false,false,false,false};

bool flutterConnected = false;

StaticJsonDocument<512> jsonTX;  // para enviar
StaticJsonDocument<512> jsonRX;  // para recibir

// UUIDs para conectarse por blu
#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

//Funcion para crear el json
String createJson(){
  jsonTX.clear();
  float humidity = dht.readHumidity();
  float temperature = dht.readTemperature();
  int dirt_humidity = analogRead(dirtHumidity);
  double waterRemaining = analogRead(waterRemainingPin);
  waterRemaining = (waterRemaining / 4095) * 1;
  int light = digitalRead(sensorLrd);

  if (isnan(humidity) || isnan(temperature)) {
    jsonTX["humidity"] = 1;       // valor por defecto
    jsonTX["temperature"] = 1;    // valor por defecto
  } else {
      jsonTX["humidity"] = humidity;
      jsonTX["temperature"] = temperature;
  }

  jsonTX["dirt_humidity"] = dirt_humidity;
  jsonTX["light"] = light;
  jsonTX["minHumidity"] = minHumidity;
  jsonTX["maxTemperature"] = maxTemperature;
  jsonTX["waterRemaining"] = waterRemaining;
  JsonArray days = jsonTX.createNestedArray("water_days");
  for (int i = 0; i < 7; i++) {
    days.add(water_days[i]);
  }
  String payload;
  serializeJson(jsonTX, payload); 
  Serial.println(payload);
  return payload;
}

//Esto es para identificar cuando se conecta y de desconecta flutter
class MyServerCallbacks: public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) {
    Serial.println("Dispositivo conectado");
    flutterConnected = true;
    digitalWrite(ledBlue, HIGH);
  }

  void onDisconnect(BLEServer* pServer) {
    Serial.println("Dispositivo desconectado");
    flutterConnected = false;
    pServer->getAdvertising()->start();
    digitalWrite(ledBlue, LOW);
  }
};

// Fuucnion para manejar los datos que son recibos desde flutter
class MyCallbacks: public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pCharacteristic) {
    String value = pCharacteristic->getValue().c_str();
    Serial.print("Recibido: ");
    Serial.println(value);
    getJson(value);
  }
};

//Funcion para manjear los datos recibidos desde mqtt
void callback(char* topic, byte* payload, unsigned int length) {
  String message;
  for (int i = 0; i < length; i++) {
    message += (char)payload[i];
  }
  getJson(message);
}

//Funcion para manejar los datos llegados desde flutter por mqtt o blu
void getJson(String data){
    jsonRX.clear();
    DeserializationError err = deserializeJson(jsonRX, data);

    if (err) {
      Serial.println("Error al parsear JSON");
      return;
    }
    Serial.println(data);
     if (jsonRX.containsKey("online")){
      String payload = createJson();
      client.publish("hydrolink/data", payload.c_str());
     }

    if (jsonRX.containsKey("waterPump")) {
      if(jsonRX["waterPump"] == false){
        digitalWrite(waterPumpPin, LOW);
      }else{
        digitalWrite(waterPumpPin, HIGH);
        int duration = jsonRX["waterPump"];
        pumpEndTime = millis() + duration * 1000;
      }
    }
    if (jsonRX.containsKey("fan")) {
      if(jsonRX["fan"] == false){
        digitalWrite(fanPin,LOW);
      } else{
        digitalWrite(fanPin, HIGH);
        int duration = jsonRX["fan"];
        fanEndTime = millis() + duration * 1000;
      }
    }
    if (jsonRX.containsKey("minHumidity")) {
      minHumidity = jsonRX["minHumidity"];
    }
    if (jsonRX.containsKey("maxTemperature")) {
      maxTemperature = jsonRX["maxTemperature"];
    }
    if (jsonRX.containsKey("waterDays")) {
      JsonArray arr = jsonRX["waterDays"];
      for (int i = 0; i < arr.size(); i++) {
        water_days[i] = arr[i];
      }
    }
    if (jsonRX.containsKey("led")) {
      if(jsonRX["led"] == true){
        digitalWrite(led,HIGH);
      }else{
        digitalWrite(led,LOW);
      }
    }
}

//Funcion para empezar wifi
void setup_wifi() {
  Serial.print("Conectando a WiFi: ");
  WiFi.begin(ssid, password);
  WiFi.setSleep(false);

  while (WiFi.status() != WL_CONNECTED) 
  {
    delay(500);
    Serial.print('.');
  }

  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\nConectado a WiFi");
    Serial.println(WiFi.localIP());
  } else {
    Serial.println("\nNo se pudo conectar a WiFi");
  }
}

//Funcion para reconectar a mqtt en caso de que se desconecte
void reconnect() {
  while (!client.connected()) {
    Serial.print("Intentando conectar al broker MQTT...\n");
    if (client.connect("ESP32Client", mqtt_user, mqtt_pass)) {
      Serial.println("Conectado al broker");
      client.subscribe("hydrolink/entry");
      digitalWrite(ledMqtt, HIGH);
    } else {
      digitalWrite(ledMqtt, LOW);
      Serial.print("Fallo, código de error: ");
      Serial.println(client.state());
      delay(5000);
    }
  }
}

//Funcion para configurar blu
void setup_blu(){
  Serial.println("Iniciando BLE...");
  Serial.printf("Memoria libre antes de BLE: %d bytes\n", ESP.getFreeHeap());
  
  esp_bt_controller_mem_release(ESP_BT_MODE_CLASSIC_BT);

  BLEDevice::init("ESP32_BLE"); 
  pServer = BLEDevice::createServer();

  BLEService *pService = pServer->createService(SERVICE_UUID);
  
  pCharacteristic = pService->createCharacteristic(
                      CHARACTERISTIC_UUID,
                      BLECharacteristic::PROPERTY_READ |
                      BLECharacteristic::PROPERTY_WRITE |
                      BLECharacteristic::PROPERTY_NOTIFY
                    );

  pCharacteristic->setCallbacks(new MyCallbacks()); 
  pServer->setCallbacks(new MyServerCallbacks());

  pService->start();

  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  BLEDevice::startAdvertising();

  Serial.printf("Memoria libre después de BLE: %d bytes\n", ESP.getFreeHeap());
  Serial.println("ESP32 BLE listo. Conéctate desde Flutter.");
}

void setup() {
  Serial.begin(115200);
  setup_blu();

  setup_wifi();
  secureClient.setCACert(ca_cert);
  client.setServer(mqtt_server, mqtt_port);
  client.setCallback(callback);
  reconnect();

  configTime(0, 0, "pool.ntp.org", "time.nist.gov");

  setenv("TZ", "PST8PDT,M3.2.0,M11.1.0", 1);
  tzset();

  Serial.println("Esperando hora...");
  delay(2000);
  Serial.println("Hora obtenida.");

  dht.begin();
  pinMode(led, OUTPUT);
  pinMode(waterPumpPin, OUTPUT);
  pinMode(ledBlue, OUTPUT);
  pinMode(ledMqtt, OUTPUT);
  pinMode(fanPin, OUTPUT);
  pinMode(sensorLrd, INPUT);
  digitalWrite(ledMqtt, HIGH);
}

void loop() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop();

  if (pumpRunning) {
    if (millis() - pumpStartTime >= pumpDuration) {
      digitalWrite(waterPumpPin, LOW);
      pumpRunning = false;
      Serial.println(">>> Riego terminado <<<");
    }
  }

  time_t now = time(nullptr);
  struct tm* timeInfo = localtime(&now);
  if (!timeInfo) return;

  int hour  = timeInfo->tm_hour;
  int min   = timeInfo->tm_min;
  int wday  = timeInfo->tm_wday; 

  if (water_days[wday] &&
      hour == 12 &&
      min == 0 &&
      lastWateredDay != wday) {

    Serial.println(">>> Activando riego <<<");
    digitalWrite(waterPumpPin, HIGH);
    pumpRunning = true;
    pumpStartTime = millis();
    lastWateredDay = wday;
  }

  unsigned long nowMillis = millis();
  static unsigned long lastRead = 0;

  if (nowMillis - lastRead >= 10000) {    
  lastRead = nowMillis;

  float humidity = dht.readHumidity();
  
  if (humidity < minHumidity) {
    if(now - lastActivationTime >= cooldown) {
      digitalWrite(waterPumpPin, HIGH);  
      pumpEndTime = now + 10000;         
      lastActivationTime = now;  
      pumpEndTime = nowMillis + 10000;        
      }    
    }
  }

  if (pumpEndTime > 0 && nowMillis >= pumpEndTime) {
    digitalWrite(waterPumpPin, LOW);
    pumpEndTime = 0;
  }
  if (fanEndTime > 0 && nowMillis >= fanEndTime) {
      digitalWrite(fanPin, LOW);
      fanEndTime = 0;
  }

  if(flutterConnected){
    static unsigned long lastTime = 0;
    if (millis() - lastTime > 10000) {
      lastTime = millis();
      String payload = createJson();
      pCharacteristic->setValue(payload.c_str());

      // Envia la notificacion y mensaje al telefono 
      pCharacteristic->notify(); 
      Serial.println("Mensaje enviado a Flutter por blu");
    }
  }
}