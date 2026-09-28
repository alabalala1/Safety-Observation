# Safety Observation

مشروع Flutter مبدئي. يحتوي حاليًا على ملفات التطبيق والإعداد الأساسية فقط، دون تنفيذ واجهات Figma أو منطق الأعمال.

## تجهيز المشروع محليًا

ثبّت Flutter SDK، ثم نفّذ من داخل مجلد المشروع:

```bash
flutter create --project-name safety_observation .
flutter pub get
flutter run
```

الأمر `flutter create` يولّد ملفات المنصات القياسية مثل `android/` و`ios/` بحسب البيئة المتاحة. بعد ذلك يمكن إضافة ملفات المنصات الناتجة إلى المستودع. افحص التغييرات قبل اعتمادها حتى يبقى `lib/main.dart` كما هو.

## الملفات الحالية

- `lib/main.dart`: نقطة تشغيل التطبيق وشاشة بداية مؤقتة.
- `pubspec.yaml`: تعريف المشروع واعتماده على Flutter.
- `analysis_options.yaml`: قواعد تحليل Dart الأساسية.
- `.gitignore`: يستبعد ملفات البناء والإعدادات المحلية.

لا توجد بيانات دخول أو مفاتيح API في المشروع.
