@tool
extends Node3D

# update the label
@onready var name_label: Label3D = $Label3D

func _ready() -> void:
	_update_label()
	renamed.connect(_update_label)

func _update_label() -> void:
	if is_instance_valid(name_label):
		name_label.text = name
