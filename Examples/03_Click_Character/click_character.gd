extends "res://RenameToYourMinigame/minigame.gd"

# Example 3: click on a 3D character

const TARGET: String = "Character_05"
const DAMAGE: float = 20.0

@onready var info: Label = $Info

var active: bool = false
var balloon: Node

func Start_Minigame(_param: Dictionary):
	info.text = "Click on %s" % TARGET

	# The balloon panel blocks clicks underneath it, so it gets hidden.
	balloon = GlobalStates.get_current_balloon()
	if balloon:
		balloon.set("visible", false)

	var cam := CharacterList.take_camera_control()
	if cam:
		cam.global_position = Vector3(0.0, 11.0, 5.0)
		cam.look_at(Vector3.ZERO, Vector3.UP)
	active = true

func _unhandled_input(event: InputEvent) -> void:
	if not active:
		return
	var click := event as InputEventMouseButton
	if click == null or not click.pressed or click.button_index != MOUSE_BUTTON_LEFT:
		return

	# Characters in Danganmake do not have collision
	# they are located based on their position on the screen.
	var picked := CharacterList.get_character_at_screen(click.position)
	if picked.is_empty():
		return

	if picked == TARGET:
		_finish()
	else:
		info.text = "That is %s, try again" % picked
		GlobalStates.Hurt.emit(DAMAGE)
		_flash_red(picked)

func _flash_red(ch_name: String) -> void:
	var sprite := CharacterList.get_character_sprite_3d(ch_name)
	if sprite == null:
		return
	sprite.modulate = Color.RED
	create_tween().tween_property(sprite, "modulate", Color.WHITE, 0.4)

func _finish() -> void:
	active = false
	info.text = "Correct!"
	await CharacterList.Wait(0.8)
	if is_instance_valid(balloon):
		balloon.set("visible", true)
	Win()
