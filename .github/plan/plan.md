Proje Spesifikasyonu: FocusLocal (Gizlilik Odaklı Yapılacaklar Uygulaması)
1. Proje Özeti
FocusLocal, kullanıcı verilerini asla buluta çıkarmayan, tamamen cihaz yerelinde (Hive) saklayan, yüksek performanslı ve gizlilik odaklı bir To-Do uygulamasıdır. Apple App Store "Spam" politikalarını aşmak için standart dışı bir UI/UX yapısı ve 10 dilde yerelleştirme desteği sunar.

2. Teknoloji Yığını ve Kısıtlamalar
Framework: Flutter

Durum Yönetimi (State Management): GetX

Temel Görünüm: GetView<T> (Kesinlikle StatelessWidget veya StatefulWidget kullanılmayacak).

Yerel Veritabanı: Hive (Cloud/Firebase entegrasyonu yok).

Tema Yönetimi: Merkezi Tema Yönetimi (Kod içinde asla Color(0xFF...) gibi inline renk kodu yazılmayacak).

Yerelleştirme: GetX Translations (Desteklenen diller: TR, EN, ZH, HI, ES, PT, FR, AR, RU, DE).

3. Mimari ve Dosya Yapısı
Plaintext
lib/
├── app/
│   ├── core/
│   │   ├── theme/          # AppThemes, AppColors, TextStyles (Merkezi Tema)
│   │   ├── values/         # Sabitler, Asset yolları
│   │   └── translations/   # 10 dilde çeviri dosyaları
│   ├── data/
│   │   ├── models/         # Hive TypeAdapter ve Veri Modelleri
│   │   ├── providers/      # Hive Box yardımcıları
│   │   └── services/       # Veritabanı ve Ayar servisleri
│   ├── modules/
│   │   ├── home/           # View (GetView), Controller, Binding
│   │   └── task_detail/    # View (GetView), Controller, Binding
│   └── routes/             # AppRoutes ve AppPages (GetPage)
└── main.dart
4. Copilot Agent İçin Kodlama Kuralları
View Katmanı: Her sayfa/ekran GetView<ControllerName> sınıfından türetilmelidir. UI güncellemeleri için Obx veya GetBuilder kullanılacaktır.

Mantık Katmanı: Tüm iş mantığı GetxController içinde olmalıdır. Hive veri yükleme işlemleri onInit içinde yönetilmelidir.

Tema Kuralı: Renkler sadece Get.theme.colorScheme veya AppColors sınıfından çekilmelidir. Dinamik tema desteği (Açık, Koyu, Özel Temalar) her zaman korunmalıdır.

Veritabanı Kuralı: Hive işlemleri DataService içinde soyutlanmalıdır. Karmaşık objeler için TypeAdapter kullanılmalıdır.

Dil Kuralı: Tüm metinler .tr uzantısı ile çağrılmalıdır (Örn: 'add_task'.tr).

5. Uygulama Görev Listesi (Task List)
Aşama 1: Altyapı ve Hazırlık
[ ] Flutter projesini oluştur ve bağımlılıkları ekle: get, hive, hive_flutter, path_provider.

[ ] AppTheme sınıfını oluştur: En az 3 mod (Açık, Koyu, Karbon/High Contrast).

[ ] 10 dil için TranslationService (GetX Translations) yapısını kur.

[ ] main.dart içinde Hive'ı başlat ve TaskAdapter kaydını yap.

Aşama 2: Tema ve Stil Yönetimi
[ ] AppColors sınıfını tanımla (Anlamsal isimlendirme: primaryAction, surfaceColor vb.).

[ ] ThemeService ile tema değiştirme ve seçilen temayı Hive'da saklama özelliğini ekle.

Aşama 3: Veritabanı ve Modeller
[ ] TaskModel oluştur (id, başlık, öncelik, enerji seviyesi, tamamlandı mı, tarih).

[ ] HiveService ile CRUD işlemlerini yaz: addTask, getTasks, updateTask, deleteTask.

Aşama 4: Modül Geliştirme (UI/UX)
[ ] Home Modülü: GetView kullanarak Bento-box veya Timeline tabanlı ana ekranı tasarla.

[ ] Görev Filtreleme: Görevleri "Enerji Seviyesi" veya "Önem" sırasına göre filtreleyen controller mantığını yaz.

[ ] Bindings: Controller ve View bağlantılarını Get.lazyPut() ile yap.

Aşama 5: Apple Onayı İçin Farklılaştırma
[ ] Görev tamamlama için özel HapticService (titreşimli geri bildirim) ekle.

[ ] "Sadece Yerel Depolama" (Local-Only) güvenlik rozetini ve UI bilgilendirmesini ekle.

[ ] Liste geçişleri için standart dışı, akıcı animasyonlar (Custom Transitions) tanımla.

6. Copilot İçin Örnek Komut Talimatları
"Bana [Modül Adı] için GetX yapısında View, Controller ve Binding dosyalarını oluştur."

"TaskModel için bir Hive TypeAdapter oluştur."

"Bu View'daki tüm inline renkleri AppTheme içindeki merkezi sistemle değiştir."

"Verilerin sadece yerelde saklandığını anlatan şık bir 'Hakkında' sayfası (GetView) tasarla."

