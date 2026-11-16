extends Area2D
class_name JumpPad
# JumpPad.gd — Melontarkan pemain ke platform tinggi dengan efek animasi membal (squash & stretch)

@export var bounce_velocity : float = -780.0
@export var sfx_path        : String = "res://assets/audio/sfx/checkpoint.ogg"

@onready var sprite : Sprite2D = get_node_or_null("Sprite2D")

var _is_bouncing : bool = false

func _ready() -> void:
	collision_layer = 0
	set_collision_mask_value(2, true) # Mask 2 = Player
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	
	if body is CharacterBody2D:
		# Lontarkan pemain ke atas
		body.velocity.y = bounce_velocity
		
		# Putar SFX
		if AudioManager:
			AudioManager.play_sfx(sfx_path)
		
		# Animasi membal per (squash & stretch)
		if sprite and not _is_bouncing:
			_is_bouncing = true
			var tw : Tween = create_tween()
			tw.tween_property(sprite, "scale", Vector2(1.35, 0.55), 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tw.tween_property(sprite, "scale", Vector2(0.85, 1.25), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tw.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
			tw.tween_callback(func() -> void:
				_is_bouncing = false
			)
