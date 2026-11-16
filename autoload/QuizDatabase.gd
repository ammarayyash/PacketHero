extends Node

var _questions_by_layer: Dictionary = {}
var _all_questions: Array[QuizQuestion] = []

func _ready() -> void:
	load_questions()

func load_questions(dir_path: String = "res://resources/questions/") -> void:
	_questions_by_layer.clear()
	_all_questions.clear()
	
	var dir := DirAccess.open(dir_path)
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				# Mendukung .tres biasa maupun .tres.remap untuk export web
				if file_name.ends_with(".tres") or file_name.ends_with(".tres.remap"):
					var clean_name := file_name.trim_suffix(".remap")
					var full_path := dir_path.path_join(clean_name)
					var res := load(full_path)
					if res is QuizQuestion:
						_add_question(res)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		push_warning("QuizDatabase: Direktori %s tidak dapat diakses." % dir_path)

func _add_question(q: QuizQuestion) -> void:
	_all_questions.append(q)
	if not _questions_by_layer.has(q.layer_id):
		var arr: Array[QuizQuestion] = []
		_questions_by_layer[q.layer_id] = arr
	_questions_by_layer[q.layer_id].append(q)

func get_for_layer(layer_id: String) -> QuizQuestion:
	if not _questions_by_layer.has(layer_id):
		return null
	var list: Array[QuizQuestion] = _questions_by_layer[layer_id]
	if list.is_empty():
		return null
	return list.pick_random()

func get_all_for_layer(layer_id: String) -> Array[QuizQuestion]:
	if not _questions_by_layer.has(layer_id):
		return []
	return _questions_by_layer[layer_id].duplicate()

func get_all_questions() -> Array[QuizQuestion]:
	return _all_questions.duplicate()

func get_all_layers() -> Array:
	return _questions_by_layer.keys()
