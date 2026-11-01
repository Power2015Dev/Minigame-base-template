extends "res://RenameToYourMinigame/minigame.gd"

# Example 5: animation using standard camera functions,
# using the Editor_Interface's SpinBox to specify the number of shots

const SHOT_TIME: float = 1.5

@onready var info: Label = $Info

func Start_Minigame(param: Dictionary):
	var names := CharacterList.get_character_names()
	if names.is_empty():
		Win()
		return

	# "example" is the key that get_data() stores in editor_interface.gd
	var shots := clampi(int(param.get("example", 3)), 1, names.size())

	for i in shots:
		var ch_name := names[i]
		info.text = "%d / %d  %s" % [i + 1, shots, ch_name]
		if i % 2 == 0:
			CharacterList.focus_CH_zoom_in(ch_name, 45, SHOT_TIME, 1.8)
		else:
			CharacterList.focus_CH_zoom_in_rotated(ch_name, 45, SHOT_TIME, -15.0, 1.8)
		await CharacterList.Wait(SHOT_TIME)

	Win()
