# Decisions

## D-01: Perilaku KillZone, Kematian, dan Checkpoint
- **Konteks:** Spesifikasi meminta pemain jatuh ke KillZone mengurangi Integrity 1 dan pindah ke titik aman terakhir (checkpoint), serta saat player_died memunculkan layar overlay "Koneksi Terputus" (1,5 detik) dan reset group resettable tanpa save file.
- **Keputusan:**
  1. Jika Integrity > 0 setelah jatuh ke KillZone: Pemain langsung dipindahkan ke posisi checkpoint terakhir dan `velocity = Vector2.ZERO`, disertai hurt cooldown singkat agar tidak terbentur berulang.
  2. Jika Integrity mencapai 0: `GameState.take_damage()` memancarkan sinyal `player_died`. Node `UI_HUD` menampilkan overlay "KONEKSI TERPUTUS" selama 1,5 detik (`Config.DEATH_OVERLAY_DURATION`).
  3. Setelah 1,5 detik: Pemain di-respawn di checkpoint dengan `GameState.reset_for_respawn()` (Integrity kembali penuh), dan `get_tree().call_group("resettable", "reset")` dipanggil untuk me-reset entitas di grup resettable.
  4. Sesuai instruksi, tidak ada penyimpanan status ke file (`user://save.json`).

## D-02: Format Soal QuizQuestion dan QuizDatabase
- **Konteks:** Spesifikasi meminta QuizQuestion sebagai Resource bertipe dan QuizDatabase memuat .tres secara otomatis serta menyediakan get_for_layer(layer_id) yang mengembalikan soal acak.
- **Keputusan:**
  1. `docs/quiz_bank.md` didokumentasikan sebagai sumber acuan soal edukasi (dimulai dari 3 soal L7).
  2. `QuizQuestion` mewarisi `Resource` dengan semua atribut static typing dan helper `to_dict()`.
  3. `QuizDatabase` memindai direktori `res://resources/questions/` menggunakan `DirAccess` dan mengelompokkan `QuizQuestion` berdasarkan `layer_id`.
  4. `get_for_layer(layer_id: String) -> QuizQuestion` mengembalikan satu soal acak menggunakan `Array.pick_random()`, atau `null` jika kosong/belum ada.

## D-03: Implementasi UI_Quiz dan Sistem Penilaian Kuis
- **Konteks:** Spesifikasi meminta UI_Quiz (process_mode Always) dengan 4 tombol opsi (tinggi min 56px), tombol petunjuk, area umpan balik, aturan skor (150/20 benar pertama, 75/10 benar setelah salah, damage 1 + acak ulang opsi saat salah, +100 EXP streak 3x benar pertama), dan integrasi debug.
- **Keputusan:**
  1. `UI_Quiz.tscn` diset `process_mode = 3` (ALWAYS) dengan layer 100 di atas scene gameplay.
  2. Semua konstanta gameplay kuis dipusatkan di `Config.gd` (`QUIZ_EXP_FIRST_TRY`, `QUIZ_BW_FIRST_TRY`, `QUIZ_EXP_RETRY`, `QUIZ_BW_RETRY`, `QUIZ_STREAK_TARGET`, `QUIZ_STREAK_BONUS_EXP`, `QUIZ_DAMAGE_WRONG`, `QUIZ_BUTTON_MIN_HEIGHT`).
  3. Method `start(questions: Variant, layer_id: String = "")` fleksibel menerima `QuizQuestion`, `Array[QuizQuestion]`, atau `Dictionary`.
  4. Bila jawaban salah: `GameState.take_damage(1)`, penjelasan materi ditampilkan di area umpan balik, streak 3x direset ke 0, opsi diacak ulang (`shuffle()`), dan tombol diaktifkan kembali agar pemain dapat mencoba lagi.
  5. Bila jawaban benar: diberikan hadiah sesuai status (pertama vs setelah salah), tombol yang benar disorot hijau, tombol opsi dinonaktifkan, dan tombol lanjut ditampilkan.
  6. Tombol petunjuk mengonsumsi 1 `hint_charges` dan menyembunyikan 1 opsi salah secara acak.
  7. Panel debug (`DebugPanel`) dilengkapi tombol "Uji Quiz L7" dan "+Hint (+1)" untuk memudahkan pengujian manual via shortcut F3.

