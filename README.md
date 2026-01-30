# Mini Task & Habit Tracker

Flutter ile geliştirilmiş görev ve alışkanlık takip uygulaması. Clean Architecture prensiplerine uygun olarak tasarlanmıştır.

![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)

## 🚀 Projenin Çalıştırılması

### Gereksinimler

- Flutter SDK 3.10+
- Dart SDK 3.0+
- Android Studio / VS Code
- Android Emulator veya fiziksel cihaz

### Flutter Kurulum Kontrolü

```bash
# Flutter'ın düzgün kurulu olduğunu kontrol edin
flutter doctor

# Tüm check'ler yeşil olmalı (✓)
# Eksik varsa flutter doctor önerilerini takip edin
```

### Kurulum Adımları

```bash
# 1. Projeyi klonlayın
git clone <repo-url>
cd Habit_Task

# 2. Bağımlılıkları yükleyin
flutter pub get

# 3. Hive adaptörlerini oluşturun
dart run build_runner build --delete-conflicting-outputs
```

### Android'de Çalıştırma

```bash
# Emulator listesini görün
flutter emulators

# Emulator başlatın (örnek: Pixel_4_API_30)
flutter emulators --launch Pixel_4_API_30

# Veya Android Studio > Device Manager > Start

# Uygulamayı çalıştırın
flutter run
```

### iOS'ta Çalıştırma (macOS gerekli)

```bash
# iOS bağımlılıklarını yükleyin
cd ios
pod install
cd ..

# Simulator başlatın
open -a Simulator

# Uygulamayı çalıştırın
flutter run
```

### Fiziksel Cihazda Çalıştırma

1. **Android**: USB Debugging aktif edin (Geliştirici Seçenekleri)
2. **iOS**: Xcode'da signing ayarlarını yapın
3. Cihazı USB ile bağlayın
4. `flutter run` komutunu çalıştırın

### Test

```bash
flutter test
```

## 🏗️ Mimari Açıklama

Proje **Clean Architecture** prensiplerine göre yapılandırılmıştır:

```text
lib/
├── core/                       # Paylaşılan bileşenler
│   ├── router/                 # GoRouter navigasyon
│   ├── theme/                  # Tema (Light/Dark)
│   └── widgets/                # Ortak widget'lar
│
├── features/                   # Feature-based modüller
│   ├── tasks/
│   │   ├── data/
│   │   │   ├── datasources/    # Local (Hive) & Remote (Fake API)
│   │   │   ├── models/         # Data modelleri
│   │   │   └── repositories/   # Repository implementasyonu
│   │   ├── domain/
│   │   │   └── repositories/   # Repository interface
│   │   └── presentation/
│   │       ├── providers/      # Riverpod state
│   │       ├── screens/        # UI ekranları
│   │       └── widgets/        # Feature widget'ları
│   │
│   └── habits/                 # Aynı yapı
│
└── main.dart
```

### Katman Sorumlulukları

| Katman | Sorumluluk |
| ------ | ---------- |
| **Data** | Veri kaynakları (Hive, Fake API), modeller, repository implementasyonu |
| **Domain** | İş kuralları, repository interface'leri |
| **Presentation** | UI, state management (Riverpod providers) |

## 🔧 State Management: Riverpod

### Neden Riverpod?

| Özellik | Açıklama |
| ------- | -------- |
| **Type-safety** | Compile-time hata kontrolü, Provider vs BLoC'a göre daha güvenli |
| **Dependency Injection** | Widget tree'den bağımsız, test edilebilir yapı |
| **Otomatik dispose** | Kullanılmayan provider'lar otomatik temizlenir |
| **AsyncValue** | Loading/Error/Data durumlarını native olarak destekler |
| **Kolay test** | Provider override ile mock data enjeksiyonu |

### Alternatif Karşılaştırma

- **Provider**: Riverpod'un öncüsü, daha az özellik
- **BLoC**: Daha fazla boilerplate, event/state pattern zorunlu
- **GetX**: Type-safety eksik, magic string kullanımı
- **MobX**: Observable pattern, Flutter'a özgü değil

### Örnek Kullanım

```dart
// Provider tanımı
final taskListProvider = StateNotifierProvider<TaskListNotifier, AsyncValue<List<TaskModel>>>(...);

// Widget'ta kullanım
final tasksState = ref.watch(filteredTasksProvider);
tasksState.when(
  loading: () => LoadingWidget(),
  error: (e, _) => ErrorWidget(onRetry: () => ref.read(taskListProvider.notifier).loadTasks()),
  data: (tasks) => ListView.builder(...),
);
```

## ⚠️ Bilinen Eksikler

1. **Cloud Sync Yok** - Veriler sadece lokalde (Hive) saklanıyor
2. **Bildirim Sistemi Yok** - Görev/alışkanlık hatırlatıcıları eksik
3. **Analitik Yok** - Haftalık/aylık istatistikler mevcut değil
4. **Streak Kırılma** - Bir gün atlanırsa streak sıfırlanıyor

## 🔮 Geliştirme Önerileri

- [ ] Firebase entegrasyonu (Auth + Firestore)
- [ ] Push notification sistemi
- [ ] Haftalık/aylık alışkanlık grafikleri
- [ ] Görev kategorileri ve etiketleri ✅ (eklendi)
- [ ] Alışkanlık dondurma (tatil modu)
- [ ] Ana ekran widget'ı
- [ ] Çoklu dil desteği
- [ ] Görev paylaşımı (aile/ekip)
- [ ] Pomodoro timer entegrasyonu

## � Özellikler

### Görevler

- ✅ Görev oluşturma, düzenleme, silme
- 🔍 Görev arama
- 🏷️ Filtre (Tümü / Aktif / Tamamlandı)
- 📊 Tamamlanma yüzdesi ve istatistikler
- 🔄 Öncelik/tarih sıralaması
- 🏷️ Etiket sistemi (Kişisel / İş / Diğer)

### Alışkanlıklar

- 🏆 Günlük alışkanlık takibi
- 🔥 Streak sayacı
- 📅 Hedef gün seçimi (7/21/30/özel)
- 📊 İlerleme çubuğu

---


