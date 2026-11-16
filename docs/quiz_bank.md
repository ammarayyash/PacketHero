# Bank Soal (Quiz Bank) - Packet Hero

Dokumen referensi soal edukasi OSI Model untuk Packet Hero.

---

## Layer 7 — Application Layer (Lapisan Aplikasi)

### Soal L7_01 (MCQ)
- **ID:** `L7_01`
- **Layer:** `L7`
- **Tipe:** `mcq`
- **Pertanyaan:** Apa kepanjangan dari protokol HTTP yang bekerja pada Layer Aplikasi?
- **Opsi:**
  1. HyperText Transfer Protocol
  2. High Transfer Tech Protocol
  3. Host Text Transfer Program
  4. HyperText Transmit Program
- **Kunci Jawaban:** Indeks 0 (HyperText Transfer Protocol)
- **Penjelasan:** HTTP (HyperText Transfer Protocol) adalah protokol Layer 7 (Application) untuk transfer halaman web dan resource antar client dan web server.

### Soal L7_02 (MCQ)
- **ID:** `L7_02`
- **Layer:** `L7`
- **Tipe:** `mcq`
- **Pertanyaan:** Protokol manakah yang bertugas menerjemahkan nama domain menjadi alamat IP di Layer Aplikasi?
- **Opsi:**
  1. DNS (Domain Name System)
  2. ARP (Address Resolution Protocol)
  3. DHCP (Dynamic Host Configuration Protocol)
  4. ICMP (Internet Control Message Protocol)
- **Kunci Jawaban:** Indeks 0 (DNS (Domain Name System))
- **Penjelasan:** DNS (Domain Name System) bekerja di Layer 7 untuk menerjemahkan nama domain seperti www.contoh.com menjadi IP address agar perangkat dapat saling terhubung.

### Soal L7_03 (MCQ)
- **ID:** `L7_03`
- **Layer:** `L7`
- **Tipe:** `mcq`
- **Pertanyaan:** Port default yang digunakan oleh HTTPS untuk transfer data terenkripsi di Layer Aplikasi adalah...
- **Opsi:**
  1. 80
  2. 443
  3. 8080
  4. 21
- **Kunci Jawaban:** Indeks 1 (443)
- **Penjelasan:** HTTPS menggunakan port default 443 dengan keamanan TLS/SSL, sedangkan HTTP standar tanpa enkripsi menggunakan port 80. Port 21 adalah FTP.

---

## Layer 6 — Presentation Layer (Lapisan Presentasi)

### Soal L6_01 (MCQ)
- **ID:** `L6_01`
- **Layer:** `L6`
- **Tipe:** `mcq`
- **Pertanyaan:** Layer Presentasi bertanggung jawab untuk...
- **Opsi:**
  1. Routing paket
  2. Enkripsi dan enkoding data
  3. Pembuatan koneksi fisik
  4. Pengalamatan MAC
- **Kunci Jawaban:** Indeks 1 (Enkripsi dan enkoding data)
- **Penjelasan:** Layer 6 (Presentation) menangani format data: enkripsi, dekripsi, kompresi, dan enkoding (misal: UTF-8, SSL/TLS).

### Soal L6_02 (MCQ)
- **ID:** `L6_02`
- **Layer:** `L6`
- **Tipe:** `mcq`
- **Pertanyaan:** Format file manakah yang melibatkan Layer Presentasi?
- **Opsi:**
  1. IP Address
  2. MAC Address
  3. JPEG/PNG
  4. Port number
- **Kunci Jawaban:** Indeks 2 (JPEG/PNG)
- **Penjelasan:** Konversi format file (JPEG, PNG, MP4) adalah tanggung jawab Layer Presentasi.

### Soal L6_03 (MCQ)
- **ID:** `L6_03`
- **Layer:** `L6`
- **Tipe:** `mcq`
- **Pertanyaan:** SSL/TLS bekerja di layer...
- **Opsi:**
  1. Layer 3
  2. Layer 4
  3. Layer 6
  4. Layer 7
- **Kunci Jawaban:** Indeks 2 (Layer 6)
- **Penjelasan:** SSL/TLS (enkripsi) bekerja di Layer 6 (Presentasi), meskipun sering diimplementasikan antara Layer 4 dan 7.

---

## Layer 5 — Session Layer (Lapisan Sesi)

