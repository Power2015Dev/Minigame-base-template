extends Node

signal Player_won
signal Player_lose
# maximum is 100 and minimun is 0.0
signal Hurt(Damage_taken : float)
# Dialogue state, useful for persistent minigames
signal dialogue_paused
signal dialogue_resumed
signal dialogue_finished
# Every dialogue line shown: {"character", "text", "id", "voice"}
# voice is the voice line that played with it ("" if none),
# you can play it again with GlobalSound.get_voice_stream(voice)
signal dialogue_line_shown(line: Dictionary)
# Emitted when set_game_paused pauses or resumes the game
signal pause_changed(paused: bool)


func Play_iSee():
	# This will instantiate the I_SEE to display it
	# it is an asynchronous function.
	# This is an example how the game do it
	# Don't uncomment it, because it's an example
	# the game will know where the scene is. 
	#
	# var instance = Isee_scene.instantiate()
	# get_tree().current_scene.add_child(instance)
	# instance.Prepare()
	# await instance.Play()
	pass
	
func Play_iSee_char_selection(char : String = ""):
	# its almost the same the diference here it is not exclusive to the main character
	# you can apply it to any character.
	# it is an asynchronous function.
	pass
	
func Play_Counter(character : String = ""):
	# This will instantiate the Counter Screen to display it
	# it is an asynchronous function.
	pass
	
func Play_Consent(main_char : String = "", secondary_char : String = ""):
	# This will instantiate the Consent Screen to display it
	# it is an asynchronous function.
	pass

# This will return the current location of your trial in Danganmake.
func get_trial_location() -> String:
	return ""
# This will return the amounts, name y path of your truthbullets
# Use get_truth_bullet_list() instead, this one only returns the last bullet
func get_truth_bullets() -> Dictionary:
	# example of how the game will give you the data
	#dic = {
		#base_name + "_path": txt_path,
		#base_name + "_Image": img_path,
		#"truth_bullets_names": {
			#"NAME_1",
			#"NAME_2",
			#"NAME_3",
			#"NAME_4",
		#}
		  #}
	return {}

## The Truth Bullets of the trial, sorted by file name.
## Inside the template it returns test data.
func get_truth_bullet_list() -> Array:
	return [
		{"name": "Test Bullet 1", "description": "Test description 1.", "image": "res://iconDanganmake.png"},
		{"name": "Test Bullet 2", "description": "Test description 2.", "image": "res://iconDanganmake.png"},
	]

# return current health in the health bar
func get_Health() -> float:
	return 0.0

func Show_Health_bar():
	pass
func Hide_Health_bar():
	pass


#region Dialogue / Balloon
# Inside the template these return the TestBench objects.
# Inside Danganmake they return the real ones.

# Template only, the TestBench fills these
var _test_balloon: Node = null
var _test_dialogue: Dictionary = {}
var _test_paused: bool = false

## Returns the dialogue balloon that Danganmake paused when your custom game started.
## You can hide it, move it, tween it or free it. Returns null if there is no balloon.
## If you free it, Danganmake creates a new one for the next dialogue line.
func get_current_balloon() -> Node:
	if is_instance_valid(_test_balloon):
		return _test_balloon
	return null

## Call it from the dialogue file where the part for your minigame ends:
## do GlobalStates.Dialogue_Finished()
## It emits dialogue_finished. In the TestBench you click the test balloon instead.
func Dialogue_Finished() -> void:
	dialogue_finished.emit()

## True while the main dialogue is paused waiting for your custom game.
## It turns false after Win(), when the dialogue goes on (useful in persistent HUDs).
func is_dialogue_paused() -> bool:
	return _test_paused and is_instance_valid(_test_balloon)

## Returns the last dialogue line shown before your custom game started.
## Keys: "character", "emotion", "text", "id" (id of the dialogue line)
func get_current_dialogue() -> Dictionary:
	return _test_dialogue.duplicate()
#endregion


