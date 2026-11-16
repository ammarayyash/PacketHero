extends CanvasLayer
# UI_Quiz.gd — Antarmuka Kuis Edukasi Model OSI (MCQ, Match, Order)
# process_mode = ALWAYS (dijalankan saat get_tree().paused = true)

signal finished(passed: bool)

const FONT_PIXEL = preload("res://assets/fonts/cyberpunk_pixel.otf")

@onready var layer_badge      : Label          = $Panel/Margin/VBox/HeaderRow/LayerBadge
@onready var status_lbl        : Label          = $Panel/Margin/VBox/HeaderRow/StatusLabel
@onready var question_lbl      : Label          = $Panel/Margin/VBox/QuestionLabel

# MCQ Nodes
@onready var options_grid      : GridContainer  = $Panel/Margin/VBox/OptionsGrid
@onready var btn_a             : Button         = $Panel/Margin/VBox/OptionsGrid/BtnA
@onready var btn_b             : Button         = $Panel/Margin/VBox/OptionsGrid/BtnB
@onready var btn_c             : Button         = $Panel/Margin/VBox/OptionsGrid/BtnC
@onready var btn_d             : Button         = $Panel/Margin/VBox/OptionsGrid/BtnD

# Match Nodes
@onready var match_container   : HBoxContainer  = $Panel/Margin/VBox/MatchContainer
@onready var left_col          : VBoxContainer  = $Panel/Margin/VBox/MatchContainer/LeftCol
@onready var right_col         : VBoxContainer  = $Panel/Margin/VBox/MatchContainer/RightCol

# Order Nodes
@onready var order_container   : VBoxContainer  = $Panel/Margin/VBox/OrderContainer
@onready var order_items_row   : HBoxContainer  = $Panel/Margin/VBox/OrderContainer/OrderItemsRow

# Feedback & Actions
@onready var feedback_panel    : PanelContainer = $Panel/Margin/VBox/FeedbackPanel
@onready var feedback_title    : Label          = $Panel/Margin/VBox/FeedbackPanel/Margin/VBoxFeedback/FeedbackTitle
@onready var expl_lbl          : Label          = $Panel/Margin/VBox/FeedbackPanel/Margin/VBoxFeedback/ExplanationLabel
@onready var btn_hint          : Button         = $Panel/Margin/VBox/BottomRow/BtnHint
@onready var btn_next          : Button         = $Panel/Margin/VBox/BottomRow/BtnNext

var _questions             : Array         = []
var _q_index               : int           = 0
var _layer_id              : String        = ""
var _current_type          : String        = "mcq"
var _answered_correctly    : bool          = false
var _has_failed_current    : bool          = false
var _passed                : bool          = false
var _first_try_streak      : int           = 0
var _current_explanation   : String        = ""

# MCQ Data
var _raw_options           : Array[String] = []
var _correct_option_text   : String        = ""
var _shuffled_opts         : Array[String] = []
var _correct_idx           : int           = 0
var _btns                  : Array[Button] = []
const LETTERS              : Array[String] = ["A", "B", "C", "D"]

# Match Data
var _pairs_left            : Array[String]     = []
var _pairs_right           : Array[String]     = []
var _matched_pairs         : Dictionary        = {} # left_idx -> right_orig_idx
var _selected_left_idx     : int               = -1
var _selected_left_btn     : Button            = null
var _match_left_btns       : Array[Button]     = []
var _match_right_btns      : Array[Button]     = []
var _match_right_items     : Array[Dictionary] = [] # [{ "text": str, "orig_idx": int }]

# Order Data
var _order_items           : Array[String]     = []
var _correct_order         : Array[int]        = []
var _order_step            : int               = 0
var _order_btns            : Array[Button]     = []
var _shuffled_order_info   : Array[Dictionary] = [] # [{ "text": str, "target_idx": int }]

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_btns = [btn_a, btn_b, btn_c, btn_d]

	for i in _btns.size():
		var idx := i
		_btns[i].pressed.connect(func() -> void: _answer_mcq(idx))

	btn_hint.pressed.connect(_use_hint)
	btn_next.pressed.connect(_next_question)
	GameState.player_died.connect(_on_player_died)

	_update_hint_button()

