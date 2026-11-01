extends "res://RenameToYourMinigame/minigame.gd"

# Example 6: HUD that persists after Win() and shared values
# Press Insert several times: the counter increases and the old HUD is replaced

const RUNS_KEY: String = "example_runs"

@onready var info: Label = $Info

func _ready() -> void:
	persistent_state = true

func Start_Minigame(_param: Dictionary):
	# Remove the HUD that was left over from the previous time.
	for old_hud in GlobalStates.get_persistent_minigames():
		if old_hud != self and old_hud.scene_file_path == scene_file_path:
			old_hud.queue_free()

	# In Danganmake, this value is saved in the save file
	# whereas in the TestBench, it is only kept in memory.
	var runs: int = GlobalStates.get_custom_value(RUNS_KEY, 0) + 1
	GlobalStates.set_custom_value(RUNS_KEY, runs)
	info.text = "HUD alive. Runs: %d" % runs

	await CharacterList.Wait(0.5)
	Win()
