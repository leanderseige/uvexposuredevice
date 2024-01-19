/*
    UV Exposure Device Firmware
    Leander Seige
*/

#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

#define LED 13
#define TESTLED 2

BLEServer *pServer = NULL;
BLECharacteristic *pTxCharacteristic;
bool deviceConnected = false;
bool oldDeviceConnected = false;
uint8_t txValue = 0;

int timeRunner = 0;

// See the following for generating UUIDs:
// https://www.uuidgenerator.net/

#define SERVICE_UUID "BB82E92C-1477-4FD6-B59F-3AE6AEC3B706"  // UART service UUID
#define CHARACTERISTIC_UUID_RX "B7EA89CF-9E06-4F8A-8017-1F6B63EA6E20"
#define CHARACTERISTIC_UUID_TX "17A87C7C-582D-4500-B229-29AAE234910C"


class MyServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer *pServer) {
    deviceConnected = true;
  };

  void onDisconnect(BLEServer *pServer) {
    deviceConnected = false;
  }
};

class MyCallbacks : public BLECharacteristicCallbacks {

  void onWrite(BLECharacteristic *pCharacteristic) {
    String rxValue = String((pCharacteristic->getValue()).c_str());
    String command = "";
    String value = "";

    if (rxValue.length() > 0) {
      Serial.println(rxValue);
      int idx = rxValue.indexOf('#');
      command = rxValue.substring(0, idx);
      value = rxValue.substring(idx + 1);
      if (command == "ON") {
        timeRunner = value.toInt();
      }
      if (command == "OFF") {
        timeRunner = 0;
      }
    }
  }
};

void blink() {
  digitalWrite(TESTLED, HIGH);
  digitalWrite(LED, HIGH);
  delay(500);
  digitalWrite(TESTLED, LOW);
  digitalWrite(LED, LOW);
  delay(500);
}

void setup() {
  pinMode(LED, OUTPUT);
  pinMode(TESTLED, OUTPUT);

  digitalWrite(LED, LOW);
  digitalWrite(TESTLED, LOW);


  Serial.begin(115200);

  // Create the BLE Device
  BLEDevice::init("UVExposureDevice");

  // Create the BLE Server
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  // Create the BLE Service
  BLEService *pService = pServer->createService(SERVICE_UUID);

  // Create a BLE Characteristic
  pTxCharacteristic = pService->createCharacteristic(
    CHARACTERISTIC_UUID_TX,
    BLECharacteristic::PROPERTY_NOTIFY);

  pTxCharacteristic->addDescriptor(new BLE2902());

  BLECharacteristic *pRxCharacteristic = pService->createCharacteristic(
    CHARACTERISTIC_UUID_RX,
    BLECharacteristic::PROPERTY_WRITE);

  pRxCharacteristic->setCallbacks(new MyCallbacks());

  // Start the service
  pService->start();

  blink();

  // Start advertising
  pServer->getAdvertising()->start();

  blink();
  blink();

  Serial.println("Waiting a client connection to notify...");
}

void loop() {
  String txValue = String(timeRunner);


  if (deviceConnected) {
    for (int c = 0; c < 10; c++) {
      pTxCharacteristic->setValue((char *)&txValue);
      pTxCharacteristic->notify();
      if (timeRunner > 0) {
        if (c == 9) {
          timeRunner = timeRunner - 1;
        }
        digitalWrite(LED, HIGH);
        digitalWrite(TESTLED, HIGH);
      } else {
        digitalWrite(LED, LOW);
        digitalWrite(TESTLED, LOW);
      }
      delay(100);
    }
  } else {
    delay(100);
    Serial.println("NOT CONNECTED");
  }

  // disconnecting
  if (!deviceConnected && oldDeviceConnected) {
    delay(500);                   // give the bluetooth stack the chance to get things ready
    pServer->startAdvertising();  // restart advertising
    Serial.println("start advertising");
    oldDeviceConnected = deviceConnected;
  }
  // connecting
  if (deviceConnected && !oldDeviceConnected) {
    // do stuff here on connecting
    oldDeviceConnected = deviceConnected;
  }
}
