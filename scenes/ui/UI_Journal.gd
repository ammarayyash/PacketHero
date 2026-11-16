extends CanvasLayer
# UI_Journal.gd

signal closed

@onready var layer_buttons_container : VBoxContainer = $Panel/HBox/LayerList/VBox/Scroll/ButtonsContainer
@onready var title_label             : Label         = $Panel/HBox/Detail/VBox/LayerTitle
@onready var pdu_label               : Label         = $Panel/HBox/Detail/VBox/PduLabel
@onready var status_badge            : Label         = $Panel/HBox/Detail/VBox/StatusBadge
@onready var desc_label              : RichTextLabel = $Panel/HBox/Detail/VBox/DescText
@onready var btn_close               : Button        = $Panel/HBox/Detail/VBox/BtnClose

const LAYERS_DATA := [
	{
		"id": "L1",
		"num": 1,
		"name": "Physical Layer (Lapisan Fisik)",
		"pdu": "Bits (0 & 1)",
		"devices": "Kabel UTP, Hub, Repeater, NIC Transceiver",
		"desc": "Bertanggung jawab atas transmisi sinyal biner mentah melalui media fisik (kabel tembaga, fiber optik, atau gelombang radio).\n\n[color=#38bdf8]Tantangan Game:[/color] Melompati Laser Kabel Arus Listrik dan menghindari Noise Bat.\n[color=#ffd700]Artefak Terkait:[/color] Kabel Tembaga & Transceiver Kunci.",
		"unlocked_by_default": true
	},
	{
		"id": "L2",
		"num": 2,
		"name": "Data Link Layer (Lapisan Jalur Data)",
		"pdu": "Frames",
		"devices": "Switch, Network Interface Card (NIC), Bridge",
		"desc": "Menyediakan transfer data point-to-point tanpa error menggunakan MAC Address fisik (48-bit). Melakukan enkapsulasi paket menjadi frame dan pengecekan CRC (Cyclic Redundancy Check).\n\n[color=#38bdf8]Tantangan Game:[/color] Switch Terminal interaktif dan menghadapi Musuh Spam Bot.\n[color=#ffd700]Artefak Terkait:[/color] Modul Kartu NIC & Header Frame Ethernet.",
		"unlocked_by_default": true
	},
	{
		"id": "L3",
		"num": 3,
		"name": "Network Layer (Lapisan Jaringan)",
		"pdu": "Packets",
		"devices": "Router, Layer 3 Switch",
		"desc": "Mengatur pengalamatan logis (IP Address) dan menentukan jalur terbaik (routing) untuk memindahkan paket data antar subnet atau internet yang berbeda.\n\n[color=#38bdf8]Tantangan Game:[/color] Rute bercabang IP Hop dan Lost Router.\n[color=#ffd700]Artefak Terkait:[/color] Router Core & Header IPv4 Packet.",
		"unlocked_by_default": false
	},
	{
		"id": "L4",
		"num": 4,
		"name": "Transport Layer (Lapisan Transport)",
		"pdu": "Segments (TCP) / Datagrams (UDP)",
		"devices": "Gateway, Port Firewall",
		"desc": "Mengatur transfer data end-to-end antar host. Membedakan transmisi andal berurutan (TCP 3-way handshake) vs transmisi cepat tanpa garansi (UDP), serta pemetaan Port Number (80, 443, 22).\n\n[color=#38bdf8]Tantangan Game:[/color] Jalur Transport Fork (TCP aman vs UDP bahaya).\n[color=#ffd700]Artefak Terkait:[/color] Token Kunci Port 80 & 443.",
		"unlocked_by_default": false
	},
	{
		"id": "L5",
		"num": 5,
		"name": "Session Layer (Lapisan Sesi)",
		"pdu": "Data",
		"devices": "OS Session Manager, NetBIOS, RPC",
		"desc": "Membuka, mengelola dialog, sinkronisasi (checkpoint), dan menutup sesi komunikasi antar aplikasi dua perangkat yang saling terhubung.\n\n[color=#38bdf8]Tantangan Game:[/color] Checkpoint Terminal pemulihan integritas.\n[color=#ffd700]Artefak Terkait:[/color] Session Token & Auth Key.",
		"unlocked_by_default": false
	},
	{
		"id": "L6",
		"num": 6,
		"name": "Presentation Layer (Lapisan Presentasi)",
		"pdu": "Data",
		"devices": "Enkripsi / Dekripsi Engine, SSL/TLS",
		"desc": "Menerjemahkan format data, kompresi file, dan enkripsi keamanan (contoh: SSL/TLS, format karakter ASCII, kompresi JPEG/MP3) agar dipahami oleh lapisan aplikasi.\n\n[color=#38bdf8]Tantangan Game:[/color] Enkripsi barrier dan dekode data sandi.\n[color=#ffd700]Artefak Terkait:[/color] TLS Certificate & Cipher Matrix.",
		"unlocked_by_default": false
	},
	{
		"id": "L7",
		"num": 7,
		"name": "Application Layer (Lapisan Aplikasi)",
		"pdu": "Data",
		"devices": "Browser Web, Email Client, DNS Client",
		"desc": "Lapisan teratas yang berinteraksi langsung dengan pengguna manusia. Menyediakan protokol layanan internet seperti HTTP/HTTPS (Web), DNS (Domain Lookup), FTP (File), dan SMTP (Email).\n\n[color=#38bdf8]Tantangan Game:[/color] Arena Boss Akhir Bug-Lord & Enkapsulasi Paket.\n[color=#ffd700]Artefak Terkait:[/color] Master Port Key & Golden HTTP Packet.",
		"unlocked_by_default": false
	}
]

