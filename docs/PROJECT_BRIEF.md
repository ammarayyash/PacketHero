Judul: PACKET HERO: Misi Menembus 7 Layer · Genre: platformer 2D edukasi, tampak samping · Viewport: 1280×720 · Bahasa: Indonesia

Alur: Main Menu → Level 1 Kota Aplikasi (L7, L6, L5) → Level 2 Hutan Rute (L4, L3) → Level 3 Gua Kabel (L2, L1) → Boss Bug-Lord → Rank dan ringkasan OSI.

2.1 Angka gameplay (masuk ke Config.gd)
Kelompok	Nilai
Gerak	SPEED 220 · JUMP_V −420 · DOUBLE_JUMP_V −360 · GRAVITY 1200 · COYOTE 0,12 s · JUMP_BUFFER 0,12 s
Dash	DASH_SPEED 520 · DASH_TIME 0,15 s · DASH_COOLDOWN 0,8 s · I-frame dash 0,2 s
Energy	Maks 100 · regenerasi 8/detik setelah 2 detik tidak dipakai · Dash 20 · Double Jump 15
Integrity	Awal 3, maks 6 · kedip kebal setelah terluka ±1 detik
Magnet koin	90 px (160 px setelah dibeli)
Booster	Kecepatan +20%, lompatan +10%, 8 detik, tidak menumpuk (refresh durasi)
Energy Cell	+40 Energy
Koin	+5 sampai +10 Bandwidth
2.2 Toko
Item	Harga	Efek
Shield	40	Menahan 1 hit, maks 1 aktif
Integrity +1	60	Maks nyawa +1 dan pulihkan 1 (maks 6)
Petunjuk Kuis	25	Hapus 1 opsi salah, sekali pakai
Double Jump	100	Permanen
Dash	90	Permanen
Magnet Koin	80	Radius 160 px
2.3 Kuis dan skor
Benar pertama: +150 EXP, +20 Bandwidth. Benar setelah salah: +75 EXP, +10 Bandwidth. Salah: −1 Integrity, tampil penjelasan, soal diulang dengan opsi diacak. Tiga benar pertama berturut-turut: +100 EXP.
Format soal: pilihan ganda 4 opsi, benar/salah, pasangkan (L4–L3), urutan (boss).
EXP lain: Artefak +100 · Kunci Port +50 · musuh +10 · fase boss +200 · boss selesai +500.
Skor = EXP + 300×Artefak + 100×Integrity akhir + 0,5×sisa Bandwidth. Rank: S ≥ 3500, A ≥ 2800, B ≥ 2000, C < 2000.
Aturan kematian: Integrity 0 → layar “Koneksi Terputus”, respawn di checkpoint dengan Integrity penuh. Bandwidth, EXP, koleksi, gerbang tetap tersimpan. Musuh reset, Energy Cell muncul lagi.
Musuh dikalahkan dengan diinjak (+10 EXP, jatuh koin). Sentuh samping atau bawah = −1 Integrity. Jatuh ke jurang = −1 Integrity dan pindah ke titik aman terakhir.
2.4 Input Map

move_left (A, ←) · move_right (D, →) · jump (Space, W, ↑) · dash (Shift) · interact (E, Enter) · pause (Esc) · journal (Tab)

2.5 Struktur folder
res://
  autoload/   Config.gd, GameState.gd, AudioManager.gd, SceneTransition.gd, QuizDatabase.gd
  resources/  questions/, items/
  scenes/     player/, enemies/, hazards/, pickups/, levels/, ui/, dev/
  scripts/
  assets/     sprites/, tilesets/, backgrounds/, audio/, fonts/, ui/
  docs/       PROJECT_BRIEF.md, ASSET_MAP.md, LEVEL_DESIGN.md, quiz_bank.md, PROGRESS.md, DECISIONS.md