## D-04: Implementasi Gerbang Kuis (QuizGate)
- **Konteks:** Spesifikasi meminta QuizGate.tscn (Area2D) dengan @export layer_id. Saat dimasuki pemain: pause game, buka UI_Quiz. Setelah benar: buka gerbang (animasi, collision hilang), GameState.gates_cleared[layer_id] = true, pancarkan gate_cleared, aktifkan checkpoint. Gerbang tetap terbuka setelah load save. Jika Integrity 0 saat kuis: respawn dan kuis diulang, EXP yang sudah tercatat tetap diberikan.
- **Keputusan:**
  1. `scenes/pickups/QuizGate.tscn` dikonfigurasi di Physics Layer 6 (Trigger) dengan Mask 2 (Player) dan script `scripts/QuizGate.gd`.
  2. Saat kuis selesai dengan status benar (`passed == true`):
     - `GameState.gates_cleared[layer_id] = true`.
     - Memancarkan `gate_cleared(layer_id)` baik di level instance `QuizGate` maupun global `GameState.gate_cleared`.
     - Posisi gerbang disimpan ke `GameState.checkpoint` dan `GameState.save_game()` dipanggil otomatis.
     - Suara `gate_open.ogg` dimainkan, sprite tertutup memudar lewat tween, dan `collision_shape` dinonaktifkan dengan `set_deferred`.
  3. Saat Integrity 0 saat kuis:
     - `UI_Quiz` menutup diri saat menerima `player_died`.
     - `QuizGate` menerima `passed == false` sehingga gerbang tetap tertutup.
     - Sistem respawn bawaan memulihkan pemain di checkpoint dengan Integrity penuh tanpa mereset `exp_points` dan `bandwidth`.
     - Kuis akan diulang secara otomatis saat pemain kembali menyentuh gerbang.
  4. Persistensi: Gerbang memeriksa `GameState.gates_cleared.has(layer_id)` pada `_ready()` dan `reset()`. Jika sudah terbuka, gerbang langsung berada dalam status terbuka tanpa memainkan animasi/suara ulang.

## D-05: Penambahan Tipe Soal Match dan Order pada UI_Quiz
- **Konteks:** Spesifikasi meminta penambahan dua tipe soal ke UI_Quiz: match (dua kolom, pilih kiri lalu kanan, salah = damage 1 & pasangan reset) dan order (daftar item diketuk berurutan, salah = damage 1 & reset), serta pembuatan 1 contoh tiap tipe dari docs/quiz_bank.md (4.4 dan B.3).
- **Keputusan:**
  1. `UI_Quiz.tscn` diperluas dengan node `MatchContainer` (dua kolom tombol berukuran tinggi min 56px) dan `OrderContainer` (tombol item urutan berukuran tinggi min 56px).
  2. Logika `UI_Quiz.gd` menyesuaikan antarmuka sesuai properti `type` dari `QuizQuestion`:
     - Tipe `match`: Pemain memilih item kiri (highlight cyan), lalu memilih item kanan. Jika cocok, kedua tombol berubah hijau dan nonaktif. Jika salah, dipanggil `take_damage(1)`, seluruh pasangan yang sudah terbentuk di-reset, dan kolom kanan diacak ulang.
     - Tipe `order`: Item urutan diacak posisinya. Pemain mengetuk sesuai urutan tahap enkapsulasi. Jika benar, tombol diberi label nomor urutan `[1]`, `[2]`, dst. dan berubah hijau. Jika salah, dipanggil `take_damage(1)` dan urutan di-reset ke tahap awal dengan posisi tombol diacak ulang.
  3. Mengimplementasikan dukungan petunjuk (`hint`) untuk semua tipe: pada `match` otomatis memasangkan 1 pasangan belum terjodohkan, pada `order` otomatis mengetuk 1 langkah berikutnya.
  4. Dua soal contoh dibuat: `res://resources/questions/l4_match_01.tres` (B.3: protokol ke port) dan `res://resources/questions/l1_order_01.tres` (4.4: urutan enkapsulasi).
  5. Ditambahkan tombol `Uji Match L4` dan `Uji Order L1` pada `DebugPanel` (F3) untuk pengujian manual.

