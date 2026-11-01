extends "res://RenameToYourMinigame/minigame.gd"

# Example 1: take the camera and rotate it around a character

const TARGET: String = "Character_01"
const ORBIT_TIME: float = 4.0
const RADIUS: float = 2.5

var cam: Camera3D
var center: Vector3

func Start_Minigame(_param: Dictionary):
	# As long as the camera is being controlled, the focus_CH do not move it.
	cam = CharacterList.take_camera_control()
	if cam == null:
		push_warning("There is no 3D camera loaded")
		Win()
		return

	center = CharacterList.get_character_position(TARGET) + Vector3.UP * 1.5

	var balloon := GlobalStates.get_current_balloon()
	if balloon:
		balloon.set("visible", false)

	var tween := create_tween()
	tween.tween_method(_orbit, 0.0, TAU, ORBIT_TIME)
	await tween.finished

	if is_instance_valid(balloon):
		balloon.set("visible", true)
	CharacterList.release_camera_control()
	Win()

func _orbit(angle: float) -> void:
	cam.global_position = center + Vector3(cos(angle), 0.3, sin(angle)) * RADIUS
	cam.look_at(center, Vector3.UP)
