extends CanvasLayer
# UI_Shop.gd — Antarmuka Toko Data Terminal Checkpoint
# process_mode = ALWAYS (dapat beroperasi saat game di-pause)

signal closed

const FONT_PIXEL = preload("res://assets/fonts/cyberpunk_pixel.otf")

@onready var bandwidth_lbl      : Label          = $MainPanel/Margin/VBox/HeaderRow/BandwidthLabel
@onready var btn_close          : Button         = $MainPanel/Margin/VBox/HeaderRow/BtnClose
@onready var items_grid         : GridContainer  = $MainPanel/Margin/VBox/ScrollContainer/ItemsGrid
@onready var confirm_overlay    : ColorRect      = $ConfirmOverlay
@onready var confirm_text       : Label          = $ConfirmOverlay/ConfirmPanel/Margin/VBox/ConfirmText
@onready var btn_confirm_yes    : Button         = $ConfirmOverlay/ConfirmPanel/Margin/VBox/ButtonsRow/BtnConfirmYes
@onready var btn_confirm_cancel : Button         = $ConfirmOverlay/ConfirmPanel/Margin/VBox/ButtonsRow/BtnConfirmCancel

var _items        : Array[ItemData] = []
var _pending_item : ItemData        = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	btn_close.pressed.connect(_on_close_pressed)
	btn_confirm_yes.pressed.connect(_on_confirm_yes_pressed)
	btn_confirm_cancel.pressed.connect(_on_confirm_cancel_pressed)
	GameState.stats_changed.connect(_update_ui)

	_load_items()
	_update_ui()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			if confirm_overlay.visible:
				_on_confirm_cancel_pressed()
			else:
				_on_close_pressed()
			get_viewport().set_input_as_handled()

func _load_items() -> void:
	_items.clear()
	var item_paths: Array[String] = [
		"res://resources/items/item_shield.tres",
		"res://resources/items/item_integrity.tres",
		"res://resources/items/item_hint.tres",
		"res://resources/items/item_double_jump.tres",
		"res://resources/items/item_dash.tres",
		"res://resources/items/item_magnet.tres"
	]

	for path in item_paths:
		if ResourceLoader.exists(path):
			var res := load(path)
			if res is ItemData:
				_items.append(res)
		else:
			push_warning("UI_Shop: File item tidak ditemukan: %s" % path)

func _update_ui() -> void:
	bandwidth_lbl.text = "Saldo: %d BW" % GameState.bandwidth
	_rebuild_item_list()

func _rebuild_item_list() -> void:
	for child in items_grid.get_children():
		child.queue_free()

	for item in _items:
		var card := _create_item_card(item)
		items_grid.add_child(card)