#region Persistent state
# Template only
var _persistent_nodes: Array[Node] = []

## Returns every custom game still alive because it used persistent_state = true.
## Useful to talk with a HUD or an animation that you left running earlier.
func get_persistent_minigames() -> Array[Node]:
	for i in range(_persistent_nodes.size() - 1, -1, -1):
		if not is_instance_valid(_persistent_nodes[i]):
			_persistent_nodes.remove_at(i)
	return _persistent_nodes

## Returns a persistent custom game by its root node name (e.g "Minigame"), or null.
func get_persistent_minigame(node_name: String) -> Node:
	for node in get_persistent_minigames():
		if node.name == node_name.strip_edges():
			return node
	return null

## Frees a persistent custom game safely.
func remove_persistent_minigame(node_name: String) -> void:
	var node := get_persistent_minigame(node_name)
	if node != null:
		_persistent_nodes.erase(node)
		node.queue_free()

## Frees every persistent custom game.
## Danganmake does it by itself when the player leaves the trial.
func free_persistent_minigames() -> void:
	for node in get_persistent_minigames():
		node.queue_free()
	_persistent_nodes.clear()
#endregion


#region Pause
var _mouse_before_pause := Input.MOUSE_MODE_VISIBLE

## Pauses or resumes the game like the pause menu of Danganmake: it shows the mouse
## while paused and puts the old mouse mode back after.
## Only nodes with process_mode = PROCESS_MODE_ALWAYS keep running, your menu must use it.
## The music, SFX and voice pause too, see GlobalSound.set_audio_plays_while_paused()
func set_game_paused(paused: bool) -> void:
	if paused == get_tree().paused:
		return
	if paused:
		_mouse_before_pause = Input.mouse_mode
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = _mouse_before_pause
	get_tree().paused = paused
	pause_changed.emit(paused)

func is_game_paused() -> bool:
	return get_tree().paused
#endregion


#region Main menu, saves and test mode
# Template only, the TestBench fills these
var _test_bench: Node = null
var _test_mode: bool = false
var _test_calls: Array = []
var _test_save: Dictionary = {}

## Goes back to the main menu, or to the editor when the trial is being tested.
## In the TestBench it restarts the test.
func return_to_title() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	GlobalSound.Stop_Voice()
	GlobalSound.Stop_SFX()
	GlobalSound.Stop_MUSIC()
	free_persistent_minigames()
	get_tree().reload_current_scene()

## True while the trial is being tested from the editor.
## In the TestBench it is the simulate_test_mode option of the inspector.
func is_test_mode() -> bool:
	return _test_mode

## Saves the trial like the Save of the pause menu. False if no trial is running.
## In the TestBench it remembers the custom values and the inserts made so far.
func save_game() -> bool:
	_test_save = {"custom_values": _custom_values.duplicate(true), "calls": _test_calls.duplicate(true)}
	return true

## True if the trial has a save.
func has_save() -> bool:
	return not _test_save.is_empty()

## Loads the save like the Load of the pause menu. False if there is no save.
## It unpauses the game but doesn't emit pause_changed.
## In the TestBench it simulates closing the game and loading: the persistent minigames
## are freed and Resume_Minigame() is called on a new one.
func load_game() -> bool:
	if _test_save.is_empty():
		return false
	_custom_values = _test_save.custom_values.duplicate(true)
	_test_calls = _test_save.calls.duplicate(true)
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	free_persistent_minigames()
	if is_instance_valid(_test_bench):
		_test_bench.call("_resume_after_load")
	return true
#endregion


#region Input actions
var _claimed_actions: Dictionary = {}

## Takes an input action from Danganmake: when Danganmake would use it, it calls callback instead.
## For example claiming "menu" opens your menu instead of the pause menu (Esc / gamepad).
## Danganmake checks "menu" in the courtroom and the 2D / free roam scene, only while not paused.
## It is released by itself when the node that owns the callback is freed.
func claim_action(action: String, callback: Callable) -> void:
	_claimed_actions[action] = callback

