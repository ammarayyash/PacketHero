4.0 Prinsip tidak monoton
Konsep OSI adalah mekanik, bukan tembok kuis. Tiap level punya satu mekanik khas yang hanya bisa diselesaikan jika pemain paham konsepnya.
Ganti jenis tantangan di setiap bagian: platforming, puzzle antar-jemput, puzzle sumber daya, kejaran, ritme, pilihan jalur.
Pilihan nyata. Ada percabangan dengan imbalan berbeda (jalur TCP vs UDP, UTP vs serat optik).
Kuis menjadi bagian misi. Gerbang kuis muncul sebagai dialog dari Terminal yang relevan dan memberi hadiah yang masuk akal.
Aman dari frustrasi. Kegagalan puzzle tidak memotong Integrity: item kembali, timer reset, atau pemain pindah ke titik terakhir.
Satu bagian ≈ 2–3 menit. Ritme: tenang → puzzle → aksi → jeda (checkpoint dan toko).
Jenis tantangan	L1	L2	L3
Platforming dasar	✔	✔	✔
Puzzle antar-jemput	HTTP Boulevard	Port Plaza	MAC Tunnel
Puzzle urutan	Encoding Alley	Handshake TCP	Perakitan Enkapsulasi
Puzzle sumber daya	Timer sesi	TTL router	Meter sinyal
Pilihan jalur	—	TCP vs UDP	UTP vs serat
Kejaran / waktu	Session Tower	Congestion Wave	Laser berirama
Pencarian rahasia	Artefak	Ping Pads	Jalur serat
4.1 Level 1 — Kota Aplikasi (L7, L6, L5) · Tema: “Antar-Jemput Layanan”

Neon cyan-kuning. Mekanik baru: membawa item, stasiun, timer. Durasi 8–10 menit.

Bagian	Isi	Gerbang
Startup Plaza	Tutorial gerak dan lompat lewat papan petunjuk. Satu koin dan satu Spam Drone aman untuk berlatih injak. Terminal pertama membuka dialog singkat: “Selamat datang, Admin.”	—
HTTP Boulevard (L7)	Misi: antar 3 permintaan. Tiga gedung (WEB SERVER, MAIL SERVER, DNS SERVER) menampilkan gelembung permintaan: “Minta halaman web”, “Kirim email”, “Cari alamat www.contoh.com”. Tiga lencana protokol (HTTP, SMTP, DNS) tersebar di atap, gang, dan balik turret. Pemain membawa lencana yang cocok ke slot gedung. Salah gedung: lencana kembali ke asalnya dan Label menjelaskan alasannya (tanpa damage). Pop-Up Turret dan Spam Drone menjaga rute. Tiga pengantaran selesai → Terminal L7 membuka kuis. Artefak #1 (Header HTTP) di atap tertinggi.	L7
Encoding Alley (L6)	Misi: olah data. Pemain mengambil Token Data mentah, membawanya melewati Stasiun Kompresi lalu Stasiun Enkripsi (urutan ini yang benar). Jika lewat Enkripsi dulu, token berlabel “Terenkripsi, sulit dikompres” dan harus diulang. Di antara stasiun ada Data Corruption Pool dan platform bergerak. Gerbang keluar hanya menerima token “Terkompres + Terenkripsi”. Artefak #2 (Sertifikat Enkripsi) di balik mesin. Booster di tengah gang.	L6
Session Tower (L5)	Misi: jaga sesi. Saklar di dasar menara membuka sesi dengan timer 60 detik. Memanjat vertikal sambil mengumpulkan token keep-alive (+10 detik tiap token) dan menghindari musuh patroli. Di puncak, tuas “Tutup Sesi” harus ditarik sebelum timer habis. Jika timeout, sesi reset ke dasar tanpa kehilangan Integrity. Energy Cell tersedia di tengah. Artefak #3 (Token Sesi) di puncak.	L5
Exit Gateway	Dialog ringkasan: urutan L7 → L5 telah terbuka. Toko. Kunci Port #1 tersembunyi di balik gedung DNS (butuh jalur samping). Portal menuju Level 2.	—
4.2 Level 2 — Hutan Rute (L4, L3) · Tema: “Perjalanan Sebuah Paket”

Hutan data hijau-cyan. HUD tambahan: panel Tujuan: 10.0.3.7 dan hitungan TTL. Mekanik baru: dua jalur (lane), TTL, kejaran. Durasi 10–12 menit.