func _create_item_card(item: ItemData) -> PanelContainer:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.custom_minimum_size = Vector2(380, 110)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.1, 0.2, 0.9)
	style.border_color = Color(0.18, 0.45, 0.75, 0.7)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_right = 6
	style.corner_radius_bottom_left = 6
	card.add_theme_stylebox_override("panel", style)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 10)
	card.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	margin.add_child(vbox)

	# Row 1: Nama & Harga
	var top_row := HBoxContainer.new()
	vbox.add_child(top_row)

	var lbl_name := Label.new()
	lbl_name.text = item.nama
	lbl_name.add_theme_font_override("font", FONT_PIXEL)
	lbl_name.add_theme_font_size_override("font_size", 16)
	lbl_name.add_theme_color_override("font_color", Color(0.25, 0.9, 1.0))
	lbl_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(lbl_name)

	var lbl_price := Label.new()
	lbl_price.text = "%d BW" % item.harga
	lbl_price.add_theme_font_override("font", FONT_PIXEL)
	lbl_price.add_theme_font_size_override("font_size", 15)
	lbl_price.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	top_row.add_child(lbl_price)

	# Row 2: Deskripsi
	var lbl_desc := Label.new()
	lbl_desc.text = item.deskripsi
	lbl_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_desc.add_theme_font_override("font", FONT_PIXEL)
	lbl_desc.add_theme_font_size_override("font_size", 12)
	lbl_desc.add_theme_color_override("font_color", Color(0.8, 0.88, 0.95))
	lbl_desc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(lbl_desc)

	# Row 3: Status & Tombol Beli
	var bottom_row := HBoxContainer.new()
	bottom_row.add_theme_constant_override("separation", 10)
	vbox.add_child(bottom_row)

	var lbl_status := Label.new()
	lbl_status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_status.add_theme_font_override("font", FONT_PIXEL)
	lbl_status.add_theme_font_size_override("font_size", 12)
	bottom_row.add_child(lbl_status)

	var can_buy: bool = GameState.can_buy_item(item.id)
	var has_enough_bw: bool = (GameState.bandwidth >= item.harga)

	var status_text: String = ""
	var status_color: Color = Color.WHITE

	if not can_buy:
		if item.id == "shield":
			status_text = "STATUS: SHIELD AKTIF"
		elif item.id == "integrity":
			status_text = "STATUS: INTEGRITY MAKSIMAL (6)"
		elif item.id in ["dash", "double_jump"]:
			status_text = "STATUS: SKILL SUDAH TERBELI"
		elif item.id == "magnet":
			status_text = "STATUS: RADIUS MAKSIMAL (160 px)"
		else:
			status_text = "STATUS: MAKSIMAL"
		status_color = Color(0.5, 0.7, 0.8)
	elif not has_enough_bw:
		status_text = "STATUS: KURANG %d BW" % (item.harga - GameState.bandwidth)
		status_color = Color(1.0, 0.4, 0.4)
	else:
		status_text = "STATUS: TERSEDIA"
		status_color = Color(0.3, 1.0, 0.5)

	lbl_status.text = status_text
	lbl_status.add_theme_color_override("font_color", status_color)

	var btn_buy := Button.new()
	btn_buy.custom_minimum_size = Vector2(100, 34)
	btn_buy.add_theme_font_override("font", FONT_PIXEL)
	btn_buy.add_theme_font_size_override("font_size", 13)
	btn_buy.text = "BELI"
	btn_buy.disabled = (not can_buy or not has_enough_bw)
	btn_buy.pressed.connect(func() -> void: _prompt_buy_confirmation(item))
	bottom_row.add_child(btn_buy)

	return card

func _prompt_buy_confirmation(item: ItemData) -> void:
	_pending_item = item
	confirm_text.text = "Beli \"%s\" seharga %d BW?\n\n%s" % [item.nama, item.harga, item.deskripsi]
	confirm_overlay.visible = true

func _on_confirm_yes_pressed() -> void:
	if _pending_item == null:
		confirm_overlay.visible = false
		return

	var item := _pending_item
	_pending_item = null
	confirm_overlay.visible = false

	if GameState.bandwidth >= item.harga and GameState.can_buy_item(item.id):
		GameState.bandwidth -= item.harga
		GameState.apply_item_effect(item.id)
		# Autosave setelah beli
		GameState.save_game()

		if AudioManager:
			AudioManager.play_sfx("res://assets/audio/sfx/checkpoint.ogg")
		print("[UI_Shop] Berhasil membeli %s (%s). Sisa BW: %d" % [item.nama, item.id, GameState.bandwidth])

	_update_ui()

func _on_confirm_cancel_pressed() -> void:
	_pending_item = null
	confirm_overlay.visible = false
	if AudioManager:
		AudioManager.play_sfx("res://assets/audio/sfx/ui_click.ogg")

func _on_close_pressed() -> void:
	if AudioManager:
		AudioManager.play_sfx("res://assets/audio/sfx/ui_click.ogg")
	closed.emit()
	if get_tree().paused:
		get_tree().paused = false
	queue_free()
