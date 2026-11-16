extends Node2D
# TestLevel.gd — Scene arena uji coba komponen UI, Player, dan HUD

@onready var hud : CanvasLayer = get_node_or_null("UI_HUD")

func _ready() -> void:
	if hud and hud.has_method("set_section"):
		hud.set_section("Startup Plaza", "L7")
