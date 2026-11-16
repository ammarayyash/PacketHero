extends Area2D
# CarryItem.gd — Item yang dapat diambil dan dibawa oleh pemain di atas kepala
class_name CarryItem

@export var item_id      : String    = "item_1"
@export var label_text   : String    = "DATA"
@export var warna        : Color     = Color.CYAN
@export var item_texture : Texture2D = null

var is_carried        : bool      = false
var is_slotted        : bool      = false
var carrier           : Node2D    = null
var _player_in_area   : Node2D    = null
var _spawn_position   : Vector2   = Vector2.ZERO

@onready var sprite      : Sprite2D  = get_node_or_null("Sprite2D")
@onready var lbl_item    : Label     = get_node_or_null("LabelItem")
@onready var prompt_lbl  : Label     = get_node_or_null("PromptLabel")

func _ready() -> void:
	add_to_group("resettable")
	_spawn_position = global_position
	
	# Layer 6 = Trigger (32), Mask 2 = Player (2)
	collision_layer = 32
	collision_mask = 2
	
	_apply_visuals()
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	if GameState and GameState.has_signal("player_died"):
		GameState.player_died.connect(_on_player_died)

func _process(_delta: float) -> void:
	if is_carried and carrier != null:
		global_position = carrier.global_position + Vector2(0, Config.CARRY_ITEM_OFFSET_Y)

	if _player_in_area and not is_carried and not is_slotted:
		if Input.is_action_just_pressed("interact"):
			_try_pickup(_player_in_area)

func _apply_visuals() -> void:
	if sprite:
		if item_texture:
			sprite.texture = item_texture
		sprite.modulate = warna
	if lbl_item:
		lbl_item.text = label_text
		lbl_item.add_theme_color_override("font_color", warna)
	if prompt_lbl:
		prompt_lbl.visible = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_area = body
		if not is_carried and not is_slotted:
			if _can_player_pickup(body) and prompt_lbl:
				prompt_lbl.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body == _player_in_area:
		_player_in_area = null
		if prompt_lbl:
			prompt_lbl.visible = false

func _can_player_pickup(player: Node2D) -> bool:
	if player.get("carried_item") == null:
		return true
	return false

func _try_pickup(player: Node2D) -> void:
	if not _can_player_pickup(player):
		return
	pickup(player)

func pickup(player: Node2D) -> void:
	is_carried = true
	carrier = player
	player.set("carried_item", self)
	if prompt_lbl:
		prompt_lbl.visible = false
	if AudioManager:
		AudioManager.play_sfx("res://assets/audio/sfx/pickup_coin.ogg")

func lock_in_slot(slot_pos: Vector2) -> void:
	is_carried = false
	is_slotted = true
	if carrier and carrier.get("carried_item") == self:
		carrier.set("carried_item", null)
	carrier = null
	global_position = slot_pos
	if prompt_lbl:
		prompt_lbl.visible = false

func return_to_spawn() -> void:
	if is_carried:
		if carrier and carrier.get("carried_item") == self:
			carrier.set("carried_item", null)
	is_carried = false
	is_slotted = false
	carrier = null
	global_position = _spawn_position
	if prompt_lbl:
		prompt_lbl.visible = false

func reset() -> void:
	return_to_spawn()

func _on_player_died() -> void:
	return_to_spawn()