## D-06: Implementasi Toko Data Terminal Checkpoint
- **Konteks:** Spesifikasi meminta Resource ItemData (id, nama, harga, deskripsi, batas) dan 6 file .tres sesuai tabel brief, UI_Shop.tscn (daftar item, saldo Bandwidth, tombol Beli dengan konfirmasi), terminal Checkpoint membuka Shop saat pemain menekan interact di dekatnya, penerapan efek ke GameState sesuai batas (Shield maks 1, Integrity maks 6, skill sekali beli), dan autosave setelah beli.
- **Keputusan:**
  1. `resources/ItemData.gd` dibuat mewarisi `Resource` dengan atribut static typing.
  2. Enam file `.tres` disimpan di `resources/items/` dengan harga sesuai `Config.gd`: `item_shield.tres` (40 BW), `item_integrity.tres` (60 BW), `item_hint.tres` (25 BW), `item_double_jump.tres` (100 BW), `item_dash.tres` (90 BW), dan `item_magnet.tres` (80 BW).
  3. Validasi batas dan penerapan efek disentralisasi di `GameState.can_buy_item(id)` dan `GameState.apply_item_effect(id)`:
     - Shield: hanya bisa dibeli jika belum aktif (`not shield`).
     - Integrity: hanya bisa dibeli jika `max_integrity < 6` (menambah kapasitas maks 1 dan memulihkan 1 HP).
     - Skill Dash & Double Jump: sekali beli (`not has_dash`, `not has_double_jump`).
     - Magnet Koin: sekali beli (`magnet_radius < 160.0`).
     - Petunjuk Kuis: menambah `hint_charges`.
  4. Setiap pembelian otomatis memotong saldo Bandwidth, menerapkan efek ke GameState, memancarkan `stats_changed`, dan memanggil `GameState.save_game()` (autosave).
  5. Checkpoint (`Checkpoint.gd`) diset `is_shop = true` secara default, memunculkan prompt `[E] Buka Toko` saat pemain berada di dalam area, dan membuka `UI_Shop.tscn` saat tombol `interact` ditekan.
  6. `UI_Shop.tscn` menampilkan saldo Bandwidth aktual, grid kartu item dengan status ketersediaan, serta dialog konfirmasi ("Ya, Beli" / "Batal") sebelum memproses transaksi.

## D-07: Konversi Menyeluruh Bank Soal ke Resource .tres dan Tool Importer
- **Konteks:** Spesifikasi meminta seluruh soal di docs/quiz_bank.md diubah menjadi file .tres di resources/questions/ (nama: L7_01.tres dan seterusnya), mencocokkan field QuizQuestion tanpa mengubah kata-kata soal, serta membuat skrip editor satu kali tools/import_quiz.gd (@tool).
- **Keputusan:**
  1. `docs/quiz_bank.md` dilengkapi dengan seluruh materi soal 7 layer Model OSI plus tipe Match dan Order (total 19 soal).
  2. Seluruh 19 soal diekspor menjadi file `.tres` di `res://resources/questions/`:
     - Layer 7: `L7_01.tres`, `L7_02.tres`, `L7_03.tres`
     - Layer 6: `L6_01.tres`, `L6_02.tres`, `L6_03.tres`
     - Layer 5: `L5_01.tres`, `L5_02.tres`
     - Layer 4: `L4_01.tres`, `L4_02.tres`, `L4_03.tres`, `L4_MATCH_01.tres`
     - Layer 3: `L3_01.tres`, `L3_02.tres`
     - Layer 2: `L2_01.tres`, `L2_02.tres`
     - Layer 1: `L1_01.tres`, `L1_02.tres`, `L1_ORDER_01.tres`
  3. Dibuat tool editor `tools/import_quiz.gd` (`@tool extends EditorScript`) yang memindai markdown dan menyusun resource `QuizQuestion` secara otomatis jika ada penambahan soal baru di masa depan.

## D-08: Penyusunan Startup Plaza dan Komponen Tutorial
- **Konteks:** Spesifikasi meminta melengkapi Startup Plaza: papan petunjuk (Area2D dengan Label) untuk gerak, lompat, dan interaksi; 8 koin; 1 Spam Drone aman untuk latihan injak; Checkpoint pertama; Terminal berdialog singkat (kotak dialog UI sederhana yang ditutup dengan interact); dan Badge HUD menampilkan "Startup Plaza".
- **Keputusan:**
  1. `scenes/props/Signboard.tscn` dan `scripts/Signboard.gd` dibuat sebagai `Area2D` di Physics Layer 6 (Trigger, mask 2 Player) dengan panel info yang muncul saat didekati pemain. Ditempatkan 3 papan di sepanjang Startup Plaza: Gerak (`[A]/[D]`), Lompat (`[SPASI]`), dan Interaksi (`[E]`).
  2. `scenes/props/TerminalDialog.tscn` dan `scripts/TerminalDialog.gd` dibuat bersama `scenes/ui/UI_DialogBox.tscn`. Saat pemain mendekat dan menekan tombol `interact`, game dipause dan kotak dialog muncul berisi pesan panduan awal admin. Kotak dialog dapat ditutup dengan menekan `interact` kembali.
  3. Checkpoint pertama (`CP0`, `checkpoint_id = 0`) diposisikan di dalam Startup Plaza (X=760, Y=580) sebagai titik simpan awal dan akses toko.
  4. 8 koin (`PlazaCoin1` s.d. `PlazaCoin8`) ditata melintasi lantai Startup Plaza dari X=300 hingga X=1200.
  5. 1 `SpamDrone` aman (`SpamDrone_Plaza`) ditempatkan di X=1100, Y=560 dengan kecepatan rendah (50) dan jarak patroli pendek (70) untuk latihan injak (`stomp`).
  6. Inisialisasi `Level_1.gd` memanggil `$UI_HUD.set_section("Startup Plaza", "Startup Plaza")` agar badge di HUD menampilkan teks "Startup Plaza".