func start(questions: Variant, layer_id: String = "") -> void:
	if questions is Array:
		_questions = questions
	elif questions != null:
		_questions = [questions]
	else:
		_questions = []

	_layer_id = layer_id
	_q_index = 0
	_first_try_streak = 0
	_passed = false

	if _questions.is_empty():
		push_warning("UI_Quiz: Tidak ada soal yang dimuat.")
		_finish()
		return

	_load_question()

func _load_question() -> void:
	if _q_index >= _questions.size():
		_finish()
		return

	_answered_correctly = false
	_has_failed_current = false
	feedback_panel.visible = false
	btn_next.visible = false

	var raw_q: Variant = _questions[_q_index]
	var q_dict: Dictionary = _parse_question_data(raw_q)
	_current_type = str(q_dict.get("type", "mcq"))

	var q_layer: String = q_dict.get("layer_id", "")
	if _layer_id.is_empty() and not q_layer.is_empty():
		_layer_id = q_layer

	var display_layer: String = _layer_id if not _layer_id.is_empty() else "L7"
	layer_badge.text = "LAYER %s — %s (%s)" % [display_layer.lstrip("L"), _layer_name(display_layer).to_upper(), _current_type.to_upper()]
	question_lbl.text = "Q%d: %s" % [_q_index + 1, q_dict.get("question", "Pertanyaan")]
	_current_explanation = q_dict.get("explanation", "")

	if _current_type == "match":
		_setup_match_question(q_dict)
	elif _current_type == "order":
		_setup_order_question(q_dict)
	else:
		_setup_mcq_question(q_dict)

	_update_hint_button()
	_update_status_label()

# ── MCQ Logic ────────────────────────────────────────────────────────
func _setup_mcq_question(q_dict: Dictionary) -> void:
	options_grid.visible = true
	match_container.visible = false
	order_container.visible = false

	var opts_raw: Array = q_dict.get("options", [])
	_raw_options.clear()
	for opt in opts_raw:
		_raw_options.append(str(opt))

	var c_idx: int = int(q_dict.get("correct_index", 0))
	if c_idx >= 0 and c_idx < _raw_options.size():
		_correct_option_text = _raw_options[c_idx]
	elif not _raw_options.is_empty():
		_correct_option_text = _raw_options[0]
	else:
		_correct_option_text = ""

	_setup_shuffled_mcq_options()

func _setup_shuffled_mcq_options() -> void:
	_shuffled_opts = _raw_options.duplicate()
	_shuffled_opts.shuffle()
	_correct_idx = _shuffled_opts.find(_correct_option_text)
	if _correct_idx == -1 and not _shuffled_opts.is_empty():
		_correct_idx = 0

	for i in _btns.size():
		if i < _shuffled_opts.size():
			_btns[i].text = "%s) %s" % [LETTERS[i], _shuffled_opts[i]]
			_btns[i].visible = true
			_btns[i].disabled = false
			_btns[i].modulate = Color.WHITE
		else:
			_btns[i].visible = false
			_btns[i].disabled = true

func _answer_mcq(btn_idx: int) -> void:
	if _answered_correctly:
		return

	if btn_idx == _correct_idx:
		_btns[btn_idx].modulate = Color(0.3, 1.0, 0.4)
		for b in _btns:
			b.disabled = true
		_on_question_solved("✔ JAWABAN BENAR!")
	else:
		_on_question_wrong("✖ JAWABAN SALAH! Opsi diacak ulang.")
		_setup_shuffled_mcq_options()

