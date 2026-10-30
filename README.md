# Rupa Rempah Solo - UTS PPB (NIM Ganjil)

Aplikasi kasir produk UMKM dengan Flutter (Material Design 3). Halaman: splash, login, daftar akun, dashboard, detail produk, pembayaran, dan ubah akun. Data produk di `lib/data/product_data.dart`. Tidak memerlukan backend.

## Menyiapkan proyek

1. Pastikan Flutter tersedia: `flutter doctor`.
2. Buat scaffold Android lengkap: buka direktori ini dan jalankan `flutter create --platforms=android .`. Perintah ini menambahkan direktori bawaan Flutter seperti `android/` yang tidak ikut disimpan dalam paket kode sumber.
3. Jalankan `flutter pub get`.
4. Periksa perangkat: `flutter devices`.
5. Jalankan di Android: `flutter run -d <device_id>`.

Alternatif: jalankan `flutter create rupa_rempah_solo`, lalu salin folder `lib/`, `assets/`, dan `pubspec.yaml` dari paket ini ke proyek yang dibuat Flutter.

## Paket

`shared_preferences` menyimpan satu akun lokal (nama, username, password) dan status masuk. `url_launcher` mengakses aplikasi telepon, SMS dan Maps. Tidak ada integrasi pembayaran daring.

## Konfigurasi kontak penjual

Edit `lib/services/contact_service.dart`:
- `sellerPhone = '628xxxxxxxxxx'` ganti dengan nomor kontak resmi yang terverifikasi (tanpa tanda `+` atau spasi untuk keamanan saat membuat URL).
- `mapsQuery = 'alamat atau koordinat resmi'` ganti dengan alamat agen/koordinat terverifikasi.

Sebelum diisi, menu panggilan/SMS/Maps memberikan pesan konfigurasi belum tersedia. Untuk uji telepon/SMS, gunakan Android fisik yang mempunyai aplikasi terkait; perilaku emulator bisa terbatas.

## Cara pakai

1. Buka aplikasi: splash -> login. Tekan **Daftar** untuk membuat akun pertama kali.
2. Login memakai data yang didaftarkan. Status masuk tersimpan.
3. Di dashboard, **ketuk gambar** produk untuk menambah satu unit. **Ketuk nama** untuk detail.
4. Ketuk ringkasan total di bawah untuk pembayaran; isi uang diterima. Tombol konfirmasi aktif hanya jika cukup.
5. Setelah konfirmasi berhasil, daftar belanja dikosongkan di dashboard.
6. Menu atas kanan untuk telepon/SMS/Maps (perlu konfigurasi), ubah user/password, dan logout.

## Membuat APK

`flutter build apk --release`

Hasil: `build/app/outputs/flutter-apk/app-release.apk`.

Pilihan APK lebih kecil per arsitektur: `flutter build apk --split-per-abi`.

## Peringatan

Proyek ini demo tugas dengan satu akun lokal. Password disimpan dalam bentuk teks biasa melalui SharedPreferences, **bukan** pilihan aman untuk aplikasi produksi. Untuk produk nyata, gunakan backend autentikasi dan mekanisme penyimpanan kredensial yang aman. Tidak menyimpan riwayat transaksi, tidak terhubung ke server, dan tidak memproses uang sungguhan.
