extends CharacterBody2D
class_name Enemy

signal died

@export var hp        := 2
@export var move_speed := 80.0
@export var exp_reward := 10
@export var damage     := 1

var _hp_current := 0

@onready var anim : AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	_hp_current = hp
	add_to_group("resettable")
	add_to_group("enemy")
	set_collision_layer_value(3, true)
	set_collision_mask_value(1, true)

func take_hit(dmg := 1) -> void:
	_hp_current -= dmg
	var tw := create_tween()
	tw.tween_property(anim, "modulate", Color(1.5, 0.5, 0.5), 0.05)
	tw.tween_property(anim, "modulate", Color.WHITE, 0.1)
	if _hp_current <= 0:
		_die()

func _die() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/explosion.ogg")
	GameState.add_exp(exp_reward)
	died.emit()
	queue_free()

func reset() -> void:
	_hp_current = hp
	visible = true
	set_process(true)
	set_physics_process(true)
