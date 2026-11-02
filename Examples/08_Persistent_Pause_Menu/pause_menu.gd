extends "res://RenameToYourMinigame/minigame.gd"

# Example 8: pause menu that comes back after loading a save
# Press Insert, then Esc. Save, press Insert again and Load: the counter goes back.
# Inside Danganmake it also comes back after closing and reopening the game.

const INSERTS_KEY: String = "example_menu_inserts"

@onready var info: Label = $Info
@onready var menu: Control = $Menu
@onready var bullets: Label = $Menu/Box/Bullets
@onready var replay_voice: Button = $Menu/Box/ReplayVoice
@onready var music_volume: HSlider = $Menu/Box/MusicVolume
@onready var load_button: Button = $Menu/Box/Load

var last_voice: String = ""

func _ready() -> void:
	
	# WARNING this function is not called like this in danganmake
	# just use the sounds of your sounds folder on your mod
	GlobalSound.SFX_recursion_list("res://Examples/08_Persistent_Pause_Menu", GlobalSound.sfx)
	
	
	persistent_state = true
	GlobalStates.claim_action("menu", _open_menu)
	GlobalStates.pause_changed.connect(_on_pause_changed)

func Start_Minigame(_param: Dictionary):
	for old_menu in GlobalStates.get_persistent_minigames():
		if old_menu != self and old_menu.scene_file_path == scene_file_path:
			old_menu.queue_free()

	var inserts: int = GlobalStates.get_custom_value(INSERTS_KEY, 0) + 1
	GlobalStates.set_custom_value(INSERTS_KEY, inserts)
	_show_inserts(inserts)

	await CharacterList.Wait(0.5)
	Win()

func Resume_Minigame(resume_info: Dictionary) -> bool:
	var inserts = GlobalStates.get_custom_value(INSERTS_KEY, null)
	# A test from a bookmark has no save, the inserts before that line are enough
	if inserts == null and not resume_info.calls.is_empty():
		inserts = resume_info.calls.size()
	# A save made before the first insert
	if inserts == null:
		return false
	persistent_state = true
	_show_inserts(int(inserts))
	return true

func _show_inserts(inserts: int) -> void:
	info.text = "Inserts: %d. Esc opens the menu" % inserts

func _input(event: InputEvent) -> void:
	if menu.visible and event.is_action_pressed("menu"):
		_close_menu()
		# Without this the same Esc reaches Danganmake, now unpaused, and opens the menu again
		get_viewport().set_input_as_handled()

func _open_menu() -> void:
	bullets.text = "Truth Bullets: %d" % GlobalStates.get_truth_bullet_list().size()
	music_volume.set_value_no_signal(GlobalSound.get_volume("Music"))
	load_button.disabled = not GlobalStates.has_save()
	menu.visible = true
	GlobalSound.set_audio_paused("SFX", true)
	GlobalStates.set_game_paused(true)

func _close_menu() -> void:
	menu.visible = false
	GlobalSound.Stop_SFX()
	GlobalStates.set_game_paused(false)
	GlobalSound.set_audio_paused("SFX", false)


func _on_pause_changed(paused: bool) -> void:
	info.visible = not paused

func _on_replay_voice_pressed() -> void:
	GlobalSound.Load_SFX("aypordios")

func _on_music_volume_value_changed(value: float) -> void:
	GlobalSound.set_volume("Music", int(value))

func _on_save_pressed() -> void:
	GlobalStates.save_game()
	load_button.disabled = false

func _on_load_pressed() -> void:
	_close_menu()
	GlobalStates.load_game()

func _on_title_pressed() -> void:
	_close_menu()
	GlobalStates.return_to_title()