### Soal L5_01 (MCQ)
- **ID:** `L5_01`
- **Layer:** `L5`
- **Tipe:** `mcq`
- **Pertanyaan:** Layer Sesi (Session Layer) berfungsi untuk...
- **Opsi:**
  1. Mengirim sinyal listrik
  2. Membangun, memelihara, dan menutup sesi komunikasi
  3. Mengatur IP address
  4. Mengatur frame data
- **Kunci Jawaban:** Indeks 1 (Membangun, memelihara, dan menutup sesi komunikasi)
- **Penjelasan:** Layer 5 mengatur sesi dialog antar aplikasi: membuka, menjaga, dan menutup koneksi komunikasi.

### Soal L5_02 (MCQ)
- **ID:** `L5_02`
- **Layer:** `L5`
- **Tipe:** `mcq`
- **Pertanyaan:** Protokol yang bekerja di Layer Sesi adalah...
- **Opsi:**
  1. TCP
  2. NetBIOS
  3. IP
  4. ARP
- **Kunci Jawaban:** Indeks 1 (NetBIOS)
- **Penjelasan:** NetBIOS bekerja di Layer 5. TCP bekerja di Layer 4, IP di Layer 3, ARP di Layer 2.

---

## Layer 4 — Transport Layer (Lapisan Transpor)

### Soal L4_01 (MCQ)
- **ID:** `L4_01`
- **Layer:** `L4`
- **Tipe:** `mcq`
- **Pertanyaan:** Perbedaan utama TCP vs UDP adalah...
- **Opsi:**
  1. TCP lebih cepat dari UDP
  2. TCP menjamin pengiriman data, UDP tidak
  3. UDP memiliki error checking, TCP tidak
  4. TCP hanya untuk video streaming
- **Kunci Jawaban:** Indeks 1 (TCP menjamin pengiriman data, UDP tidak)
- **Penjelasan:** TCP (connection-oriented) menjamin pengiriman paket dengan ACK. UDP (connectionless) lebih cepat tapi tidak menjamin pengiriman.

### Soal L4_02 (MCQ)
- **ID:** `L4_02`
- **Layer:** `L4`
- **Tipe:** `mcq`
- **Pertanyaan:** Apa fungsi port number di Layer Transport?
- **Opsi:**
  1. Mengidentifikasi perangkat fisik
  2. Membedakan aplikasi yang berjalan di host yang sama
  3. Menentukan jalur routing
  4. Mengatur kecepatan transmisi
- **Kunci Jawaban:** Indeks 1 (Membedakan aplikasi yang berjalan di host yang sama)
- **Penjelasan:** Port number mengidentifikasi proses/aplikasi spesifik di suatu host, sehingga data bisa dikirim ke program yang tepat.

### Soal L4_03 (MCQ)
- **ID:** `L4_03`
- **Layer:** `L4`
- **Tipe:** `mcq`
- **Pertanyaan:** Three-way handshake TCP terdiri dari...
- **Opsi:**
  1. SYN, ACK, FIN
  2. SYN, SYN-ACK, ACK
  3. ACK, SYN, RST
  4. CONNECT, OK, DONE
- **Kunci Jawaban:** Indeks 1 (SYN, SYN-ACK, ACK)
- **Penjelasan:** Three-way handshake: (1) Client kirim SYN, (2) Server balas SYN-ACK, (3) Client kirim ACK. Koneksi terbentuk.

---

## Layer 3 — Network Layer (Lapisan Jaringan)

### Soal L3_01 (MCQ)
- **ID:** `L3_01`
- **Layer:** `L3`
- **Tipe:** `mcq`
- **Pertanyaan:** Perangkat yang bekerja di Layer Network adalah...
- **Opsi:**
  1. Switch
  2. Hub
  3. Router
  4. Repeater
- **Kunci Jawaban:** Indeks 2 (Router)
- **Penjelasan:** Router bekerja di Layer 3 (Network) dan memutuskan jalur terbaik untuk mengirim paket antar jaringan berbeda.

### Soal L3_02 (MCQ)
- **ID:** `L3_02`
- **Layer:** `L3`
- **Tipe:** `mcq`
- **Pertanyaan:** IP Address 192.168.1.1 termasuk kelas...
- **Opsi:**
  1. Kelas A
  2. Kelas B
  3. Kelas C
  4. Kelas D
