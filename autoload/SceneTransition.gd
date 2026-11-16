extends CanvasLayer

var _transitioning := false

func _ready() -> void:
	layer = 125
	process_mode = Node.PROCESS_MODE_ALWAYS
	var rect := ColorRect.new()
	rect.name = "Overlay"
	rect.color = Color.BLACK
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.modulate.a = 0.0
	add_child(rect)

func change_scene(path: String, fade_time := 0.4) -> void:
	if _transitioning:
		return
	_transitioning = true
	var overlay : ColorRect = $Overlay
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(overlay, "modulate:a", 1.0, fade_time)
	await tw.finished
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	await get_tree().process_frame
	var tw2 := create_tween()
	tw2.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw2.tween_property(overlay, "modulate:a", 0.0, fade_time)
	await tw2.finished
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_transitioning = false
