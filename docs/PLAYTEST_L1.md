# PLAYTEST CHECKLIST — LEVEL 1 (KOTA DATA: LAPISAN L7, L6, L5)

Dokumen ini berisi panduan dan checklist verifikasi playtest untuk **Level 1 — Kota Data** dalam game *Packet Hero*. Checklist ini mencakup pengujian durasi, titik buntu, jangkauan koleksi, sebaran checkpoint, dan keadilan penempatan musuh.

---

## 1. Ringkasan Desain & Target Verifikasi

| Parameter Uji | Target Desain | Status Verifikasi Desain | Catatan |
|---|---|---|---|
| **Durasi Level** | 8 – 10 Menit | **VALID (~9.5 Menit)** | Terbagi dalam 5 seksi berkesinambungan |
| **Titik Buntu (Deadlock)** | 0 Titik Buntu | **VALID (Bebas Softlock)** | Sistem auto-reset token & fail-safe timer sesi |
| **Koleksi Terjangkau** | 100% Dapat Diraih | **VALID (Semua Terjangkau)** | 3 Artefak, 1 Kunci Port, 4 Booster, 5 Energy Cell |
| **Kerapatan Checkpoint** | Tiap 2 – 3 Menit | **VALID (4 Checkpoint)** | Jarak rata-rata 2000–2500 px (~2–2.5 menit) |
| **Keadilan Musuh** | Tidak ada musuh mutlak | **VALID (Fair & Dodgeable)** | Semua musuh memiliki celah stomping / evasion |

---

## 2. Checklist Detail per Seksi

### Seksi 1: Startup Plaza (X = 0 s.d. 1500)
- [ ] **Papan Petunjuk (Signboards):** Ketiga papan petunjuk (Gerak, Lompat, Interaksi) dapat dibaca jelas dengan font pixel.
- [ ] **Koin Plaza:** Seluruh 8 koin (`PlazaCoin1` s.d. `PlazaCoin8`) dapat dikumpulkan tanpa rintangan mematikan.
- [ ] **Spam Drone Latihan:** `SpamDrone_Plaza` di $X=1100$ mudah diinjak dari atas untuk latihan stomping pemain pemula.
- [ ] **Terminal Plaza:** Interaksi `[E]` membuka kotak dialog tutorial awal dan menutup dengan mulus saat ditekan kembali.
- [ ] **Checkpoint 0 (Toko Awal):** `CP0` di $X=760$ aktif saat disentuh, memulihkan HP, dan membuka toko saat `[E]` ditekan.

### Seksi 2: HTTP Boulevard — Lapisan 7 (X = 1500 s.d. 3000)
- [ ] **Lencana Protokol (Carry Items):** Lencana `HTTP`, `SMTP`, dan `DNS` dapat diambil dengan tombol `E` dan melayang di atas kepala Hero.
- [ ] **Slot Gedung (Carry Slots):**
  - Meletakkan lencana pada slot yang cocok (`WEB` $\leftarrow$ `HTTP`, `MAIL` $\leftarrow$ `SMTP`, `DNS` $\leftarrow$ `DNS`) memicu status *accepted* dengan bubble dialog hijau.
  - Meletakkan lencana pada slot yang salah memicu penolakan visual; lencana kembali ke posisi asal tanpa damage.
- [ ] **Kunci Port #1:** Tersembunyi di balik gedung DNS di atas `Plat_DNS_Side` ($X=2960, Y=430$), dapat dijangkau lewat tangga samping atau drop dari skyway. Mengambilnya memberikan +50 EXP dan tersimpan di `GameState.port_keys`.
- [ ] **Artefak #1:** Terletak di atap tertinggi sub-stasi ($X=2250, Y=115$), dapat diraih melalui platforming tangga sub-stasi.
- [ ] **Terminal L7 & QuizGate L7:**
  - `Terminal_L7` terkunci sebelum 3 slot terisi.
  - Setelah 3 slot terisi, Terminal aktif dan membuka `GateL7`.
  - Melewati `GateL7` memicu kuis L7 (Aplikasi); menjawab benar membuka gerbang secara permanen.
- [ ] **Checkpoint 1:** `CP1` di $X=2780$ aktif sebelum Gerbang L7.

### Seksi 3: Encoding Alley — Lapisan 6 (X = 3000 s.d. 5300)
- [ ] **Token Data Mentah:** Pemain dapat mengambil `TokenData` di awal gang.
- [ ] **Urutan Pemrosesan Data:**
  - Urutan benar: Masuk Stasiun Kompresi (`RAW` $\rightarrow$ `COMPRESSED`), lalu masuk Stasiun Enkripsi (`COMPRESSED` $\rightarrow$ `READY`).
  - Urutan salah: Masuk Enkripsi saat masih `RAW` $\rightarrow$ status berubah `INVALID` (*"Terenkripsi, sulit dikompres"*).
  - Slot keluar `Slot_Exit_L6` hanya menerima token berstatus `READY`. Jika `INVALID`, token ditolak dan kembali ke posisi spawn dalam status `RAW`.
- [ ] **Platforming Cekungan:** Dua platform bergerak (`MovingPlat_Alley_1` dan `2`) bergerak harmonis menyeberangi `DataCorruptionPool_Alley` tanpa celah jatuh mutlak.
- [ ] **Artefak #2:** Terletak di balik stasiun enkripsi ($X=4750, Y=575$) dan dapat diambil dengan mudah.
- [ ] **QuizGate L6:** Terbuka setelah `Slot_Exit_L6` menerima data yang valid, memicu kuis L6 (Presentasi).

