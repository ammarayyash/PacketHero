extends CanvasLayer
class_name PauseOverlay
# PauseOverlay.gd — Mengelola pause/unpause dengan aman tanpa memblokir input engine

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not event.is_echo():
		get_viewport().set_input_as_handled()
		toggle_pause()

func toggle_pause() -> void:
	var new_state : bool = not get_tree().paused
	get_tree().paused = new_state
	visible = new_state
