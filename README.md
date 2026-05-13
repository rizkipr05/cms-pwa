# CMS PWA Presensi

Dokumen ini menjelaskan cara menjalankan proyek presensi ini secara lokal mulai dari setup database di phpMyAdmin sampai semua aplikasi aktif:

- `backend`: API Node.js + Express + Sequelize
- `cms`: panel admin React + Vite
- `frontend`: aplikasi Flutter untuk user/admin

File contoh environment backend tersedia di [backend/.env.example](/opt/lampp/htdocs/cms-pwa/backend/.env.example).

## 1. Gambaran Arsitektur

Proyek ini tidak memakai PHP untuk backend utama. XAMPP dipakai untuk:

- Menjalankan `MySQL/MariaDB`
- Membuka `phpMyAdmin`
- Menyimpan folder proyek di `htdocs` bila diinginkan

Komponen yang berjalan:

- Database: `MariaDB/MySQL` dari XAMPP
- Backend API: `http://127.0.0.1:3000`
- CMS Admin: `http://127.0.0.1:5173`
- Flutter app: berjalan dari emulator, device, atau desktop Flutter

## 2. Prasyarat

Pastikan tools berikut sudah tersedia:

- XAMPP
- Node.js dan npm
- Flutter SDK
- Git
- Browser

Versi minimum yang aman untuk mengikuti proyek ini:

- XAMPP dengan MySQL/MariaDB aktif
- Node.js 18 atau lebih baru
- Flutter 3.x

## 3. Struktur Folder Penting

- [database/db_presensi.sql](/opt/lampp/htdocs/cms-pwa/database/db_presensi.sql): dump database untuk impor lewat phpMyAdmin
- [backend](/opt/lampp/htdocs/cms-pwa/backend): REST API
- [cms](/opt/lampp/htdocs/cms-pwa/cms): dashboard admin berbasis React
- [frontend](/opt/lampp/htdocs/cms-pwa/frontend): aplikasi Flutter

## 4. Menyalakan XAMPP

1. Buka XAMPP Control Panel.
2. Start `Apache`.
3. Start `MySQL`.

Catatan:

- `Apache` dipakai agar akses `phpMyAdmin` mudah lewat browser.
- Backend proyek ini tetap berjalan lewat Node.js, bukan lewat Apache.

## 5. Membuat Database di phpMyAdmin

1. Buka `http://localhost/phpmyadmin`.
2. Klik tab `Databases`.
3. Buat database baru dengan nama `db_presensi`.
4. Gunakan collation default `utf8mb4_general_ci` bila diminta.
5. Setelah database jadi, klik database `db_presensi`.
6. Buka tab `Import`.
7. Pilih file [database/db_presensi.sql](/opt/lampp/htdocs/cms-pwa/database/db_presensi.sql).
8. Klik `Go` atau `Import`.

Jika impor berhasil, minimal akan terbentuk tabel:

- `users`
- `schedules`
- `attendances`

## 6. Jika Import SQL Gagal

Dump SQL saat ini berisi banyak `UNIQUE KEY` duplikat pada kolom `email` di tabel `users`. Di beberapa instalasi MariaDB, impor tetap berhasil. Di mesin lain, impor bisa gagal saat menambahkan index.

Jika itu terjadi:

1. Hapus database `db_presensi`.
2. Buat ulang database `db_presensi`.
3. Edit file SQL sebelum impor, lalu pada bagian `ALTER TABLE users` sisakan satu baris unique key untuk `email`.

Bagian yang aman cukup seperti ini:

```sql
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);
```

Setelah itu, impor ulang file SQL.

## 7. Konfigurasi Environment Backend

Backend membaca koneksi database dari file `.env`.

1. Masuk ke folder [backend](/opt/lampp/htdocs/cms-pwa/backend).
2. Salin isi file contoh [backend/.env.example](/opt/lampp/htdocs/cms-pwa/backend/.env.example) ke file baru `backend/.env`.
3. Sesuaikan nilainya.

