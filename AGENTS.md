KONTEKS
- Proyek: Packet Hero, platformer 2D edukasi tampak samping tentang Model OSI.
- Engine: Godot 4.3+, bahasa GDScript, renderer Compatibility, target export HTML5 (desktop dan mobile).
- Dokumen acuan: docs/PROJECT_BRIEF.md, docs/ASSET_MAP.md, docs/LEVEL_DESIGN.md, docs/quiz_bank.md.

ATURAN KERJA
1. Kerjakan HANYA prompt yang sedang aktif. Jangan membuat fitur untuk langkah berikutnya dan jangan refactor besar tanpa diminta.
2. Sebelum mengubah file, tulis rencana singkat: file yang akan dibuat atau diubah.
3. Setelah selesai, laporkan: (a) daftar file, (b) cara menguji, (c) hal yang sengaja belum dikerjakan. Lalu BERHENTI dan tunggu perintah.
4. Setelah selesai, tambahkan satu baris di docs/PROGRESS.md: ID prompt, file utama, status uji.
5. Semua angka gameplay (kecepatan, harga, durasi, EXP) disimpan di res://autoload/Config.gd, jangan disebar sebagai angka ajaib.
6. Pakai GDScript bertipe (static typing). File snake_case, scene PascalCase. Komunikasi antar node memakai signal, hindari path get_node yang panjang.
7. Jika aset belum ada, pakai placeholder (ColorRect, Polygon2D, atau icon.svg) dan buat jalur aset mudah diganti lewat variabel @export. Jangan menyentuh isi folder assets/ kecuali diminta.
8. Kompatibel web: tanpa thread, tanpa shader berat, pakai CPUParticles2D, hindari file besar.
9. Teks yang tampil ke pemain memakai Bahasa Indonesia.
10. Jangan menambah addon atau plugin tanpa izin.
11. Jika spesifikasi ambigu, pilih opsi paling sederhana, catat di docs/DECISIONS.md, lalu lanjut. Jangan bertanya panjang.
12. Jangan menulis "sudah diuji" bila game tidak dijalankan. Tulis "belum diuji" dan jelaskan cara uji manual.
13. Physics layer: 1 World, 2 Player, 3 Enemy, 4 Hazard, 5 Pickup, 6 Trigger. Group node: player, enemy, resettable, coin.