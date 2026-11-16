extends Area2D
# Signboard.gd — Papan petunjuk tutorial di area level
class_name Signboard

@export var title_text    : String    = "PETUNJUK"
@export_multiline var message_text  : String    = "Instruksi petunjuk di sini..."
@export var sign_texture  : Texture2D = null

@onready var sprite      : Sprite2D = get_node_or_null("Sprite2D")
@onready var panel       : Control  = get_node_or_null("Panel")
@onready var lbl_title   : Label    = get_node_or_null("Panel/MarginContainer/VBoxContainer/LblTitle")
@onready var lbl_message : Label    = get_node_or_null("Panel/MarginContainer/VBoxContainer/LblMessage")

func _ready() -> void:
	# Layer 6 = Trigger (32), Mask 2 = Player (2)
	collision_layer = 32
	collision_mask = 2
	
	if sign_texture and sprite:
		sprite.texture = sign_texture
		
	if lbl_title:
		lbl_title.text = title_text
	if lbl_message:
		lbl_message.text = message_text
		
	if panel:
		panel.visible = false
		
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if panel:
			panel.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		if panel:
			panel.visible = false