## D-09: Sistem Item Bawaan (CarryItem) dan Penerima Slot (CarrySlot)
- **Konteks:** Spesifikasi meminta sistem item yang dibawa (`scripts/carry/CarryItem.gd` dan `scripts/carry/CarrySlot.gd`). Pemain membawa maks 1 item melayang di atas kepala. Interact di dekat item untuk mengambil, interact di dekat slot untuk meletakkan. Slot menerima item cocok (sinyal accepted) dan menolak yang salah (item kembali ke posisi asal, tampil pesan singkat, tanpa damage). Item kembali ke asal saat pemain respawn. Diuji di TestLevel, belum di Level_1.
- **Keputusan:**
  1. `scripts/carry/CarryItem.gd` dan `scenes/carry/CarryItem.tscn` dibuat sebagai `Area2D` di Physics Layer 6 (Trigger, mask 2 Player) dengan export `item_id`, `label_text`, `warna`, dan `item_texture`. Menyimpan posisi awal `_spawn_position`, terdaftar di grup `resettable`, dan mendengarkan `GameState.player_died`.
  2. Saat dibawa (`is_carried`), posisi item melayang di atas kepala pemain (`Config.CARRY_ITEM_OFFSET_Y = -42.0`). Properti `player.carried_item` memegang referensi item yang sedang dibawa, memastikan pemain hanya bisa membawa maksimal 1 item.
  3. `scripts/carry/CarrySlot.gd` dan `scenes/carry/CarrySlot.tscn` dibuat sebagai `Area2D` di Physics Layer 6 dengan export `accepts_id`, `slot_label`, dan `slot_warna`. Memancarkan sinyal `accepted(item_id)` bila item yang dimasukkan cocok, mengunci item di slot (`lock_in_slot()`), dan menampilkan umpan balik hijau.
  4. Jika item yang dimasukkan ke slot salah: slot menampilkan pesan umpan balik merah ("Item Tidak Cocok! Kembali ke asal."), memanggil `return_to_spawn()` pada item, melepaskan pegangan pemain, dan tidak memberikan damage apa pun ke pemain.
  5. Pada `Player.gd`, `carried_item` diintegrasikan pada `_on_player_died()` dan `_respawn()` untuk memastikan item kembali ke titik asalnya saat pemain mati atau respawn.
  6. Dua item uji (`CarryItem_HTTP` dan `CarryItem_DNS`) serta satu slot uji (`CarrySlot_Web` yang menerima `"http"`) dipasang di `TestLevel.tscn` untuk pengujian interaksi bawa-dan-letakkan.

## D-10: Pembangunan HTTP Boulevard, Slot Gedung, dan Aktivasi Gerbang L7
- **Konteks:** Spesifikasi meminta pembangunan area HTTP Boulevard (Level 1, Seksi 2) sesuai LEVEL_DESIGN 4.1: platform gedung, 3 slot gedung (WEB, MAIL, DNS) dengan gelembung permintaan, 3 lencana protokol (HTTP, SMTP, DNS) tersebar di rute berbeda, musuh Pop-Up Turret dan Spam Drone menjaga rute, Terminal L7 yang aktif setelah 3 slot terisi benar dan membuka QuizGate L7, Artefak #1 di atap tertinggi, 5 koin, 1 Energy Cell, dan Checkpoint sebelum gerbang.
- **Keputusan:**
  1. `CarrySlot.gd` diperluas dengan dukungan gelembung permintaan (`request_bubble_text`) dan pesan spesifik alasan penolakan (`reject_message`). Gedung WEB SERVER meminta *"Minta halaman web"* (HTTP), MAIL SERVER meminta *"Kirim email"* (SMTP), dan DNS SERVER meminta *"Cari alamat www.contoh.com"* (DNS).
  2. Tiga lencana protokol disebar di rute berbeda: HTTP di gang awal (X=1650), SMTP di atap substation (X=2080), dan DNS di ceruk belakang Pop-Up Turret (X=2600).
  3. Jalur dijaga oleh `PopUpTurret_Boulevard` (X=2520) serta dua unit `SpamDrone` patroli udara (X=1980 dan X=2450).
  4. Komponen `TerminalL7.gd` memantau sinyal `accepted` dari ketiga slot gedung. Gerbang `GateL7` dikunci awal (`locked = true`). Ketika ketiga slot lengkap, Terminal L7 aktif (ONLINE) dan membuka `GateL7` (`unlock_gate()`) untuk memungkinkan verifikasi kuis L7.
  5. Checkpoint 1 (`CP1`) diposisikan persis sebelum gerbang dan Terminal L7 di X=2780.
  6. Artefak #1 diletakkan di atap tertinggi (Skyway, X=2250, Y=115), 1 Energy Cell di platform tengah (X=2060, Y=385), dan 5 koin disebar di sepanjang jalur.