- **Kunci Jawaban:** Indeks 2 (Kelas C)
- **Penjelasan:** 192.168.x.x adalah kelas C (range 192.0.0.0 - 223.255.255.255). Sering dipakai jaringan lokal.

---

## Layer 2 — Data Link Layer (Lapisan Data Link)

### Soal L2_01 (MCQ)
- **ID:** `L2_01`
- **Layer:** `L2`
- **Tipe:** `mcq`
- **Pertanyaan:** MAC Address ditemukan di layer...
- **Opsi:**
  1. Layer 1
  2. Layer 2
  3. Layer 3
  4. Layer 4
- **Kunci Jawaban:** Indeks 1 (Layer 2)
- **Penjelasan:** MAC Address adalah pengalamatan fisik di Layer 2 (Data Link). Panjangnya 48 bit dan unik per perangkat.

### Soal L2_02 (MCQ)
- **ID:** `L2_02`
- **Layer:** `L2`
- **Tipe:** `mcq`
- **Pertanyaan:** Perangkat yang bekerja di Layer Data Link adalah...
- **Opsi:**
  1. Router
  2. Hub
  3. Switch
  4. Repeater
- **Kunci Jawaban:** Indeks 2 (Switch)
- **Penjelasan:** Switch bekerja di Layer 2 menggunakan MAC table untuk meneruskan frame ke port yang tepat.

---

## Layer 1 — Physical Layer (Lapisan Fisik)

### Soal L1_01 (MCQ)
- **ID:** `L1_01`
- **Layer:** `L1`
- **Tipe:** `mcq`
- **Pertanyaan:** Layer Fisik (Physical Layer) menangani...
- **Opsi:**
  1. Enkripsi data
  2. Routing antar jaringan
  3. Transmisi bit melalui media fisik
  4. Pembentukan sesi
- **Kunci Jawaban:** Indeks 2 (Transmisi bit melalui media fisik)
- **Penjelasan:** Layer 1 menangani transmisi bit mentah melalui media fisik: kabel tembaga, fiber optik, sinyal radio, dll.

### Soal L1_02 (MCQ)
- **ID:** `L1_02`
- **Layer:** `L1`
- **Tipe:** `mcq`
- **Pertanyaan:** Perangkat di Layer Fisik adalah...
- **Opsi:**
  1. Switch
  2. Router
  3. Hub / Repeater
  4. Firewall
- **Kunci Jawaban:** Indeks 2 (Hub / Repeater)
- **Penjelasan:** Hub dan Repeater bekerja di Layer 1 — mereka hanya memperkuat/mendistribusikan sinyal tanpa memahami isi frame.

---

## Bagian B.3 — Soal Tipe Pasangkan (Match)

### Soal L4_MATCH_01 (Match)
- **ID:** `L4_MATCH_01`
- **Layer:** `L4`
- **Tipe:** `match`
- **Pertanyaan:** Pasangkan protokol aplikasi berikut dengan nomor port default yang sesuai di Layer Transport (L4):
- **Kolom Kiri (pairs_left):**
  1. HTTP
  2. HTTPS
  3. DNS
  4. SSH
- **Kolom Kanan (pairs_right):**
  1. Port 80
  2. Port 443
  3. Port 53
  4. Port 22
- **Penjelasan:** Di Layer Transport (L4), port number digunakan untuk mengarahkan segmen ke aplikasi yang tepat: HTTP (80), HTTPS (443), DNS (53), dan SSH (22).

---

## Bagian 4.4 — Soal Tipe Urutan (Order)

### Soal L1_ORDER_01 (Order)
- **ID:** `L1_ORDER_01`
- **Layer:** `L1`
- **Tipe:** `order`
- **Pertanyaan:** Ketuk unit data berikut secara berurutan sesuai proses enkapsulasi dari Layer Aplikasi (L7) hingga transmisi fisik (L1):
- **Item Urutan (order_items):**
  1. Data
  2. Segment
  3. Packet
  4. Frame
  5. Bits
- **Urutan Benar (correct_order):** [0, 1, 2, 3, 4]
- **Penjelasan:** Enkapsulasi OSI mengemas data bertahap: Data mentah di L7-L5 dibungkus menjadi Segment di L4 (Transport), lalu Packet di L3 (Network), lalu Frame di L2 (Data Link), dan akhirnya dikonversi menjadi Bits di L1 (Physical).
