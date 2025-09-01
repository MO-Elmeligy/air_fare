# Bluetooth Serial Communication Guide

## نظرة عامة

تم تحديث النظام لاستخدام `flutter_bluetooth_serial` بدلاً من `flutter_blue` للحصول على:
- دعم أفضل لـ Classic Bluetooth (مثل HC-05)
- اتصال Serial سلس وسريع
- إرسال واستقبال البيانات بسهولة
- تجربة مشابهة لبرنامج Serial Bluetooth Terminal

## المميزات الجديدة

### ✅ ما تم إضافته:
- **Scan للبحث عن الأجهزة**
- **Connect للاتصال بالأجهزة**
- **Send/Receive البيانات** (نص و bytes)
- **Stream للاستماع للبيانات الواردة**
- **معالجة الأوامر المخصصة**
- **إدارة الاتصال والحالة**

### 🔧 الوظائف المتاحة:

#### 1. إدارة الاتصال
```dart
// تفعيل البلوتوث
await bluetoothController.requestBluetoothPermissions();

// البحث عن الأجهزة
await bluetoothController.scanDevices();

// الاتصال بجهاز
await bluetoothController.connectToDevice(device);

// قطع الاتصال
await bluetoothController.disconnect();
```

#### 2. إرسال البيانات
```dart
// إرسال نص
await bluetoothController.sendData("Hello HC-05");

// إرسال bytes
Uint8List bytes = Uint8List.fromList([0x01, 0x02, 0x03]);
await bluetoothController.sendBytes(bytes);
```

#### 3. استقبال البيانات
```dart
// الاستماع للبيانات الواردة
bluetoothController.dataStream.listen((data) {
  print('Received: $data');
  // معالجة البيانات هنا
});
```

## كيفية الاستخدام

### 1. إعداد المشروع

أضف الباكج في `pubspec.yaml`:
```yaml
dependencies:
  flutter_bluetooth_serial: ^0.4.0
```

### 2. تهيئة BluetoothController

```dart
// في main.dart أو أي مكان تريد استخدامه
final BluetoothController bluetoothController = Get.put(BluetoothController());
```

### 3. استخدام الصفحة

```dart
// الانتقال لصفحة البلوتوث
Get.to(() => BluetoothPage());
```

### 4. معالجة البيانات

```dart
// تهيئة معالج البيانات
final dataHandler = BluetoothDataHandler();
dataHandler.initialize();
```

## الأوامر المدعومة

### 🍳 أوامر الطبخ:
- `start_cooking` - بدء الطبخ
- `stop_cooking` - إيقاف الطبخ
- `pause_cooking` - إيقاف مؤقت
- `resume_cooking` - استئناف الطبخ

### 🌡️ أوامر الحرارة:
- `temp_high` - حرارة عالية
- `temp_low` - حرارة منخفضة
- `temp_normal` - حرارة طبيعية

### ⏱️ أوامر المؤقت:
- `timer_start` - بدء المؤقت
- `timer_stop` - إيقاف المؤقت
- `timer_pause` - إيقاف مؤقت للمؤقت

### 📊 طلبات الحالة:
- `get_status` - الحصول على الحالة
- `get_temperature` - الحصول على الحرارة
- `get_timer` - الحصول على المؤقت

### 🚨 أوامر الطوارئ:
- `emergency_stop` - إيقاف طارئ
- `safety_check` - فحص الأمان

## مثال على الاستخدام مع HC-05

### 1. إعداد HC-05:
```arduino
// كود Arduino للـ HC-05
void setup() {
  Serial.begin(9600);
}

void loop() {
  if (Serial.available()) {
    String command = Serial.readString();
    command.trim();
    
    // معالجة الأوامر
    if (command == "get_temperature") {
      float temp = readTemperature();
      Serial.println("temp:" + String(temp));
    }
    else if (command == "start_cooking") {
      startCooking();
      Serial.println("cooking_started");
    }
    // ... المزيد من الأوامر
  }
}
```

### 2. إرسال أوامر من Flutter:
```dart
// إرسال أمر بدء الطبخ
bluetoothController.sendData("start_cooking");

// طلب قراءة الحرارة
bluetoothController.sendData("get_temperature");

// إرسال معاملات الطبخ
dataHandler.sendCookingParameters(
  temperature: 180,
  duration: 30,
  mode: "bake"
);
```

## إعدادات Android

### 1. الأذونات المطلوبة في `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
```

### 2. إعدادات Bluetooth في `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-feature android:name="android.hardware.bluetooth" android:required="true" />
```

## استكشاف الأخطاء

### مشاكل شائعة:

#### 1. لا يتم العثور على الأجهزة:
- تأكد من تفعيل البلوتوث
- تأكد من إعطاء أذونات الموقع
- تأكد من أن الجهاز في وضع الاكتشاف

#### 2. فشل الاتصال:
- تأكد من أن الجهاز متاح
- تأكد من كلمة المرور (عادة 1234 أو 0000)
- جرب إعادة تشغيل البلوتوث

#### 3. لا يتم إرسال/استقبال البيانات:
- تأكد من الاتصال الناجح
- تأكد من إعدادات Baud Rate (عادة 9600)
- تحقق من تنسيق البيانات

### نصائح للتطوير:

1. **اختبار الاتصال:**
```dart
// إرسال أمر اختبار
bluetoothController.sendData("test");
```

2. **مراقبة البيانات:**
```dart
// مراقبة البيانات الواردة
bluetoothController.dataStream.listen((data) {
  print('Raw data: $data');
});
```

3. **فحص حالة الاتصال:**
```dart
// فحص إذا كان متصل
if (bluetoothController.isConnected.value) {
  print('Connected to: ${bluetoothController.connectedDeviceName.value}');
}
```

## التطوير المستقبلي

### إضافات مقترحة:
- [ ] دعم إرسال ملفات
- [ ] تشفير البيانات
- [ ] إعادة الاتصال التلقائي
- [ ] حفظ الأجهزة المفضلة
- [ ] واجهة تحكم متقدمة

### تحسينات الأداء:
- [ ] ضغط البيانات
- [ ] إرسال البيانات في خلفية
- [ ] إدارة الذاكرة المحسنة
- [ ] معالجة الأخطاء المتقدمة

## الدعم والمساعدة

إذا واجهت أي مشاكل:
1. تحقق من الأذونات
2. تأكد من إعدادات الجهاز
3. راجع الـ logs في console
4. اختبر الاتصال ببرنامج Serial Bluetooth Terminal أولاً

---

**ملاحظة:** هذا النظام مصمم خصيصاً للعمل مع أجهزة Classic Bluetooth مثل HC-05 وليس BLE devices.