### Seksi 4: Session Tower — Lapisan 5 (X = 5300 s.d. 7100)
- [ ] **Checkpoint 2:** `CP2` di $X=5350$ aktif di dasar menara sebelum memulai panjat sesi.
- [ ] **Mekanik Timer Sesi:**
  - Saklar dasar di $X=5500$ memulai sesi transmisi dengan timer 60 detik (tampil di HUD `LblTimer`).
  - Mengambil token keep-alive (3 buah di jalur panjat) menambah waktu $+10$ detik per token.
  - Tuas di puncak ($X=6380, Y=250$) menutup sesi, menghentikan timer, dan meng-unlock `GateL5`.
- [ ] **Fail-Safe Timeout:** Jika waktu 60 detik habis sebelum tuas ditarik, pemain diteleportasi kembali ke dasar menara ($X=5500, Y=580$) tanpa pengurangan Integrity, dan token keep-alive di-reset kembali.
- [ ] **Artefak #3:** Terletak di puncak menara ($X=6440, Y=230$) dekat tuas penutup sesi.
- [ ] **QuizGate L5:** Terletak di dasar setelah menara ($X=7050$), memicu kuis L5 (Sesi).

### Seksi 5: Exit Gateway (X = 7100 s.d. 8500)
- [ ] **Terminal Ringkasan:** `Terminal_Summary` di $X=7250$ menampilkan pesan edukasi pemulihan protokol lapisan atas (L7 $\rightarrow$ L5) saat berinteraksi.
- [ ] **Checkpoint 3 (Toko Akhir):** `CP3` di $X=7450$ membuka `UI_Shop` untuk persiapan menuju Level 2.
- [ ] **Booster Exit:** Terletak di $X=7650$ memberikan dorongan kecepatan akhir.
- [ ] **Portal Exit & UI_LevelComplete:**
  - Menyentuh `PortalExit` di $X=8450$ memunculkan layar ringkasan `UI_LevelComplete` dan mem-pause permainan.
  - Statistik EXP, Bandwidth, Artefak ($x/3$), dan Integritas ($x/x$) tampil akurat sesuai data sesi pemain.
  - Menekan tombol *"LANJUTKAN KE LEVEL 2"* memicu efek pudar hitam (`SceneTransition`) menuju `Level_2.tscn`.

---

## 3. Laporan Temuan Audit Level 1

Berdasarkan audit menyeluruh terhadap arsitektur scene `Level_1.tscn` dan parameter gameplay:

1. **Temuan 1 (Duplikasi Objek Artefak L6):**
   - Terdapat node lama `Artifact2` di $X=6550, Y=345$ (sisa template awal) yang menggunakan `item_id = "artifact_L6"`.
   - Node resmi Artefak #2 yang dibangun pada P-26 adalah `Artifact2_Alley` di $X=4750, Y=575$ (di balik mesin enkripsi sesuai brief).
   - *Dampak:* Karena keduanya memiliki ID sama, pemain yang mengambil salah satu akan menonaktifkan yang lain saat reload/save, namun keberadaan dua artefak L6 di level yang sama dapat membingungkan penjelajahan pemain.

2. **Temuan 2 (Penempatan Booster Level 1):**
   - Dalam `docs/LEVEL_DESIGN.md` Bagian 4.5 tertulis: *"Booster (4): Encoding Alley x2, Session Tower x1, Exit x1"*.
   - Saat ini penempatan Booster di scene adalah:
     - `Booster1`: $X=1350$ (Startup Plaza / transisi menuju Boulevard)
     - `Booster2`: $X=4250$ (Encoding Alley)
     - `Booster_Alley`: $X=4380$ (Encoding Alley)
     - `Booster_Exit`: $X=7650$ (Exit Gateway)
   - *Dampak:* Session Tower tidak memiliki Booster, padahal penempatan Booster di Session Tower sangat berguna untuk membantu ritme memanjat cepat melawan timer 60 detik.

3. **Temuan 3 (Checkpoint Shop):**
   - Checkpoint Toko berada di `CP0` (Plaza) dan `CP3` (Exit Gateway).
   - Checkpoint `CP1` dan `CP2` berfungsi sebagai checkpoint murni (pemulihan HP dan titik spawn) tanpa membuka menu toko.
   - *Dampak:* Sangat seimbang dan sesuai alur narasi, di mana pemain berbelanja di awal plaza dan di akhir gerbang sebelum lanjut ke Level 2.

---

## 4. Perubahan Kecil yang Telah Diterapkan (Disetujui Pengguna)

Perubahan berikut telah dieksekusi dan diverifikasi pada `Level_1.tscn`:

- [x] **Usulan A (Hapus Node Duplikat Artefak L6) — SELESAI:**
  Node duplikat lama `Pickups/Artifact2` ($X=6550, Y=345$) telah dihapus dari `Level_1.tscn`. Koleksi Artefak #2 kini murni dan tunggal di `Artifact2_Alley` ($X=4750, Y=575$) di balik Stasiun Enkripsi sesuai LEVEL_DESIGN 4.1.
- [x] **Usulan B (Pindahkan Booster ke Session Tower) — SELESAI:**
  Node `Booster1` dari Plaza telah dipindahkan dan disesuaikan menjadi `Booster_Tower` di dasar menara sesi ($X=5580, Y=575$, `jenis = 3`) tepat setelah saklar sesi, sehingga distribusi 4 booster Level 1 kini 100% cocok dengan LEVEL_DESIGN 4.5 (*"Encoding Alley x2, Session Tower x1, Exit x1"*).
