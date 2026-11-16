class_name QuizQuestion
extends Resource

@export var layer_id: String = "L7"
@export_enum("mcq", "tf", "match", "order") var type: String = "mcq"
@export_multiline var question: String = ""
@export var options: Array[String] = []
@export var correct_index: int = 0
@export var pairs_left: Array[String] = []
@export var pairs_right: Array[String] = []
@export var order_items: Array[String] = []
@export var correct_order: Array[int] = []
@export_multiline var explanation: String = ""

func to_dict() -> Dictionary:
	return {
		"layer_id": layer_id,
		"type": type,
		"question": question,
		"options": options,
		"correct_index": correct_index,
		"pairs_left": pairs_left,
		"pairs_right": pairs_right,
		"order_items": order_items,
		"correct_order": correct_order,
		"explanation": explanation
	}