# ── Match Logic ──────────────────────────────────────────────────────
func _setup_match_question(q_dict: Dictionary) -> void:
	options_grid.visible = false
	match_container.visible = true
	order_container.visible = false

	for child in left_col.get_children():
		child.queue_free()
	for child in right_col.get_children():
		child.queue_free()

	_pairs_left.clear()
	_pairs_right.clear()
	var raw_l: Array = q_dict.get("pairs_left", [])
	var raw_r: Array = q_dict.get("pairs_right", [])
	for item in raw_l:
		_pairs_left.append(str(item))
	for item in raw_r:
		_pairs_right.append(str(item))

	_matched_pairs.clear()
	_selected_left_idx = -1
	_selected_left_btn = null
	_match_left_btns.clear()

	for i in _pairs_left.size():
		var l_btn := Button.new()
		l_btn.custom_minimum_size = Vector2(0, Config.QUIZ_BUTTON_MIN_HEIGHT)
		l_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l_btn.text = _pairs_left[i]
		l_btn.add_theme_font_override("font", FONT_PIXEL)
		l_btn.add_theme_font_size_override("font_size", 14)
		l_btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		var idx := i
		l_btn.pressed.connect(func() -> void: _on_match_left_pressed(idx, l_btn))
		left_col.add_child(l_btn)
		_match_left_btns.append(l_btn)

	_setup_match_right_col()

func _setup_match_right_col() -> void:
	for child in right_col.get_children():
		child.queue_free()
	_match_right_btns.clear()
	_match_right_items.clear()

	for i in _pairs_right.size():
		_match_right_items.append({
			"text": _pairs_right[i],
			"orig_idx": i
		})
	_match_right_items.shuffle()

	for item in _match_right_items:
		var r_btn := Button.new()
		r_btn.custom_minimum_size = Vector2(0, Config.QUIZ_BUTTON_MIN_HEIGHT)
		r_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		r_btn.text = item["text"]
		r_btn.add_theme_font_override("font", FONT_PIXEL)
		r_btn.add_theme_font_size_override("font_size", 14)
		r_btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		var orig_idx: int = item["orig_idx"]
		r_btn.pressed.connect(func() -> void: _on_match_right_pressed(orig_idx, r_btn))
		right_col.add_child(r_btn)
		_match_right_btns.append(r_btn)

func _on_match_left_pressed(idx: int, btn: Button) -> void:
	if _answered_correctly or _matched_pairs.has(idx):
		return

	if _selected_left_btn and is_instance_valid(_selected_left_btn):
		_selected_left_btn.modulate = Color.WHITE

	_selected_left_idx = idx
	_selected_left_btn = btn
	btn.modulate = Color(0.2, 0.9, 1.0)
	AudioManager.play_sfx("res://assets/audio/sfx/ui_click.ogg")

func _on_match_right_pressed(orig_idx: int, btn: Button) -> void:
	if _answered_correctly or _selected_left_idx == -1:
		return

	# Cek apakah item kanan sudah dipasangkan
	for matched_right in _matched_pairs.values():
		if matched_right == orig_idx:
			return

	if orig_idx == _selected_left_idx:
		# Pasangan benar!
		_matched_pairs[_selected_left_idx] = orig_idx
		if _selected_left_btn and is_instance_valid(_selected_left_btn):
			_selected_left_btn.modulate = Color(0.3, 1.0, 0.4)
			_selected_left_btn.disabled = true
		btn.modulate = Color(0.3, 1.0, 0.4)
		btn.disabled = true
		_selected_left_idx = -1
		_selected_left_btn = null
		AudioManager.play_sfx("res://assets/audio/sfx/ui_click.ogg")

		if _matched_pairs.size() == _pairs_left.size():
			_on_question_solved("✔ SEMUA PASANGAN BENAR!")
	else:
		# Pasangan salah → damage 1 dan pasangan reset!
		_on_question_wrong("✖ Pasangan salah! Semua pasangan di-reset.")
		_reset_match_pairs()

func _reset_match_pairs() -> void:
	_matched_pairs.clear()
	_selected_left_idx = -1
	_selected_left_btn = null
	for btn in _match_left_btns:
		if is_instance_valid(btn):
			btn.disabled = false
			btn.modulate = Color.WHITE
	_setup_match_right_col()

# ── Order Logic ──────────────────────────────────────────────────────
func _setup_order_question(q_dict: Dictionary) -> void:
	options_grid.visible = false
	match_container.visible = false
	order_container.visible = true

	_order_items.clear()
	var raw_items: Array = q_dict.get("order_items", [])
	for it in raw_items:
		_order_items.append(str(it))

	_correct_order.clear()
	var raw_order: Array = q_dict.get("correct_order", [])
	for o in raw_order:
		_correct_order.append(int(o))
	if _correct_order.is_empty():
		for i in _order_items.size():
			_correct_order.append(i)

	_reset_order_sequence()

