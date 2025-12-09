# 🕌 Prayer Time / Namaz Vakti

<div align="center">

![Version](https://img.shields.io/badge/version-0.5.4-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B.svg?logo=flutter)
![License](https://img.shields.io/badge/license-MIT-green.svg)

**A beautiful and feature-rich prayer times application built with Flutter**

**Flutter ile geliştirilmiş, zengin özelliklere sahip namaz vakitleri uygulaması**

[English](#english) | [Türkçe](#turkish)

</div>

---

<a name="english"></a>
## 📖 English

### Overview
Prayer Time is a comprehensive mobile application that helps Muslims keep track of their daily prayer times. The app provides accurate prayer times based on your location, with notification support and silent mode automation.

### ✨ Features

#### 🕐 Prayer Times
- **Accurate Times**: Fetches prayer times based on your current location
- **Daily View**: Today's complete prayer schedule
- **Weekly Calendar**: View prayer times for the entire week
- **Monthly Calendar**: Full month prayer times overview
- **Automatic Updates**: Prayer times update automatically based on location changes

#### 🔔 Smart Notifications
- **Before Prayer Notifications**: Get notified before each prayer time (customizable from 5 to 60 minutes)
- **Individual Control**: Enable/disable notifications for each prayer separately
- **Persistent Notification**: Always-on notification showing the next prayer time that **cannot be dismissed**
- **Background Service**: Runs reliably in the background for timely alerts
- **Non-Dismissible Service**: Foreground service notification stays in the notification panel permanently
- **Universal Compatibility**: Works on all Android devices including Huawei/Honor

#### 🔇 Automatic Silent Mode
- **Prayer Time Silence**: Automatically silence your phone during prayer times
- **Customizable Duration**: Set different durations before and after each prayer (5-120 minutes)
- **Individual Settings**: Configure silent mode for each prayer independently
- **Smart Automation**: Works seamlessly in the background

#### 🌍 Location Services
- **Auto-Detection**: Automatically detects your location
- **Manual Refresh**: Update location whenever needed
- **Cache System**: Stores prayer times for offline access
- **Location Change Detection**: Updates prayer times when you move to a new location

#### 🎨 User Interface
- **Modern Design**: Clean and intuitive material design
- **Dark Mode**: Eye-friendly dark theme support
- **Bilingual**: Full support for English and Turkish
- **Smooth Animations**: Beautiful transitions and animations
- **Responsive Layout**: Works perfectly on all screen sizes

#### ⚙️ Settings & Customization
- **Language Selection**: Switch between English and Turkish
- **Theme Selection**: Choose between light and dark modes
- **Battery Optimization**: Guidance for ensuring background service reliability
- **Cache Management**: Clear cached data when needed

### 📱 Screenshots

<div align="center">
  <img src="assets/screenShots/en/en_splashScreen.png" width="200" />  
  <img src="assets/screenShots/en/en_homeScreen.png" width="200" />
  <img src="assets/screenShots/en/en_monthly.png" width="200" /> 
  <br /> <img src="assets/screenShots/en/en_weekly.png" width="200" />
  <img src="assets/screenShots/en/en_settings.png" width="200" />    
  <img src="assets/screenShots/en/en_notification.png" width="200" />
</div>

### 🚀 Version History

#### Version 0.5.4 (Latest) - Huawei Device Fix 🔧
- **🔧 Critical Fix**: Resolved crash issue on Huawei and Honor devices
- **📱 Notification Icon Fix**: Fixed notification icon compatibility problem that caused crashes
- **✅ Universal Compatibility**: App now works smoothly on all Android devices including Huawei/Honor
- **🛡️ Enhanced Stability**: Improved error handling and device compatibility

#### Version 0.5.3 - Notification Enhancement 🔔
- **🔒 Non-Dismissible Notification**: Foreground service notification now stays permanently in the notification panel
- **✨ Improved Reliability**: Users can no longer accidentally dismiss the prayer time notification
- **📱 Better User Experience**: Notification remains visible to always show the next prayer time
- **🎯 Enhanced Background Service**: More stable and reliable background operation

#### Version 0.5.2 - Critical Bug Fix 🔧
- **🔋 Battery Optimization Fix**: Fixed critical issue where devices were killing the app in background
- **✅ Automatic Permission Dialog**: App now automatically prompts users to disable battery optimization on first launch
- **📱 Improved Reliability**: Background service now runs more reliably with proper battery optimization settings
- **🐛 Bug Fixes**: Resolved app termination issues on various Android devices

#### Version 0.5.1 - Language Enhancement
- **🌐 Auto Language Detection**: App automatically detects and uses device's language on first launch
- **🐛 Bug Fixes**: Various stability improvements
- **⚡ Performance**: Enhanced background service reliability

#### Version 0.5.0 - Major Update
- **🔔 Background Service**: Persistent notifications for prayer times
- **🔇 Automatic Silent Mode**: Phone automatically silences during prayer times
- **📅 Calendar Views**: Weekly and monthly prayer calendars
- **🔋 Battery Support**: Battery optimization guidance
- **💾 Cache System**: Offline access to prayer times

### 🛠️ Technical Stack

- **Framework**: Flutter 3.0+
- **State Management**: Flutter Bloc (Cubit)
- **Local Storage**: SharedPreferences
- **HTTP Client**: Dio
- **Notifications**: flutter_local_notifications
- **Background Service**: flutter_background_service
- **Location**: Geolocator
- **Localization**: flutter_localizations
- **Timezone**: timezone

### 📦 Project Structure

```
lib/
├── core/                          # Core functionality
│   ├── services/                  # Services (notifications, location, cache)
│   │   ├── backgroundServices/    # Background service implementation
│   │   ├── locationServices/      # Location detection and management
│   │   └── notificationServices/  # Notification handling
│   ├── routing/                   # Navigation
│   ├── theme/                     # App theme
│   └── widgets/                   # Shared widgets
├── features/                      # Feature modules
│   ├── home/                      # Daily prayer times
│   ├── weeklyPrayer/             # Weekly calendar
│   ├── monthlyPrayer/            # Monthly calendar
│   ├── settings/                 # App settings
│   └── splashScreen/             # Splash screen
└── l10n/                         # Localization files
```

### 🔧 Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/prayer_time.git
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### 📝 API Integration

This app uses the [Aladhan Prayer Times API](http://api.aladhan.com/) for fetching accurate prayer times using the Diyanet calculation method.

### 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### 👨‍💻 Developer

**Created by atQs**

### 📧 Contact

For questions or support, please open an issue on GitHub.

---

<a name="turkish"></a>
## 📖 Türkçe

### Genel Bakış
Namaz Vakti, Müslümanların günlük namaz vakitlerini takip etmelerine yardımcı olan kapsamlı bir mobil uygulamadır. Uygulama, konumunuza göre doğru namaz vakitlerini sağlar, bildirim desteği ve sessiz mod otomasyonu sunar.

### ✨ Özellikler

#### 🕐 Namaz Vakitleri
- **Doğru Vakitler**: Bulunduğunuz konuma göre namaz vakitlerini getirir
- **Günlük Görünüm**: Bugünün tüm namaz programı
- **Haftalık Takvim**: Tüm hafta için namaz vakitlerini görüntüleyin
- **Aylık Takvim**: Tam ay namaz vakitleri görünümü
- **Otomatik Güncelleme**: Konum değişikliklerine göre namaz vakitleri otomatik güncellenir

#### 🔔 Akıllı Bildirimler
- **Vakit Öncesi Bildirimler**: Her namaz vaktinden önce bildirim alın (5-60 dakika arası özelleştirilebilir)
- **Bireysel Kontrol**: Her namaz için bildirimleri ayrı ayrı etkinleştirin/devre dışı bırakın
- **Kalıcı Bildirim**: **Silinemez** şekilde bir sonraki namaz vaktini gösteren sürekli bildirim
- **Arka Plan Servisi**: Zamanında uyarılar için arka planda güvenilir şekilde çalışır
- **Silinemez Servis**: Ön plan hizmet bildirimi bildirim panelinde kalıcı olarak kalır

#### 🔇 Otomatik Sessiz Mod
- **Namaz Vakti Sessizliği**: Namaz vakitlerinde telefonunuzu otomatik olarak sessize alır
- **Özelleştirilebilir Süre**: Her namaz için öncesi ve sonrası farklı süreler ayarlayın (5-120 dakika)
- **Bireysel Ayarlar**: Her namaz için sessiz modu ayrı ayrı yapılandırın
- **Akıllı Otomasyon**: Arka planda sorunsuz çalışır

#### 🌍 Konum Hizmetleri
- **Otomatik Algılama**: Konumunuzu otomatik olarak algılar
- **Manuel Yenileme**: İhtiyaç duyduğunuzda konumu güncelleyin
- **Önbellek Sistemi**: Çevrimdışı erişim için namaz vakitlerini saklar
- **Konum Değişikliği Algılama**: Yeni bir konuma taşındığınızda namaz vakitlerini günceller

#### 🎨 Kullanıcı Arayüzü
- **Modern Tasarım**: Temiz ve sezgisel materyal tasarım
- **Karanlık Mod**: Göz dostu karanlık tema desteği
- **Çift Dilli**: Tam İngilizce ve Türkçe desteği
- **Akıcı Animasyonlar**: Güzel geçişler ve animasyonlar
- **Duyarlı Düzen**: Tüm ekran boyutlarında mükemmel çalışır

#### ⚙️ Ayarlar ve Özelleştirme
- **Dil Seçimi**: İngilizce ve Türkçe arasında geçiş yapın
- **Tema Seçimi**: Açık ve koyu modlar arasında seçim yapın
- **Pil Optimizasyonu**: Arka plan hizmeti güvenilirliği için rehberlik
- **Önbellek Yönetimi**: Gerektiğinde önbelleğe alınmış verileri temizleyin

### 📱 Ekran Görüntüleri

<div align="center">
  <img src="assets/screenShots/tr/tr_splashScreen.png" width="200" />  
  <img src="assets/screenShots/tr/tr_homeScreen.png" width="200" />
  <img src="assets/screenShots/tr/tr_weekly.png" width="200" />
  <br /> <img src="assets/screenShots/tr/tr_settings.png" width="200" />    
  <img src="assets/screenShots/tr/tr_notification.png" width="200" />
</div>

### 🚀 Versiyon Geçmişi

#### Versiyon 0.5.4 (Son Güncelleme) - Huawei Cihaz Düzeltmesi 🔧
- **🔧 Kritik Düzeltme**: Huawei ve Honor cihazlardaki çökme sorunu çözüldü
- **📱 Bildirim İkonu Düzeltmesi**: Çökme sorununa yol açan bildirim ikonu uyumluluk problemi düzeltildi
- **✅ Evrensel Uyumluluk**: Uygulama artık Huawei/Honor dahil tüm Android cihazlarda sorunsuz çalışıyor
- **🛡️ Geliştirilmiş Stabilite**: Hata ayıklama ve cihaz uyumluluğu iyileştirildi

#### Versiyon 0.5.3 - Bildirim Geliştirmesi 🔔
- **🔒 Silinemez Bildirim**: Ön plan hizmet bildirimi artık bildirim panelinde kalıcı olarak kalıyor
- **✨ Geliştirilmiş Güvenilirlik**: Kullanıcılar artık namaz vakti bildirimini yanlışlıkla silemez
- **📱 Daha İyi Kullanıcı Deneyimi**: Bildirim, bir sonraki namaz vaktini her zaman göstermek için görünür kalır
- **🎯 Geliştirilmiş Arka Plan Servisi**: Daha kararlı ve güvenilir arka plan çalışması

#### Versiyon 0.5.2 - Kritik Hata Düzeltmesi 🔧
- **🔋 Pil Optimizasyonu Düzeltmesi**: Cihazların uygulamayı arka planda kapatması sorunu çözüldü
- **✅ Otomatik İzin Diyalogu**: Uygulama artık ilk açılışta otomatik olarak pil optimizasyonunu devre dışı bırakma isteği gösteriyor
- **📱 Geliştirilmiş Güvenilirlik**: Arka plan servisi, doğru pil optimizasyon ayarlarıyla daha güvenilir çalışıyor
- **🐛 Hata Düzeltmeleri**: Çeşitli Android cihazlarda uygulama sonlandırma sorunları çözüldü

#### Versiyon 0.5.1 - Dil Geliştirmesi
- **🌐 Otomatik Dil Algılama**: Uygulama artık ilk açılışta cihazınızın dilini otomatik olarak algılayıp kullanıyor
- **🐛 Hata Düzeltmeleri**: Çeşitli stabilite iyileştirmeleri
- **⚡ Performans**: Geliştirilmiş arka plan hizmeti güvenilirliği

#### Versiyon 0.5.0 - Büyük Güncelleme
- **🔔 Arka Plan Servisi**: Namaz vakitleri için kalıcı bildirimler
- **🔇 Otomatik Sessiz Mod**: Namaz vakitlerinde telefon otomatik olarak sessizleşiyor
- **📅 Takvim Görünümleri**: Haftalık ve aylık namaz takvimleri
- **🔋 Pil Desteği**: Pil optimizasyon rehberliği
- **💾 Önbellek Sistemi**: Namaz vakitlerine çevrimdışı erişim

### 🛠️ Teknoloji Yığını

- **Framework**: Flutter 3.0+
- **Durum Yönetimi**: Flutter Bloc (Cubit)
- **Yerel Depolama**: SharedPreferences
- **HTTP İstemcisi**: Dio
- **Bildirimler**: flutter_local_notifications
- **Arka Plan Servisi**: flutter_background_service
- **Konum**: Geolocator
- **Yerelleştirme**: flutter_localizations
- **Saat Dilimi**: timezone

### 📦 Proje Yapısı

```
lib/
├── core/                          # Temel işlevsellik
│   ├── services/                  # Servisler (bildirimler, konum, önbellek)
│   │   ├── backgroundServices/    # Arka plan servisi implementasyonu
│   │   ├── locationServices/      # Konum algılama ve yönetimi
│   │   └── notificationServices/  # Bildirim yönetimi
│   ├── routing/                   # Navigasyon
│   ├── theme/                     # Uygulama teması
│   └── widgets/                   # Paylaşılan widget'lar
├── features/                      # Özellik modülleri
│   ├── home/                      # Günlük namaz vakitleri
│   ├── weeklyPrayer/             # Haftalık takvim
│   ├── monthlyPrayer/            # Aylık takvim
│   ├── settings/                 # Uygulama ayarları
│   └── splashScreen/             # Açılış ekranı
└── l10n/                         # Yerelleştirme dosyaları
```

### 🔧 Kurulum

1. Depoyu klonlayın:
```bash
git clone https://github.com/yourusername/prayer_time.git
```

2. Bağımlılıkları yükleyin:
```bash
flutter pub get
```

3. Uygulamayı çalıştırın:
```bash
flutter run
```

### 📝 API Entegrasyonu

Bu uygulama, Diyanet hesaplama yöntemini kullanarak doğru namaz vakitlerini almak için [Aladhan Namaz Vakitleri API](http://api.aladhan.com/)'sini kullanır.

### 🤝 Katkıda Bulunma

Katkılar memnuniyetle karşılanır! Lütfen Pull Request göndermekten çekinmeyin.

### 📄 Lisans

Bu proje MIT Lisansı altında lisanslanmıştır - detaylar için [LICENSE](LICENSE) dosyasına bakın.

### 👨‍💻 Geliştirici

**atQs tarafından oluşturuldu**

### 📧 İletişim

Sorularınız veya destek için GitHub'da bir issue açın.

---

<div align="center">

**Made with ❤️ and Flutter**

**❤️ ve Flutter ile yapıldı**

</div>