func release_action(action: String) -> void:
	_claimed_actions.erase(action)

func is_action_claimed(action: String) -> bool:
	var callback: Callable = _claimed_actions.get(action, Callable())
	if callback.is_valid():
		return true
	_claimed_actions.erase(action)
	return false

# Template only, Danganmake uses its own: the TestBench calls it like the real scenes
func run_claimed_action(action: String) -> bool:
	if not is_action_claimed(action):
		return false
	_claimed_actions[action].call()
	return true
#endregion


#region Custom values
# Values stored in the save file of the trial, so your custom games
# can share data between them (scores, choices, unlocked things, etc).
# Only use simple types: bool, int, float, String, Vector2/3, Color, Array, Dictionary.
var _custom_values: Dictionary = {}

func set_custom_value(key: String, value: Variant) -> void:
	_custom_values[key.strip_edges()] = value

func get_custom_value(key: String, default_value: Variant = null) -> Variant:
	return _custom_values.get(key.strip_edges(), default_value)

func has_custom_value(key: String) -> bool:
	return _custom_values.has(key.strip_edges())

func erase_custom_value(key: String) -> void:
	_custom_values.erase(key.strip_edges())
#endregion


#region Trial assets
# All the dictionaries use the file name without extension as key
# and the absolute path of the file as value:
# { "Classroom": "C:/.../Trials/MyTrial/assets/bg/Classroom.png" }
# Inside the template they return empty dictionaries and the
# textures return a placeholder so you can test your code.

## Names of the custom focus created in the trial (Custom Focus folder).
## Use them with CharacterList.focus_CH_Custom() or CharacterScript.focus_CH_Custom()
func get_custom_focus_list() -> PackedStringArray:
	return PackedStringArray()

## Returns the path of a custom focus, ready to use in focus_CH_Custom(path, ...)
func get_custom_focus_path(focus_name: String) -> String:
	return ""

## Images of the Image folder (png, jpg, jpeg)
func get_images() -> Dictionary:
	return {}

## Loads an image of the Image folder as a texture. Returns null if it doesn't exist.
func get_image_texture(img_name: String) -> Texture2D:
	return _get_placeholder_texture()

## Backgrounds of the bg folder
func get_backgrounds() -> Dictionary:
	return {}

## Loads a background as a texture. Returns null if it doesn't exist.
func get_background_texture(bg_name: String) -> Texture2D:
	return _get_placeholder_texture()

## Name of the background currently shown in the 2D scene, "" if there is none.
func get_current_background() -> String:
	return ""

## Videos of the video folder (.ogv only)
func get_videos() -> Dictionary:
	return {}

## Loads a video so you can use it in your own VideoStreamPlayer.
func get_video_stream(video_name: String) -> VideoStream:
	return null

## Custom text boxes of the custom text box folder
func get_custom_balloons() -> Dictionary:
	return {}

## Absolute path of the trial assets folder, "" if no trial is loaded.
## Always build paths with path_join(), never with "/".
func get_trial_assets_path() -> String:
	return ""

func _get_placeholder_texture() -> Texture2D:
	if ResourceLoader.exists("res://iconDanganmake.png"):
		return load("res://iconDanganmake.png") as Texture2D
	return null
#endregion


#region Platform
## "windows", "linux", "macos", "android", "ios" or "web"
## Useful to show touch controls only on mobile.
func get_platform() -> String:
	if OS.has_feature("android"):
		return "android"
	if OS.has_feature("ios"):
		return "ios"
	if OS.has_feature("web"):
		return "web"
	if OS.has_feature("macos"):
		return "macos"
	if OS.has_feature("windows"):
		return "windows"
	return "linux"

func is_mobile() -> bool:
	return OS.has_feature("mobile")

func is_touch_available() -> bool:
	return DisplayServer.is_touchscreen_available()
#endregion
