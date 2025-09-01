/*
 * كود الآردوينو للاتصال مع تطبيق الطبخ عبر HC-05
 * Arduino Nano + HC-05 Bluetooth Module
 * 
 * التوصيل:
 * HC-05 VCC → 5V
 * HC-05 GND → GND  
 * HC-05 TX → Arduino Pin 2 (RX)
 * HC-05 RX → Arduino Pin 3 (TX)
 */

#include <SoftwareSerial.h>

// تعريف منافذ البلوتوث
SoftwareSerial bluetooth(2, 3); // RX, TX

// متغيرات الطبخ
int cookingTemperature = 0;
int cookingTime = 0;
int steamLevel = 0;
bool isCooking = false;
unsigned long cookingStartTime = 0;
unsigned long cookingDuration = 0;

// تعريف المنافذ (يمكن تعديلها حسب احتياجاتك)
const int HEATER_PIN = 4;      // منفذ السخان
const int STEAM_PIN = 5;       // منفذ البخار
const int LED_PIN = 13;        // LED مؤشر
const int BUZZER_PIN = 6;      // منفذ الصوت

void setup() {
  // إعداد الاتصال التسلسلي
  Serial.begin(9600);
  bluetooth.begin(9600);
  
  // إعداد المنافذ
  pinMode(HEATER_PIN, OUTPUT);
  pinMode(STEAM_PIN, OUTPUT);
  pinMode(LED_PIN, OUTPUT);
  pinMode(BUZZER_PIN, OUTPUT);
  
  // إيقاف جميع الأجهزة
  digitalWrite(HEATER_PIN, LOW);
  digitalWrite(STEAM_PIN, LOW);
  digitalWrite(LED_PIN, LOW);
  
  // رسالة التأهب
  Serial.println("=== نظام الطبخ الذكي ===");
  Serial.println("HC-05 جاهز للاتصال");
  bluetooth.println("HC-05 جاهز للاتصال");
  
  // إشارة صوتية للتأهب
  beep(2);
}

void loop() {
  // قراءة البيانات من البلوتوث
  if (bluetooth.available()) {
    String data = bluetooth.readString();
    data.trim(); // إزالة المسافات الزائدة
    
    Serial.println("تم استقبال: " + data);
    
    // معالجة البيانات
    processCookingData(data);
  }
  
  // مراقبة عملية الطبخ
  if (isCooking) {
    monitorCooking();
  }
  
  // إرسال حالة النظام كل 5 ثواني
  static unsigned long lastStatusTime = 0;
  if (millis() - lastStatusTime > 5000) {
    sendStatus();
    lastStatusTime = millis();
  }
}

/*
 * معالجة بيانات الطبخ المستلمة
 * التنسيق: "TEMP:TIME:STEAM"
 * مثال: "175:30:1"
 */
void processCookingData(String data) {
  // البحث عن النقطتين الرأسيتين
  int firstColon = data.indexOf(':');
  int secondColon = data.indexOf(':', firstColon + 1);
  
  if (firstColon != -1 && secondColon != -1) {
    // استخراج القيم
    cookingTemperature = data.substring(0, firstColon).toInt();
    cookingTime = data.substring(firstColon + 1, secondColon).toInt();
    steamLevel = data.substring(secondColon + 1).toInt();
    
    // التحقق من صحة البيانات
    if (cookingTemperature >= 100 && cookingTemperature <= 250 &&
        cookingTime >= 1 && cookingTime <= 60 &&
        steamLevel >= 0 && steamLevel <= 2) {
      
      // طباعة البيانات
      Serial.println("=== إعدادات الطبخ ===");
      Serial.println("درجة الحرارة: " + String(cookingTemperature) + "°C");
      Serial.println("الوقت: " + String(cookingTime) + " دقيقة");
      Serial.println("مستوى البخار: " + String(steamLevel));
      
      // إرسال تأكيد
      bluetooth.println("تم استقبال الإعدادات: " + data);
      
      // بدء عملية الطبخ
      startCooking();
      
    } else {
      Serial.println("بيانات غير صحيحة!");
      bluetooth.println("خطأ: بيانات غير صحيحة");
      beep(3); // إشارة خطأ
    }
  } else {
    Serial.println("تنسيق البيانات غير صحيح!");
    bluetooth.println("خطأ: تنسيق البيانات غير صحيح");
    beep(3);
  }
}