## D-11: Pembangunan Encoding Alley, Pemrosesan Token Data, dan Pembukaan QuizGate L6
- **Konteks:** Spesifikasi meminta pembangunan area Encoding Alley (Level 1, Seksi 3) sesuai LEVEL_DESIGN 4.1: Token Data mentah (`TokenData.gd`), Stasiun Kompresi dan Enkripsi (`DataStation.gd`), urutan olah data (Kompresi lalu Enkripsi; jika Enkripsi dulu label berubah *"Terenkripsi, sulit dikompres"* dan harus diulang), gerbang keluar (slot) hanya menerima token *"Terkompres + Terenkripsi"*, Data Corruption Pool, dua platform bergerak (`MovingPlatform.gd`), 1 Booster, Artefak #2 di balik mesin, serta pembukaan QuizGate L6 setelah slot terisi.
- **Keputusan:**
  1. `TokenData.gd` dan `TokenData.tscn` dibuat mewarisi `CarryItem.gd` dengan mesin status data: `RAW` (*"Data Mentah"*), `COMPRESSED` (*"Terkompres"*), `READY` (*"Terkompres + Terenkripsi"*), dan `INVALID` (*"Terenkripsi, sulit dikompres"*). Saat dikembalikan ke asal atau reset, otomatis kembali ke `RAW`.
  2. `DataStation.gd` dan `DataStation.tscn` (`Area2D` di Physics Layer 6) mendeteksi token yang dibawa pemain:
     - Stasiun Kompresi memproses `RAW` menjadi `COMPRESSED`. Menolak jika token sudah `INVALID`.
     - Stasiun Enkripsi memproses `COMPRESSED` menjadi `READY` (sukses). Jika dimasuki token `RAW`, status berubah menjadi `INVALID` (salah urutan).
  3. Platforming dan Rintangan:
     - `MovingPlatform.gd` dan `MovingPlatform.tscn` (`AnimatableBody2D`) dipasang 2 unit (X=3920 dan X=4180) untuk menyeberangi cekungan bahaya.
     - `DataCorruptionPool_Alley` dipasang di dasar cekungan (X=4050).
     - 1 Booster dipasang di tengah gang (X=4380).
     - Artefak #2 (`artifact_L6`, Sertifikat Enkripsi) dipasang di balik stasiun enkripsi (X=4750).
  4. Slot keluar `Slot_Exit_L6` (X=4920) hanya menerima `"DATA_READY"`. Jika token belum siap atau invalid, ditolak dan token dipulangkan ke spawn.
  5. Saat `Slot_Exit_L6` terisi benar, `GateL6` (X=5040) di-unlock (`unlock_gate()`) sehingga pemain dapat masuk dan membuka kuis L6 (Presentasi).

