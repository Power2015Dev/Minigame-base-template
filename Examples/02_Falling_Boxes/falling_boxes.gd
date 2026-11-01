extends "res://RenameToYourMinigame/minigame.gd"

# Example 2: Instantiating a 3D scene created in the editor within the trial/test environment

const BOX_SCENE: PackedScene = preload("res://Examples/02_Falling_Boxes/falling_box.tscn")
const TARGET: String = "Character_03"
const BOX_COUNT: int = 12

@onready var info: Label = $Info

func Start_Minigame(_param: Dictionary):
	info.text = "Boxes are falling on %s" % TARGET
	CharacterList.focus_CH(TARGET, 60, 0.5)
	await CharacterList.Wait(0.6)

	var target_pos := CharacterList.get_character_position(TARGET)
	for i in BOX_COUNT:
		var box := BOX_SCENE.instantiate() as RigidBody3D
		# add_3d_node releases it automatically when the minigame ends.
		CharacterList.add_3d_node(box)
		box.global_position = target_pos + Vector3(randf_range(-0.6, 0.6), 4.0, randf_range(-0.6, 0.6))
		box.rotation = Vector3(randf(), randf(), randf()) * TAU
		await CharacterList.Wait(0.25)

	await CharacterList.Wait(2.0)
	Win()