func _reset_order_sequence() -> void:
	_order_step = 0
	for child in order_items_row.get_children():
		child.queue_free()
	_order_btns.clear()
	_shuffled_order_info.clear()

	for i in _order_items.size():
		_shuffled_order_info.append({
			"text": _order_items[i],
			"target_idx": i
		})
	_shuffled_order_info.shuffle()

	for item in _shuffled_order_info:
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(130, Config.QUIZ_BUTTON_MIN_HEIGHT)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.text = item["text"]
		btn.add_theme_font_override("font", FONT_PIXEL)
		btn.add_theme_font_size_override("font_size", 14)
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		var target_idx: int = item["target_idx"]
		btn.pressed.connect(func() -> void: _on_order_item_pressed(target_idx, btn, item["text"]))
		order_items_row.add_child(btn)
		_order_btns.append(btn)

func _on_order_item_pressed(target_idx: int, btn: Button, original_text: String) -> void:
	if _answered_correctly or btn.disabled:
		return

	if _order_step < _correct_order.size() and target_idx == _correct_order[_order_step]:
		# Langkah urutan benar!
		_order_step += 1
		btn.disabled = true
		btn.modulate = Color(0.3, 1.0, 0.4)
		btn.text = "[%d] %s" % [_order_step, original_text]
		AudioManager.play_sfx("res://assets/audio/sfx/ui_click.ogg")

		if _order_step == _correct_order.size():
			_on_question_solved("✔ URUTAN ENKAPSULASI BENAR!")
	else:
		# Urutan salah → damage 1 dan reset!
		_on_question_wrong("✖ Urutan salah! Urutan di-reset.")
		_reset_order_sequence()

# ── General Solved / Wrong Handlers ──────────────────────────────────
func _on_question_solved(title_text: String) -> void:
	_answered_correctly = true
	_passed = true

	var exp_reward: int = 0
	var bw_reward: int = 0
	var streak_bonus_text: String = ""

	if not _has_failed_current:
		exp_reward = Config.QUIZ_EXP_FIRST_TRY
		bw_reward = Config.QUIZ_BW_FIRST_TRY
		_first_try_streak += 1
		if _first_try_streak == Config.QUIZ_STREAK_TARGET:
			exp_reward += Config.QUIZ_STREAK_BONUS_EXP
			streak_bonus_text = " [Bonus Streak 3x: +%d EXP!]" % Config.QUIZ_STREAK_BONUS_EXP
	else:
		exp_reward = Config.QUIZ_EXP_RETRY
		bw_reward = Config.QUIZ_BW_RETRY
		_first_try_streak = 0

	GameState.add_exp(exp_reward)
	GameState.add_bandwidth(bw_reward)
	AudioManager.play_sfx("res://assets/audio/sfx/quiz_correct.ogg")

	feedback_title.text = "%s (+%d EXP, +%d BW)%s" % [title_text, exp_reward, bw_reward, streak_bonus_text]
	feedback_title.modulate = Color(0.3, 1.0, 0.4)
	expl_lbl.text = _current_explanation
	feedback_panel.visible = true

	btn_next.text = "SELESAI ✔" if _q_index >= _questions.size() - 1 else "LANJUT ▶"
	btn_next.visible = true
	_update_status_label()

func _on_question_wrong(msg: String) -> void:
	_has_failed_current = true
	_first_try_streak = 0
	GameState.take_damage(Config.QUIZ_DAMAGE_WRONG)
	AudioManager.play_sfx("res://assets/audio/sfx/quiz_wrong.ogg")

	feedback_title.text = "%s (-%d Integrity)!" % [msg, Config.QUIZ_DAMAGE_WRONG]
	feedback_title.modulate = Color(1.0, 0.3, 0.3)
	expl_lbl.text = _current_explanation
	feedback_panel.visible = true
	_update_status_label()