## D-12: Pembangunan Session Tower, Timer Sesi HUD, dan Pembukaan QuizGate L5
- **Konteks:** Spesifikasi meminta pembangunan area Session Tower (Level 1, Seksi 4) sesuai LEVEL_DESIGN 4.1: saklar di dasar membuka sesi dengan timer 60 detik (tampil di HUD), token keep-alive (+10 detik) di sepanjang jalur, tuas "Tutup Sesi" di puncak harus ditarik sebelum timer habis (timeout -> sesi reset dan pemain kembali ke dasar tanpa kehilangan Integrity), 2 Energy Cell, musuh patroli, Artefak #3 di puncak, serta pembukaan QuizGate L5 setelah tuas ditarik.
- **Keputusan:**
  1. `SessionTowerManager.gd` mengelola siklus hidup sesi: `start_session()` menyalakan timer 60 detik (`Config.SESSION_TOWER_DURATION`), `add_time()` menambah waktu +10 detik per token, `close_session()` mengakhiri sesi dengan sukses dan membuka `GateL5`, serta `_on_timeout()` mengembalikan pemain ke dasar (X=5500, Y=580) tanpa damage Integrity serta me-reset seluruh token keep-alive.
  2. `UI_HUD.gd` dan `UI_HUD.tscn` dilengkapi fungsi `set_session_timer(time_left, visible)` dan label `LblTimer` di bagian tengah atas layar.
  3. Dibuat `KeepAliveToken.gd` dan `KeepAliveToken.tscn` (Area2D Trigger 32) terdaftar di grup `"keep_alive_token"` dan `"resettable"`, dipasang 3 unit di jalur panjat (X=5680, X=6000, X=6250).
  4. Dibuat `SessionLever.gd` dan `SessionLever.tscn` untuk saklar buka sesi di dasar (X=5500) dan tuas tutup sesi di puncak (X=6380, Y=250).
  5. Ditempatkan 2 Energy Cell (X=5880 dan X=6180), musuh patroli udara `SpamDrone_Tower` (X=6050), dan Artefak #3 (`artifact_L5`, Token Sesi) di puncak (X=6440, Y=230).
  6. `GateL5` (`QuizGate.tscn`) dipasang di X=7050 dengan status awal `locked = true`, yang otomatis di-unlock saat tuas puncak ditarik.

## D-13: Pembangunan Exit Gateway, Dialog Ringkasan, Toko, Kunci Port #1, dan UI_LevelComplete
- **Konteks:** Spesifikasi meminta pembangunan area Exit Gateway (Level 1, Seksi 5) sesuai LEVEL_DESIGN 4.1: dialog ringkasan (mengonfirmasi urutan L7 → L5 telah terbuka), Toko (Checkpoint dengan fitur shop), Kunci Port #1 di balik gedung DNS lewat jalur samping, Portal keluar menuju level berikutnya, UI_LevelComplete (ringkasan EXP, Bandwidth, Artefak x/3, dan Integritas), serta transisi fade layar via SceneTransition. Level berikutnya (Level 2) sementara tetap kosong/placeholder.
- **Keputusan:**
  1. SummaryTerminal.tscn (Area2D Trigger 32) diletakkan di X=7250, menampilkan dialog ringkasan keberhasilan pemulihan Lapisan Aplikasi (L7), Presentasi (L6), dan Sesi (L5), dengan prompt interaksi [E] BACA RINGKASAN.
  2. Toko ditempatkan di X=7450 menggunakan scene Checkpoint.tscn (CP3) dengan konfigurasi is_shop = true, memungkinkan pemain berbelanja item/upgrade sebelum memasuki portal.
  3. Kunci Port #1 (KeyPort1, Pickup jenis PORT_KEY / enum 5, item_id = "key_port_1") diletakkan di platform samping di balik gedung DNS / Gate L7 (Plat_DNS_Side di X=2960, Y=480), diakses melalui pijakan bertahap Plat_DNS_Step (X=2850, Y=550) atau drop dari skyway atas (Plat_Skyway_Substation_Right).
  4. Layar ringkasan akhir level UI_LevelComplete.tscn dan UI_LevelComplete.gd (CanvasLayer layer 110, process_mode = PROCESS_MODE_ALWAYS) menampilkan:
     - Total EXP yang diperoleh (GameState.exp_points).
     - Sisa Bandwidth (GameState.bandwidth).
     - Jumlah Artefak Level 1 terkumpul (mini(count, 3) / 3).
     - Integritas paket saat ini (GameState.integrity / GameState.max_integrity).
     - Tombol aksi "LANJUTKAN KE LEVEL 2 ▶" dan shortcut input Enter / Interact yang memicu pergantian scene ke res://scenes/Level_2.tscn dengan efek pudar fade SceneTransition.change_scene(..., 0.5).
  5. Di Level_1.gd, saat pemain menyentuh PortalExit, UI_LevelComplete diinstansiasi ke dalam scene dan permainan di-pause, menghentikan perpindahan langsung tanpa ringkasan.

