extends EnemyBase
class_name SpamDrone
# spam_drone.gd — Drone musuh turunan EnemyBase yang berpatroli terbang horizontal

func _ready() -> void:
	is_flying = true
	super._ready()
	if anim and anim.sprite_frames and anim.sprite_frames.has_animation("fly"):
		anim.play("fly")

func reset() -> void:
	super.reset()
	if anim and anim.sprite_frames and anim.sprite_frames.has_animation("fly"):
		anim.play("fly")