/*
 * بدء عملية الطبخ
 */
void startCooking() {
  if (isCooking) {
    Serial.println("عملية طبخ قيد التشغيل بالفعل!");
    bluetooth.println("عملية طبخ قيد التشغيل بالفعل!");
    return;
  }
  
  Serial.println("بدء عملية الطبخ...");
  bluetooth.println("بدء عملية الطبخ...");
  
  // تفعيل السخان
  digitalWrite(HEATER_PIN, HIGH);
  digitalWrite(LED_PIN, HIGH);
  
  // تفعيل البخار حسب المستوى
  if (steamLevel > 0) {
    digitalWrite(STEAM_PIN, HIGH);
    Serial.println("تم تفعيل البخار - المستوى: " + String(steamLevel));
  }
  
  // تسجيل وقت البدء
  cookingStartTime = millis();
  cookingDuration = cookingTime * 60000; // تحويل الدقائق إلى ميلي ثانية
  isCooking = true;
  
  // إشارة بدء الطبخ
  beep(1);
  
  // إرسال رسالة البدء
  bluetooth.println("تم بدء الطبخ - درجة الحرارة: " + String(cookingTemperature) + "°C");
}

/*
 * مراقبة عملية الطبخ
 */
void monitorCooking() {
  unsigned long elapsedTime = millis() - cookingStartTime;
  unsigned long remainingTime = cookingDuration - elapsedTime;
  
  // التحقق من انتهاء الوقت
  if (remainingTime <= 0) {
    finishCooking();
    return;
  }
  
  // إرسال التحديث كل دقيقة
  static unsigned long lastUpdateTime = 0;
  if (millis() - lastUpdateTime > 60000) { // كل دقيقة
    int remainingMinutes = remainingTime / 60000;
    Serial.println("الوقت المتبقي: " + String(remainingMinutes) + " دقيقة");
    bluetooth.println("الوقت المتبقي: " + String(remainingMinutes) + " دقيقة");
    lastUpdateTime = millis();
  }
  
  // وميض LED أثناء الطبخ
  if (millis() % 1000 < 500) {
    digitalWrite(LED_PIN, HIGH);
  } else {
    digitalWrite(LED_PIN, LOW);
  }
}

/*
 * إنهاء عملية الطبخ
 */
void finishCooking() {
  Serial.println("انتهت عملية الطبخ!");
  bluetooth.println("انتهت عملية الطبخ!");
  
  // إيقاف جميع الأجهزة
  digitalWrite(HEATER_PIN, LOW);
  digitalWrite(STEAM_PIN, LOW);
  digitalWrite(LED_PIN, LOW);
  
  // إعادة تعيين المتغيرات
  isCooking = false;
  cookingTemperature = 0;
  cookingTime = 0;
  steamLevel = 0;
  
  // إشارة انتهاء الطبخ
  beep(4);
  
  // إرسال رسالة الانتهاء
  bluetooth.println("تم الانتهاء من الطبخ بنجاح!");
}

/*
 * إرسال حالة النظام
 */
void sendStatus() {
  String status = "الحالة: ";
  
  if (isCooking) {
    unsigned long elapsedTime = millis() - cookingStartTime;
    unsigned long remainingTime = cookingDuration - elapsedTime;
    int remainingMinutes = remainingTime / 60000;
    
    status += "طبخ - الوقت المتبقي: " + String(remainingMinutes) + " دقيقة";
  } else {
    status += "جاهز";
  }
  
  bluetooth.println(status);
}

/*
 * إشارات صوتية
 * count: عدد النغمات
 */
void beep(int count) {
  for (int i = 0; i < count; i++) {
    digitalWrite(BUZZER_PIN, HIGH);
    delay(200);
    digitalWrite(BUZZER_PIN, LOW);
    delay(200);
  }
}

/*
 * إيقاف الطوارئ
 * يمكن استدعاؤها من البلوتوث
 */
void emergencyStop() {
  Serial.println("إيقاف طارئ!");
  bluetooth.println("إيقاف طارئ!");
  
  // إيقاف جميع الأجهزة
  digitalWrite(HEATER_PIN, LOW);
  digitalWrite(STEAM_PIN, LOW);
  digitalWrite(LED_PIN, LOW);
  
  // إعادة تعيين المتغيرات
  isCooking = false;
  
  // إشارة الإيقاف
  beep(5);
}