## D-14: Penataan Koleksi Level 1 (Eliminasi Duplikasi Artefak L6 & Relokasi Booster ke Session Tower)
- **Konteks:** Hasil audit playtest Level 1 (docs/PLAYTEST_L1.md) mengidentifikasi dua ketidaksesuaian kecil terhadap dokumen acuan LEVEL_DESIGN 4.1 & 4.5:
  1. Terdapat node sisa template awal `Artifact2` di X=6550 yang menduplikasi ID `artifact_L6`.
  2. Distribusi booster tidak mencakup Session Tower meskipun LEVEL_DESIGN 4.5 mensyaratkan 1 Booster di Session Tower.
- **Keputusan:**
  1. Menghapus node lama duplikat `Pickups/Artifact2` di X=6550 dari `Level_1.tscn`. Dengan ini, Artefak #2 (Sertifikat Enkripsi) eksklusif berada di `Artifact2_Alley` (X=4750, Y=575) di balik Stasiun Enkripsi.
  2. Mengganti `Booster1` dari Plaza menjadi `Booster_Tower` di dasar panjat Session Tower (X=5580, Y=575, `jenis = 3`), memberikan buff lari/lompat saat memulai sesi bertimer 60 detik. Distribusi 4 booster kini 100% sesuai LEVEL_DESIGN 4.5 (Encoding Alley x2, Session Tower x1, Exit Gateway x1).

## D-15: Perbaikan Infinite Recursion (Stack Overflow) dan Pembersihan Warning Godot
- **Konteks:** Pemain melaporkan crash fatal: `Stack overflow (stack size: 1024). Check for infinite recursion in your script` serta 15+ pesan peringatan (shadowed method di `UI_HUD.gd`, integer division, dan invalid UID pada `ext_resource`).
- **Keputusan:**
  1. Ditemukan infinite recursion loop pada `scripts/enemies/enemy.gd` di mana setter `jarak` memanggil `patrol_distance = val` dan setter `patrol_distance` memanggil `jarak = val` bolak-balik tanpa henti. Diperbaiki dengan guard conditional: `if patrol_distance != val` dan `if jarak != val`.
  2. Setter `id` dan `item_id` pada `scripts/Pickup.gd` juga diamankan dengan guard `!= val` agar kebal terhadap rekursi.
  3. Pada `scenes/ui/UI_HUD.gd`, parameter fungsi `set_session_timer` diubah dari `show` menjadi `is_visible` (menghilangkan bentrok dengan `CanvasLayer.show()`), dan `int(time_left) / 60` diubah menjadi `int(time_left / 60.0)` (menghilangkan warning integer division).
  4. Seluruh atribut `uid="..."` sintetis/tidak valid pada tag `[ext_resource]` di 18 file `.tscn` telah dibersihkan sehingga Godot 4 langsung memuat scene dan tekstur melalui `path="..."` dengan bersih tanpa warning fallback.

## D-16: Perbaikan Type Mismatch Checkpoint dan Duplikasi Animasi SpriteFrames
- **Konteks:** Eksekusi runtime memunculkan 2 error lanjutan:
  1. `SCRIPT ERROR: Trying to assign value of type 'ColorRect' to a variable of type 'Node2D'` pada `Checkpoint.gd:14`.
  2. `ERROR: SpriteFrames already has animation 'default'` pada `Pickup.gd:118`.
- **Keputusan:**
  1. Pada `scripts/Checkpoint.gd`, tipe `@onready var status_light` diubah dari `Node2D` menjadi `CanvasItem` agar kompatibel dengan node `ColorRect` di `Checkpoint.tscn`.
  2. Pada `scripts/Pickup.gd`, pembuatan `SpriteFrames` baru mengecek keberadaan animasi `"default"` dan memanggil `clear("default")` alih-alih `add_animation("default")`.

## D-17: Penyesuaian Tinggi Lompatan, Pengaktifan Bawaan Dash & Double Jump, serta Ekstensi Keybinding
- **Konteks:** Pemain meminta penyesuaian kontrol pergerakan: lompatan sedikit lebih tinggi, Dash langsung dapat digunakan, serta kelancaran kontrol lainnya.
- **Keputusan:**
  1. Kecepatan lompat `JUMP_V` pada `autoload/Config.gd` dinaikkan dari `-420.0` ke `-480.0` (tinggi lompat naik dari 73.5 px ke ~96 px), `DOUBLE_JUMP_V` dinaikkan dari `-360.0` ke `-420.0`, dan `ENEMY_STOMP_BOUNCE` dinaikkan dari `-280.0` ke `-340.0`. Waktu toleransi coyote time dan jump buffer ditingkatkan menjadi 0.14 detik agar kontrol terasa lebih presisi dan responsif.
  2. Status kemampuan `has_dash` dan `has_double_jump` pada `autoload/GameState.gd` diaktifkan secara bawaan (`true`), sehingga pemain dapat langsung menggunakan Dash dan Double Jump tanpa harus membeli di toko terlebih dahulu.
  3. Kecepatan Dash `DASH_SPEED` ditingkatkan ke `580.0` (dari `520.0`), cooldown dipercepat menjadi `0.5` detik (dari `0.8` detik), dan ditambahkan feedback audio `laser_active.ogg` saat dash dieksekusi.
  4. Input action `dash` di `project.godot` diperluas dengan menambahkan alternatif tombol `C` dan `J` (selain `Shift`), serta input `interact` ditambahkan tombol `F` (selain `E` dan `Enter`).