# ── Hint System ──────────────────────────────────────────────────────
func _use_hint() -> void:
	if GameState.hint_charges <= 0 or _answered_correctly:
		return

	GameState.hint_charges -= 1
	_update_hint_button()
	AudioManager.play_sfx("res://assets/audio/sfx/ui_click.ogg")

	if _current_type == "mcq" or _current_type == "tf":
		var wrong_indices: Array[int] = []
		for i in _btns.size():
			if _btns[i].visible and i != _correct_idx and i < _shuffled_opts.size():
				wrong_indices.append(i)

		if not wrong_indices.is_empty():
			wrong_indices.shuffle()
			var hide_idx: int = wrong_indices[0]
			_btns[hide_idx].visible = false
			_btns[hide_idx].disabled = true

	elif _current_type == "match":
		# Otomatis pasangkan 1 pasangan yang belum cocok
		for i in _pairs_left.size():
			if not _matched_pairs.has(i):
				var l_btn: Button = _match_left_btns[i]
				var r_btn: Button = null
				for rb in _match_right_btns:
					if rb.text == _pairs_right[i]:
						r_btn = rb
						break
				if l_btn and r_btn and is_instance_valid(l_btn) and is_instance_valid(r_btn):
					_matched_pairs[i] = i
					l_btn.modulate = Color(0.3, 1.0, 0.4)
					l_btn.disabled = true
					r_btn.modulate = Color(0.3, 1.0, 0.4)
					r_btn.disabled = true
					_selected_left_idx = -1
					_selected_left_btn = null
					if _matched_pairs.size() == _pairs_left.size():
						_on_question_solved("✔ SEMUA PASANGAN BENAR!")
					break

	elif _current_type == "order":
		# Otomatis ketuk item urutan berikutnya yang benar
		if _order_step < _correct_order.size():
			var expected_target := _correct_order[_order_step]
			for it in _shuffled_order_info:
				if it["target_idx"] == expected_target:
					for b in _order_btns:
						if is_instance_valid(b) and b.text == it["text"] and not b.disabled:
							_on_order_item_pressed(expected_target, b, it["text"])
							return

func _update_hint_button() -> void:
	btn_hint.text = "💡 Petunjuk (%d)" % GameState.hint_charges
	btn_hint.disabled = (GameState.hint_charges <= 0)

func _update_status_label() -> void:
	var total_q: int = max(_questions.size(), 1)
	var streak_info: String = " | Streak: %d" % _first_try_streak if _first_try_streak > 0 else ""
	status_lbl.text = "Soal %d / %d%s" % [_q_index + 1, total_q, streak_info]

func _next_question() -> void:
	_q_index += 1
	_load_question()

func _on_player_died() -> void:
	_finish()

func _finish() -> void:
	finished.emit(_passed)
	if get_tree().paused:
		get_tree().paused = false
	queue_free()

func _parse_question_data(raw_q: Variant) -> Dictionary:
	if raw_q is QuizQuestion:
		return raw_q.to_dict()
	elif raw_q is Dictionary:
		return raw_q
	elif raw_q != null and "question" in raw_q:
		return {
			"layer_id": raw_q.get("layer_id") if "layer_id" in raw_q else "",
			"type": raw_q.get("type") if "type" in raw_q else "mcq",
			"question": raw_q.get("question"),
			"options": raw_q.get("options") if "options" in raw_q else [],
			"correct_index": raw_q.get("correct_index") if "correct_index" in raw_q else 0,
			"pairs_left": raw_q.get("pairs_left") if "pairs_left" in raw_q else [],
			"pairs_right": raw_q.get("pairs_right") if "pairs_right" in raw_q else [],
			"order_items": raw_q.get("order_items") if "order_items" in raw_q else [],
			"correct_order": raw_q.get("correct_order") if "correct_order" in raw_q else [],
			"explanation": raw_q.get("explanation") if "explanation" in raw_q else ""
		}
	return {}

func _layer_name(lid: String) -> String:
	var names := {
		"L7": "Application", "L6": "Presentation", "L5": "Session",
		"L4": "Transport", "L3": "Network", "L2": "Data Link", "L1": "Physical"
	}
	return names.get(lid, lid)
