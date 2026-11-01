extends "res://RenameToYourMinigame/minigame.gd"

# Example 7: The minigame calls Win(), remains active while a dialogue is displayed,
# and continues once that dialogue ends.
# In the TestBench, the dialogue is ended with a click. In Danganmake, this is
# specified in the .dialogue file as: do GlobalStates.Dialogue_Finished()

const TARGET: String = "Character_02"

@onready var info: Label = $Info

func _ready() -> void:
	persistent_state = true

func Start_Minigame(_param: Dictionary):
	info.text = "Part 1: the minigame starts"
	CharacterList.focus_CH(TARGET, 50, 0.4)
	await CharacterList.Wait(1.5)

	# It connects before Win() so as not to lose the signal
	GlobalStates.dialogue_resumed.connect(_on_dialogue_resumed, CONNECT_ONE_SHOT)
	GlobalStates.dialogue_finished.connect(_on_dialogue_finished, CONNECT_ONE_SHOT)
	info.text = "Win() emitted, the dialogue goes on"
	Win()

func _on_dialogue_resumed() -> void:
	info.text = "Waiting for the dialogue to finish..."

func _on_dialogue_finished() -> void:
	# Part 2: react at the end of the dialogue
	info.text = "Dialogue finished, part 2 of the minigame"
	var sprite := CharacterList.get_character_sprite_3d(TARGET)
	if sprite:
		var base_scale := sprite.scale
		var tween := create_tween()
		tween.tween_property(sprite, "scale", base_scale * 1.4, 0.3)
		tween.tween_property(sprite, "scale", base_scale, 0.3)
		await tween.finished
	await CharacterList.Wait(1.0)
	# It’s no longer needed; it comes off on its own.
	queue_free()
