/*
 * كود آردوينو بسيط جداً للاختبار
 * Arduino Nano + HC-05 Bluetooth Module
 */

#include <SoftwareSerial.h>

SoftwareSerial bluetooth(2, 3); // RX, TX

void setup() {
  Serial.begin(9600);
  bluetooth.begin(9600);
  
  Serial.println("Arduino started");
  bluetooth.println("Arduino started");
  
  delay(2000);
  bluetooth.println("Ready");
  Serial.println("Sent: Ready");
}

void loop() {
  // إرسال رسالة كل 3 ثواني
  static unsigned long lastTime = 0;
  if (millis() - lastTime > 3000) {
    bluetooth.println("Hello from Arduino");
    Serial.println("Sent: Hello from Arduino");
    lastTime = millis();
  }
  
  // قراءة البيانات
  if (bluetooth.available()) {
    String data = bluetooth.readString();
    data.trim();
    Serial.println("Received: " + data);
    bluetooth.println("Echo: " + data);
  }
  
  delay(100);
}
