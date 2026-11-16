extends Area2D
# CarrySlot.gd — Slot penerima item yang dibawa pemain
class_name CarrySlot

signal accepted(item_id: String)

@export var accepts_id          : String    = "item_1"
@export var slot_label          : String    = "SLOT"
@export var slot_warna          : Color     = Color.YELLOW
@export var slot_texture        : Texture2D = null
@export var request_bubble_text : String    = ""
@export var reject_message      : String    = ""

var is_filled           : bool      = false
var _player_in_area     : Node2D    = null
var _feedback_timer     : float     = 0.0

@onready var sprite        : Sprite2D  = get_node_or_null("Sprite2D")
@onready var lbl_slot      : Label     = get_node_or_null("LabelSlot")
@onready var prompt_lbl    : Label     = get_node_or_null("PromptLabel")
@onready var feedback_lbl  : Label     = get_node_or_null("FeedbackLabel")
@onready var bubble_lbl    : Label     = get_node_or_null("BubbleLabel")

func _ready() -> void:
	add_to_group("resettable")
	# Layer 6 = Trigger (32), Mask 2 = Player (2)
	collision_layer = 32
	collision_mask = 2
	
	_apply_visuals()
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	if _feedback_timer > 0.0:
		_feedback_timer -= delta
		if _feedback_timer <= 0.0 and feedback_lbl:
			feedback_lbl.visible = false

	if _player_in_area and not is_filled:
		_update_prompt()
		if Input.is_action_just_pressed("interact"):
			_try_place_item(_player_in_area)

func _apply_visuals() -> void:
	if sprite:
		if slot_texture:
			sprite.texture = slot_texture
		sprite.modulate = Color(0.2, 1.0, 0.4, 1.0) if is_filled else slot_warna
	if lbl_slot:
		lbl_slot.text = "%s [%s]" % [slot_label, accepts_id]
		lbl_slot.add_theme_color_override("font_color", slot_warna)
	if bubble_lbl:
		if request_bubble_text != "":
			bubble_lbl.text = "\"%s\"" % request_bubble_text
			bubble_lbl.visible = not is_filled
		else:
			bubble_lbl.visible = false
	if prompt_lbl:
		prompt_lbl.visible = false
	if feedback_lbl:
		feedback_lbl.visible = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_area = body
		_update_prompt()

func _on_body_exited(body: Node2D) -> void:
	if body == _player_in_area:
		_player_in_area = null
		if prompt_lbl:
			prompt_lbl.visible = false

func _update_prompt() -> void:
	if not prompt_lbl:
		return
	if is_filled:
		prompt_lbl.visible = false
		return
	if _player_in_area and _player_in_area.get("carried_item") != null:
		prompt_lbl.text = "[E] MASUKKAN ITEM"
		prompt_lbl.visible = true
	else:
		prompt_lbl.visible = false

func _try_place_item(player: Node2D) -> void:
	var item: Node2D = player.get("carried_item")
	if item == null:
		return
		
	var item_id_val: String = item.get("item_id") if "item_id" in item else ""
	
	if item_id_val.to_upper() == accepts_id.to_upper():
		# Cocok!
		is_filled = true
		if item.has_method("lock_in_slot"):
			item.lock_in_slot(global_position)
		if player.get("carried_item") == item:
			player.set("carried_item", null)
			
		_show_feedback("Item Cocok! Diterima.", Color(0.2, 1.0, 0.4, 1.0))
		if prompt_lbl:
			prompt_lbl.visible = false
		if bubble_lbl:
			bubble_lbl.visible = false
		if sprite:
			sprite.modulate = Color(0.2, 1.0, 0.4, 1.0)
		if AudioManager:
			AudioManager.play_sfx("res://assets/audio/sfx/gate_open.ogg")
			
		accepted.emit(item_id_val)
	else:
		# Tidak cocok! Item kembali ke posisi asal, tampil pesan singkat, tidak ada damage.
		var fail_text: String = reject_message if reject_message != "" else "Item Tidak Cocok! Kembali ke asal."
		_show_feedback(fail_text, Color(1.0, 0.3, 0.3, 1.0))
		if item.has_method("return_to_spawn"):
			item.return_to_spawn()
		if player.get("carried_item") == item:
			player.set("carried_item", null)
		if AudioManager:
			AudioManager.play_sfx("res://assets/audio/sfx/player_hit.ogg")

func _show_feedback(msg: String, col: Color) -> void:
	if feedback_lbl:
		feedback_lbl.text = msg
		feedback_lbl.add_theme_color_override("font_color", col)
		feedback_lbl.visible = true
		_feedback_timer = Config.CARRY_SLOT_FEEDBACK_DURATION

func reset() -> void:
	is_filled = false
	_apply_visuals()