Contoh isi `backend/.env`:

```env
PORT=3000
DB_HOST=127.0.0.1
DB_USER=root
DB_PASS=
DB_NAME=db_presensi
JWT_SECRET=ganti_dengan_secret_yang_aman
```

Penjelasan:

- `PORT`: port backend Express
- `DB_HOST`: host database XAMPP, umumnya `127.0.0.1`
- `DB_USER`: user database, default XAMPP biasanya `root`
- `DB_PASS`: password database XAMPP, default sering kosong
- `DB_NAME`: nama database yang diimpor, harus `db_presensi`
- `JWT_SECRET`: secret untuk token login, wajib diisi

## 8. Install Dependency

Jalankan perintah berikut dari terminal terpisah.

### Backend

```bash
cd /opt/lampp/htdocs/cms-pwa/backend
npm install
```

### CMS

```bash
cd /opt/lampp/htdocs/cms-pwa/cms
npm install
```

### Flutter Frontend

```bash
cd /opt/lampp/htdocs/cms-pwa/frontend
flutter pub get
```

## 9. Menjalankan Backend API

Masuk ke folder backend lalu jalankan:

```bash
cd /opt/lampp/htdocs/cms-pwa/backend
npm run dev
```

Atau tanpa nodemon:

```bash
cd /opt/lampp/htdocs/cms-pwa/backend
npm start
```

Jika berhasil, terminal biasanya menampilkan informasi bahwa database tersambung dan server berjalan di port `3000`.

Endpoint dasar yang bisa dicek di browser:

- `http://127.0.0.1:3000/`

Respon normal:

```text
Attendance API is running...
```

Catatan penting:

- Saat server start, Sequelize menjalankan `sequelize.sync({ alter: true })`.
- Artinya struktur tabel bisa disesuaikan otomatis dengan model backend.
- Tetap disarankan mengimpor SQL dulu agar akun demo dan data awal tersedia.

## 10. Menjalankan CMS Admin

Masuk ke folder CMS:

```bash
cd /opt/lampp/htdocs/cms-pwa/cms
npm run dev
```

Lalu buka alamat yang ditampilkan Vite, biasanya:

- `http://127.0.0.1:5173`

Penjelasan koneksi CMS:

- CMS memanggil API melalui path `/api`
- Vite akan mem-proxy request itu ke `http://127.0.0.1:3000`
- Karena itu backend harus aktif lebih dulu

Konfigurasi proxy ada di [cms/vite.config.js](/opt/lampp/htdocs/cms-pwa/cms/vite.config.js).

## 11. Menjalankan Frontend Flutter

Masuk ke folder frontend:

```bash
cd /opt/lampp/htdocs/cms-pwa/frontend
flutter run
```

Secara default aplikasi Flutter memakai base URL berikut:

```text
http://localhost:3000/api
```

Nilai ini berasal dari [frontend/lib/core/api_service.dart](/opt/lampp/htdocs/cms-pwa/frontend/lib/core/api_service.dart).

### Jika dijalankan di emulator Android

`localhost` pada emulator Android mengarah ke emulator itu sendiri, bukan ke komputer host. Gunakan:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api
```

### Jika dijalankan di device fisik

Gunakan IP laptop atau PC di jaringan yang sama, contoh:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000/api
```

Syaratnya:

- HP dan komputer satu jaringan
- firewall mengizinkan koneksi ke port `3000`
- backend berjalan dengan normal

### Jika dijalankan di Chrome atau desktop Flutter