var _selected_index := 0
var _buttons : Array[Button] = []

func _ready() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/journal_open.ogg")
	btn_close.pressed.connect(_on_close)
	_build_layer_list()
	_display_layer(0)

func _build_layer_list() -> void:
	# Bersihkan tombol sebelumnya jika ada
	for child in layer_buttons_container.get_children():
		child.queue_free()
	_buttons.clear()

	for i in LAYERS_DATA.size():
		var data: Dictionary = LAYERS_DATA[i]
		var is_unlocked : bool = _is_layer_unlocked(data)
		var btn : Button = Button.new()
		var status_icon : String = "🔓" if is_unlocked else "🔒"
		btn.text = "%s L%d: %s" % [status_icon, data["num"], data["name"].split(" ")[0]]
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.custom_minimum_size = Vector2(170, 38)
		btn.pressed.connect(_on_layer_selected.bind(i))
		layer_buttons_container.add_child(btn)
		_buttons.append(btn)

func _is_layer_unlocked(data: Dictionary) -> bool:
	if data["unlocked_by_default"]:
		return true
	var layer_id: String = data["id"]
	return GameState.gates_cleared.get(layer_id, false) or GameState.gates_cleared.get("all", false)

func _on_layer_selected(idx: int) -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/journal_flip.ogg")
	_display_layer(idx)

func _display_layer(idx: int) -> void:
	_selected_index = idx
	var data: Dictionary = LAYERS_DATA[idx]
	var unlocked : bool = _is_layer_unlocked(data)

	title_label.text = "LAYER %d: %s" % [data["num"], data["name"].to_upper()]
	pdu_label.text = "PDU (Satuan Data): %s | Perangkat: %s" % [data["pdu"], data["devices"]]

	if unlocked:
		status_badge.text = "[ STATUS: TERBUKA ]"
		status_badge.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4))
		desc_label.text = data["desc"]
	else:
		status_badge.text = "[ STATUS: TERKUNCI — Selesaikan Gerbang Kuis Terkait ]"
		status_badge.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
		desc_label.text = "Lapisan protokol ini belum terbuka secara penuh di memori Hero.\n\nSelesaikan Gerbang Kuis pada Level %s untuk membuka rincian arsitektur dan lore artefak protokol ini!" % data["id"]

func _on_close() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/ui_close.ogg")
	closed.emit()
	queue_free()
