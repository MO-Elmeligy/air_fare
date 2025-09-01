# دليل تكامل HC-05 مع تطبيق الطبخ

## نظرة عامة
تم دمج وظائف البلوتوث مع تطبيق الطبخ للاتصال بشريحة HC-05 المتصلة بآردوينو نانو.

## المتطلبات

### الأجهزة
- شريحة HC-05 بلوتوث
- آردوينو نانو
- مستشعرات (اختيارية): درجة الحرارة، الرطوبة، إلخ

### البرمجيات
- Flutter SDK
- مكتبة `flutter_bluetooth_serial: ^0.4.0`

## إعداد الآردوينو

### توصيل HC-05
```
HC-05 VCC → 5V
HC-05 GND → GND
HC-05 TX → Arduino Pin 2 (RX)
HC-05 RX → Arduino Pin 3 (TX)
```

### كود الآردوينو
```cpp
#include <SoftwareSerial.h>

SoftwareSerial bluetooth(2, 3); // RX, TX

void setup() {
  Serial.begin(9600);
  bluetooth.begin(9600);
  Serial.println("HC-05 Ready");
}

void loop() {
  if (bluetooth.available()) {
    String data = bluetooth.readString();
    Serial.println("Received: " + data);
    
    // Parse cooking data: "TEMP:TIME:STEAM"
    // Example: "175:30:1"
    int firstColon = data.indexOf(':');
    int secondColon = data.indexOf(':', firstColon + 1);
    
    if (firstColon != -1 && secondColon != -1) {
      int temp = data.substring(0, firstColon).toInt();
      int time = data.substring(firstColon + 1, secondColon).toInt();
      int steam = data.substring(secondColon + 1).toInt();
      
      Serial.println("Temperature: " + String(temp) + "°C");
      Serial.println("Time: " + String(time) + " min");
      Serial.println("Steam: " + String(steam));
      
      // Start cooking process here
      startCooking(temp, time, steam);
    }
  }
}

void startCooking(int temp, int time, int steam) {
  // Implement your cooking logic here
  Serial.println("Starting cooking process...");
  
  // Example: Control relays, heaters, etc.
  // digitalWrite(HEATER_PIN, HIGH);
  // delay(time * 60000); // Convert minutes to milliseconds
  // digitalWrite(HEATER_PIN, LOW);
}
```

## إعداد التطبيق

### 1. تحديث MAC Address
في ملف `lib/detailsPage.dart`، قم بتغيير عنوان MAC الخاص بـ HC-05:

```dart
BluetoothConnection.toAddress("98:D3:31:FD:76:A0") // ← غير هذا العنوان
```

### 2. البحث عن عنوان MAC
1. اذهب إلى إعدادات البلوتوث في هاتفك
2. ابحث عن جهاز HC-05
3. انقر على "Details" أو "Settings"
4. ابحث عن عنوان MAC (مثل: 98:D3:31:FD:76:A0)

### 3. إقران الجهاز
قبل استخدام التطبيق، تأكد من إقران HC-05 مع هاتفك من إعدادات البلوتوث.

## كيفية الاستخدام

### 1. الاتصال
- افتح التطبيق
- اذهب إلى صفحة تفاصيل الطعام
- اضغط على زر "اتصال" في قسم البلوتوث
- انتظر حتى يظهر "متصل ✅"

### 2. ضبط الإعدادات
- استخدم الشرائح لضبط:
  - درجة الحرارة (100-250°C)
  - الوقت (1-60 دقيقة)
  - مستوى البخار (0-2)

### 3. بدء الطبخ
- اضغط على زر "Start Cooking"
- سيتم إرسال الإعدادات تلقائياً إلى HC-05
- ستظهر رسالة تأكيد

## تنسيق البيانات

### الإرسال (التطبيق → HC-05)
```
TEMP:TIME:STEAM
```
مثال: `175:30:1`

### الاستقبال (HC-05 → التطبيق)
يمكن للآردوينو إرسال بيانات مثل:
- حالة الطبخ
- درجة الحرارة الحالية
- الوقت المتبقي
- رسائل الخطأ

## استكشاف الأخطاء

### مشاكل الاتصال
1. **لا يمكن الاتصال**
   - تأكد من إقران HC-05 مع الهاتف
   - تحقق من أن HC-05 يعمل
   - تأكد من صحة عنوان MAC

2. **فصل الاتصال تلقائياً**
   - تحقق من إعدادات الطاقة
   - تأكد من عدم وجود تداخل

3. **بطء في الاتصال**
   - تأكد من أن HC-05 قريب من الهاتف
   - تحقق من عدم وجود أجهزة أخرى متصلة

### مشاكل في الإرسال
1. **لا يتم إرسال البيانات**
   - تأكد من الاتصال
   - تحقق من كود الآردوينو
   - تأكد من سرعة البود (9600)

2. **بيانات مشوهة**
   - تحقق من تنسيق البيانات
   - تأكد من عدم وجود تداخل

## ميزات إضافية

### 1. مراقبة في الوقت الفعلي
يمكن إضافة ميزات مثل:
- عرض درجة الحرارة الحالية
- العد التنازلي للوقت
- حالة الطبخ

### 2. حفظ الإعدادات
- حفظ الإعدادات المفضلة
- استرجاع الإعدادات السابقة

### 3. وصفات متعددة
- إرسال وصفات كاملة
- جدولة الطبخ

## ملاحظات مهمة

1. **الأمان**: تأكد من أن HC-05 في وضع آمن
2. **الطاقة**: استخدم مصدر طاقة مستقر للآردوينو
3. **التحديثات**: احتفظ بمكتبات Flutter محدثة
4. **الاختبار**: اختبر الاتصال قبل الاستخدام الفعلي

## الدعم

إذا واجهت أي مشاكل:
1. تحقق من سجلات التطبيق
2. تأكد من إعدادات البلوتوث
3. اختبر الاتصال مع تطبيق بلوتوث آخر
4. راجع كود الآردوينو

---

**ملاحظة**: هذا الدليل مخصص للتطبيق الحالي. قد تحتاج لتعديل الكود حسب احتياجاتك الخاصة.