Biasanya cukup:

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000/api
```

Jika browser/device tidak bisa membaca `localhost`, ganti dengan `127.0.0.1` atau IP LAN komputer.

## 12. Akun Login Default

Data ini tersedia dari dump SQL dan juga cocok dengan file seeder backend:

### Admin CMS / Admin Flutter

- Email: `admin@presensi.com`
- Password: `admin123`

### User Karyawan

- Email: `user@presensi.com`
- Password: `user123`

## 13. Opsi Seeder Jika Tidak Import SQL

Kalau Anda tidak memakai dump SQL dan hanya ingin membuat tabel dari backend, langkahnya:

1. Buat database kosong `db_presensi`.
2. Jalankan backend sekali agar tabel dibuat oleh Sequelize.
3. Jalankan seeder manual dari folder backend.

Seeder admin:

```bash
cd /opt/lampp/htdocs/cms-pwa/backend
node src/seeders/adminSeeder.js
```

Seeder user demo:

```bash
cd /opt/lampp/htdocs/cms-pwa/backend
node src/seeders/userSeeder.js
```

Cara ini berguna jika impor SQL bermasalah dan Anda hanya butuh akun awal.

## 14. Urutan Menjalankan Proyek

Urutan paling aman setiap kali development:

1. Start `Apache` dan `MySQL` dari XAMPP
2. Pastikan database `db_presensi` sudah ada
3. Jalankan backend `npm run dev`
4. Jalankan CMS `npm run dev`
5. Jalankan Flutter `flutter run`

## 15. Troubleshooting

### `Access denied for user 'root'@'localhost'`

Penyebab:

- username atau password database di `backend/.env` tidak cocok

Solusi:

- cek kembali `DB_USER` dan `DB_PASS`
- pastikan MySQL XAMPP benar-benar aktif

### `Unknown database 'db_presensi'`

Penyebab:

- database belum dibuat atau nama database salah

Solusi:

- buat database `db_presensi` di phpMyAdmin
- pastikan `DB_NAME=db_presensi`

### CMS tidak bisa login atau muncul error koneksi

Penyebab:

- backend belum jalan
- backend jalan di port berbeda

Solusi:

- cek backend di `http://127.0.0.1:3000`
- cek file [cms/vite.config.js](/opt/lampp/htdocs/cms-pwa/cms/vite.config.js)

### Flutter login gagal padahal backend aktif

Penyebab:

- `localhost` tidak bisa dijangkau dari emulator atau device

Solusi:

- pakai `10.0.2.2` untuk emulator Android
- pakai IP LAN komputer untuk device fisik
- kirim `--dart-define=API_BASE_URL=...` saat `flutter run`

### Error izin lokasi saat check-in

Penyebab:

- fitur presensi memakai GPS/lokasi

Solusi:

- aktifkan izin lokasi di emulator atau device
- pastikan GPS tersedia

### Import SQL gagal saat index `email`

Penyebab:

- file dump berisi beberapa `UNIQUE KEY` duplikat

Solusi:

- edit file SQL dan sisakan satu unique key saja untuk `email`
- atau gunakan metode seeder

## 16. Ringkasan Cepat

Kalau ingin versi singkat:

1. Start `Apache` dan `MySQL` di XAMPP
2. Buat database `db_presensi` di `http://localhost/phpmyadmin`
3. Import [database/db_presensi.sql](/opt/lampp/htdocs/cms-pwa/database/db_presensi.sql)
4. Buat `backend/.env` dari [backend/.env.example](/opt/lampp/htdocs/cms-pwa/backend/.env.example)
5. Jalankan `npm install` di `backend` dan `cms`
6. Jalankan `flutter pub get` di `frontend`
7. Jalankan backend: `npm run dev`
8. Jalankan CMS: `npm run dev`
9. Jalankan Flutter: `flutter run`

## 17. File Referensi Konfigurasi

- [backend/src/config/database.js](/opt/lampp/htdocs/cms-pwa/backend/src/config/database.js)
- [backend/src/index.js](/opt/lampp/htdocs/cms-pwa/backend/src/index.js)
- [cms/vite.config.js](/opt/lampp/htdocs/cms-pwa/cms/vite.config.js)
- [frontend/lib/core/api_service.dart](/opt/lampp/htdocs/cms-pwa/frontend/lib/core/api_service.dart)