## D-18: Perbaikan Trigger Mengurangi Nyawa (Physics Layer Bitmask) dan Mekanik Stomp Musuh
- **Konteks:** Pemain melaporkan bahwa menyentuh checkpoint/toko/gerbang/koin mengurangi Integrity (nyawa) Hero, serta menginjak musuh terkadang tetap melukai pemain meskipun musuh mati.
- **Keputusan:**
  1. Akar masalah pemicuan damage saat menyentuh trigger/checkpoint: `collision_layer` pada `CP1`, `CP2`, `GateL7`, `GateL6`, dan `PortalExit` sebelumnya bernilai desimal `6` (bit 2 + bit 3 = Player + Enemy), serta koin/pickup bernilai `5` (bit 1 + bit 3 = World + Enemy). Akibatnya, `Player.hurtbox` (yang memantau Layer 3 Enemy) mendeteksi objek-objek tersebut sebagai musuh dan memanggil `take_hit()`. Seluruh layer telah diperbaiki menjadi bitmask murni: `collision_layer = 32` (Layer 6 Trigger) dan `collision_layer = 16` (Layer 5 Pickup).
  2. Pada `Player.gd`, `_on_hurtbox_area_entered` dan `_on_hurtbox_body_entered` diperketat untuk mengabaikan grup `pickup`, `coin`, `trigger`, `checkpoint`, `gate`, dan `portal`.
  3. Memperbaiki mekanik injak musuh (*stomp*):
     - Di `Player.gd`, kontak dengan musuh saat Hero sedang jatuh (`velocity.y > 0.0`) dan posisinya di atas musuh tidak lagi menghasilkan damage. Ditambahkan fungsi `apply_stomp_iframe(0.35)`.
     - Di `scripts/enemies/enemy.gd`, fungsi `_stomp(body)` langsung mematikan monitoring dan collision hitbox musuh seketika serta memberikan i-frame ke pemain sebelum musuh meledak/mati.
     - Di `scenes/enemies/EnemyBase.tscn`, area deteksi injak `StompArea` diperluas dan dinaikkan ($Y = -14$, tinggi 12) serta `Hitbox` diturunkan ($Y = +6$) sehingga kontak dari atas selalu memicu injak terlebih dahulu.

## D-19: Harmonisasi Stomp untuk Seluruh Jenis Musuh (EnemyChaser & EnemyBase)
- **Konteks:** Pemain menemukan bahwa monster jenis tertentu (SparkBug, NoiseBat, LostRouter, SpamBot) saat diinjak tetap mengurangi HP pemain meskipun monsternya mati.
- **Penyebab:** Monster-monster tersebut menggunakan skrip terpisah EnemyChaser.gd (bukan EnemyBase), di mana saat stomp terjadi, hitbox musuh belum langsung dimatikan (menunggu tween 0.18 detik), pemain belum diberi apply_stomp_iframe(0.35), dan kecepatan jatuh pemain yang langsung dibalik ke negatif membuat pemeriksaan velocity.y > 0.0 di hurtbox pemain gagal, sehingga pemain terkena damage.
- **Keputusan:**
  1. Pada EnemyChaser.gd, deteksi stomp diperlebar (player.velocity.y >= 0.0 and player.y < enemy.y), langsung panggil player_node.apply_stomp_iframe(0.35), dan seketika nonaktifkan monitoring & monitorable pada hitbox musuh sebelum efek mati dijalankan.
  2. Pada Player.gd, _on_hurtbox_area_entered dan _on_hurtbox_body_entered mengecek is_invulnerable dan invulnerable_t > 0.0 sehingga frame stomp sepenuhnya kebal dari kontak sekunder musuh.
  3. Pada enemy.gd, toleransi deteksi stomp diperluas untuk memastikan semua musuh berbasis EnemyBase juga konsisten.