Bagian	Isi	Gerbang
Gerbang Hutan (tutorial)	Terminal menjelaskan: “Kamu kini paket dengan alamat tujuan 10.0.3.7.” Memperkenalkan panel Tujuan, satu Packet Loss Wraith dalam area aman, dan Portal pindah jalur.	—
Transport Fork (L4)	Pilihan dua jalur, bisa berpindah lewat Portal di sepertiga dan dua pertiga jalur. Kedua jalur bertujuan sama: kumpulkan 5 segmen bernomor (Koin berlabel 1–5), lalu bertemu di gerbang.	L4
↳ Jalur TCP (depan)	Aman tetapi panjang. 3 Router Switch berlabel SYN, SYN-ACK, ACK harus ditekan berurutan untuk membentuk jembatan koneksi (salah urutan: saklar padam, tanpa damage). Segmen harus diambil berurutan 1→5; segmen keliru “dikirim ulang” ke tempat semula. Platform stabil, hanya 2 Spam Drone, 2 Energy Cell. Bonus Kelengkapan +20 EXP per segmen (maks +100). Artefak #5 (Sequence Number) di cabang atas.	
↳ Jalur UDP (belakang)	Cepat dan lebih pendek ±40%, tanpa handshake. Segmen tersebar bebas urutan. Platform packet loss: berkedip lalu menghilang 1,5 detik secara acak. 2 Packet Loss Wraith. Lolos jika ≥3 segmen terkumpul. Bonus Kecepatan +80 EXP jika selesai di bawah 60 detik. 1 Booster di tengah.	
Port Plaza (L4 lanjutan)	Misi: layanan ke port yang benar. Tiga pintu berlabel 80, 443, 53. Tiga Kristal Layanan (HTTP, HTTPS, DNS) dijaga Pop-Up Turret dan Spam Drone. Bawa tiap kristal ke pintu yang cocok. Salah pintu: kristal kembali dan Label “Port tidak cocok”. Ketiga pintu terbuka → jalan lanjut. Di balik pintu 443 ada ruang kecil berisi Artefak #4 (Nomor Port).	—
Router Grove (L3)	Misi: rute dengan TTL. TTL awal 8. Tiga router (Router Switch berlabel R1–R3) berdiri di persimpangan. Berinteraksi dengan router membuka papan routing table (UI panel) yang memetakan prefiks tujuan ke arah (Kiri, Tengah, Kanan). Tujuan 10.0.3.7 masuk prefiks 10.0.3.0/24, tiap router punya tabel berbeda sehingga harus dibaca. Setiap melewati router: TTL −1. Cabang salah berujung ke Loop Bug Zone atau jalan buntu: TTL −2. Jika TTL 0: pesan “Time Exceeded” dan pemain kembali ke router terakhir dengan TTL reset 8 (tanpa damage). Menekan ketiga router dengan benar mengaktifkan jembatan (sesuai GDD).	L3
Packet Rapids	Aksi. Congestion Wave (Data Corruption Pool panjang) mengejar dari kiri pada kecepatan 150 (pemain 220). Lintasi sungai data: conveyor “aliran data” bergantian arah, platform bergerak, Packet Loss Wraith. Booster diletakkan di awal. Artefak #6 (Alamat IP dan TTL) di jalur atas yang dapat dicapai dengan timing conveyor (Double Jump atau Booster mempermudah).	—
Exit Canopy	Ping Pads. Tiga pelat (Router Switch) di lantai: injak pelat 1, pulsa cahaya merambat lewat kabel, injak pelat 2 dalam 3 detik, lalu pelat 3. Berhasil → Chest terbuka (Kunci Port #2). Terminal Toko dan Portal ke Level 3.	—
4.3 Level 3 — Gua Kabel (L2, L1) · Tema: “Teknisi di Kegelapan”

Gua magenta-ungu gelap. CanvasModulate gelap, Hero membawa PointLight2D, kabel bercahaya menjadi penunjuk jalan. Mekanik baru: kegelapan, tabel MAC, meter sinyal, laser berirama. Durasi 12–15 menit termasuk boss.

Bagian	Isi	Gerbang
Poros Turun (intro)	Turun vertikal lewat platform jatuh dan dinding kabel. Cable Mite pertama. Memperkenalkan cahaya Hero dan aturan kegelapan. Checkpoint di dasar.	—
MAC Tunnel (L2)	Misi: switch yang belajar. Ruang pusat berisi switch dan papan Tabel MAC (awal kosong). Empat lorong (A–D), masing-masing berakhir di pintu perangkat dengan alamat MAC tersembunyi (misalnya AA:01). Pemain membawa Frame berlabel tujuan (“→ AA:03”). Saat masuk lorong, MAC-nya dipelajari dan masuk Tabel MAC. Frame pertama: tujuan belum diketahui → harus menjelajah lorong (flood), dua lorong dijaga Cable Mite. Frame kedua dan ketiga: jika tujuannya sudah ada di tabel, jalur langsung (unicast), kecuali frame ketiga sengaja menuju MAC yang belum dipelajari. Satu tuas “Broadcast” menampilkan semua label sesaat (sekali pakai). Tiga frame terantar → Terminal L2 membuka kuis. Artefak #7 (Alamat MAC) di lorong D rahasia.	L2
Jembatan Kabel	Aksi dan jeda. Menyeberang kabel menggantung dengan platform bergerak, Spark berkala, dan Spam Drone sebagai “serangga kabel”. Chest bonus dan Energy Cell. Artefak #8 (Frame Check Sequence) di bawah celah lebar (Double Jump atau Dash membantu, tetapi ada jalur panjang tanpa skill).	—
Physical Cavern (L1)	Misi: jaga sinyal. Bagian A, Meter Sinyal: pemain mengambil Sumber Sinyal (Energy Cell), lalu meter sinyal berkurang ±6 per detik saat berada di jalur UTP. Repeater (Terminal kuning) mengisi kembali meter dan menjadi checkpoint. Jarak antar-repeater ±14 detik perjalanan. Meter 0 → kembali ke repeater terakhir (tanpa damage). Alternatif Jalur Serat Optik: meter tidak berkurang tetapi rintangannya lebih sulit (Laser Kabel). Artefak #9 (Sinyal Murni) hanya ada di jalur serat. Bagian B, Ritme: 4 Laser Kabel menyala berurutan dengan irama tetap (cadence 0,8 detik) dan dua Signal Jammer memperlambat gerak. Injak Jammer dari atas untuk mematikannya. Spark sebagai gangguan.	L1
Server Core Hall	Latihan enkapsulasi. Lima pedestal tersusun vertikal berlabel L7–5, L4, L3, L2, L1. Pemain mengambil Token Header (Artefak berwarna per layer) dan memasangnya dari atas ke bawah: Data → Segment → Packet → Frame → Bits. Pemasangan benar menyalakan jalur kabel, salah mengembalikan token. Selesai → pemain mendapat Shield untuk boss dan pintu boss terbuka. Kunci Port #3 tersembunyi di sisi aula. Terminal Toko dan checkpoint terakhir.	—
Boss Arena	Bug-Lord (aturan di bagian 4.4). Checkpoint tepat sebelum arena.	Kuis final
4.4 Boss Bug-Lord

Arena melingkar dengan tiga Virus Node dan emitter Laser Kabel yang sudah ada.

Fase	Fokus	Serangan	Cara menang
1 Glitch Wave	L2	Gelombang proyektil tanah, summon Virus	Jawab kuis L2 benar → core terbuka 8 detik → sentuh core
2 Packet Storm	L1	Hujan paket, Laser Kabel, lantai retak	Jawab kuis L1 benar → hancurkan 3 Virus Node → sentuh core
3 Final Corruption	Enkapsulasi	Kombinasi serangan, lantai menghilang	Selesaikan urutan enkapsulasi benar → core terbuka → sentuh core terakhir

Aturan adil: jawaban salah −1 Integrity dan core menutup 5 detik, progres fase tidak reset. Kalah → boss kembali ke awal fase aktif. Semua serangan punya telegraf 0,6 detik. Dash tidak wajib. +200 EXP per fase, +500 EXP saat selesai.

4.5 Penempatan koleksi
Level	Artefak (3)	Kunci Port	Booster (4)	Energy Cell (5)
1	#1 atap HTTP · #2 balik mesin · #3 puncak menara	Balik gedung DNS	Encoding Alley ×2, Session Tower ×1, Exit ×1	Tersebar, dua di Session Tower
2	#4 ruang pintu 443 · #5 cabang atas TCP · #6 jalur atas Rapids	Chest Ping Pads	Awal Rapids ×2, UDP ×1, Router Grove ×1	Satu per bagian
3	#7 lorong D rahasia · #8 celah Jembatan Kabel · #9 jalur serat	Sisi Server Core Hall	Poros ×1, Jembatan ×1, Cavern ×1, Hall ×1	Satu per bagian ditambah Cavern