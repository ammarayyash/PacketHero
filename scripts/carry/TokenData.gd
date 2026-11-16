extends CarryItem
# TokenData.gd — Token Data mentah yang dapat diolah statusnya melewati stasiun
class_name TokenData

enum State { RAW, COMPRESSED, READY, INVALID }

var current_state : State = State.RAW

func _ready() -> void:
	super._ready()
	set_state(State.RAW)

func set_state(new_state: State) -> void:
	current_state = new_state
	match current_state:
		State.RAW:
			item_id = "DATA_RAW"
			label_text = "Data Mentah"
			warna = Color(0.85, 0.88, 0.95, 1.0)
		State.COMPRESSED:
			item_id = "DATA_COMPRESSED"
			label_text = "Terkompres"
			warna = Color(0.2, 0.95, 0.65, 1.0)
		State.READY:
			item_id = "DATA_READY"
			label_text = "Terkompres + Terenkripsi"
			warna = Color(0.75, 0.45, 1.0, 1.0)
		State.INVALID:
			item_id = "DATA_INVALID"
			label_text = "Terenkripsi, sulit dikompres"
			warna = Color(1.0, 0.35, 0.35, 1.0)
			
	_apply_visuals()

func return_to_spawn() -> void:
	set_state(State.RAW)
	super.return_to_spawn()

func reset() -> void:
	set_state(State.RAW)
	super.reset()
