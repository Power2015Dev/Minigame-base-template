extends Node3D

# Test scene that loads your custom game the same way Danganmake does:
# first the Editor_Interface, then Start_Minigame() with its data.
# The 3D stage is only a placeholder, the camera shots are approximate.
# This folder is excluded when you export the pck.

@export var minigame_scene: PackedScene
@export var editor_interface_scene: PackedScene
## Skip the Editor_Interface and start with test_params directly
@export var skip_editor_interface: bool = false
@export var test_params: Dictionary = {}
## Fake dialogue balloon, to test get_current_balloon()
@export var show_test_balloon: bool = true
@export var label_tree: Label

# To add, remove or rename characters, edit the children of "Characters".
# Each one is an instance of test_character.tscn, its node name is the character name.

const EYE_HEIGHT: float = 1.5
const IGNORED_FOLDERS: PackedStringArray = [".godot", "Dummy_Autoloads", "addons"]

@onready var camera: Camera3D = $Camera3D
@onready var courtroom: Node3D = $Courtroom
@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var characters_root: Node3D = $Characters
@onready var balloon: CanvasLayer = $TestBalloon
@onready var balloon_label: Label = $TestBalloon/Panel/Label
@onready var balloon_panel: Panel = $TestBalloon/Panel
@onready var ui_layer: CanvasLayer = $UILayer

var editor_ui: Control
var minigame: Node
var camera_tween: Tween
var waiting_dialogue: bool = false

func _ready() -> void:
	_find_scenes_if_missing()
	_register_stage()
	_register_balloon()
	_connect_signals()

	if skip_editor_interface:
		_start_minigame(test_params)
	else:
		_show_editor_interface()

#region Stage
# scene nodes goes to autoload
func _register_stage() -> void:
	var characters := {}
	var sprites := {}
	for child in characters_root.get_children():
		if not child is Node3D:
			continue
		var ch_name := String(child.name)
		characters[ch_name] = child
		var sprite := child.get_node_or_null("Sprite3D") as Sprite3D
		if sprite != null:
			sprites[ch_name] = sprite
	CharacterList._register_test_stage(camera, self, courtroom, world_environment, characters, sprites)

func _register_balloon() -> void:
	# Hidden until the minigame calls Win(), like the paused balloon
	balloon.visible = false
	if not show_test_balloon:
		return
	balloon_panel.gui_input.connect(_on_balloon_input)
	GlobalStates._test_balloon = balloon
	GlobalStates._test_dialogue = {
		"character": "Character_01",
		"emotion": "Idle",
		"text": balloon_label.text,
		"id": "",
	}
#endregion

#region Minigame flow
func _show_editor_interface() -> void:
	if editor_interface_scene == null:
		push_warning("TestBench: Editor_Interface.tscn was not found, starting with test_params")
		_start_minigame(test_params)
		return

	if not is_instance_valid(editor_ui):
		editor_ui = editor_interface_scene.instantiate() as Control
		ui_layer.add_child(editor_ui)
		if editor_ui.has_signal("insert_pressed"):
			editor_ui.connect("insert_pressed", _on_insert_pressed)
		if editor_ui.has_signal("cancel_pressed"):
			editor_ui.connect("cancel_pressed", _on_cancel_pressed)
	editor_ui.visible = true

func _on_insert_pressed() -> void:
	var data: Dictionary = {}
	if editor_ui.has_method("get_data"):
		data = editor_ui.call("get_data")
	print("[TestBench] get_data() returned: ", data)
	# Simula guardar y volver a editar el evento
	if editor_ui.has_method("set_data"):
		editor_ui.call("set_data", data)
	editor_ui.visible = false
	_start_minigame(data)

func _on_cancel_pressed() -> void:
	print("[TestBench] Cancel pressed, closing the test")
	get_tree().quit()

func _start_minigame(data: Dictionary) -> void:
	if minigame_scene == null:
		push_error("TestBench: Minigame.tscn was not found, set it in the TestBench inspector")
		return
	if is_instance_valid(minigame) and not _is_persistent(minigame):
		minigame.queue_free()
	_set_balloon_paused(true)
	minigame = minigame_scene.instantiate()
	add_child(minigame)
	if minigame.has_method("Start_Minigame"):
		minigame.call("Start_Minigame", data)
	else:
		push_warning("TestBench: your minigame doesn't have Start_Minigame(param)")

func _on_player_won() -> void:
	# Danganmake ignores Player_won when no minigame is waiting for it
	if not is_instance_valid(minigame):
		return
	print("[TestBench] Player_won emitted")
	_finish_minigame()

func _on_player_lose() -> void:
	if not is_instance_valid(minigame):
		return
	print("[TestBench] Player_lose emitted")
	_finish_minigame()

func _on_hurt(damage: float) -> void:
	print("[TestBench] Hurt emitted, damage: ", damage)

func _finish_minigame() -> void:
	_set_balloon_paused(false)
	if is_instance_valid(minigame):
		if _is_persistent(minigame):
			GlobalStates._persistent_nodes.append(minigame)
		else:
			label_tree.text = "Minigame has exited the tree"
			label_tree.add_theme_color_override("font_color", Color.RED)
			minigame.queue_free()
	minigame = null
	# The dialogue goes on: wait until the test dialogue is finished
	if show_test_balloon:
		await GlobalStates.dialogue_finished
		label_tree.text = "Alive in the tree"
		label_tree.add_theme_color_override("font_color", Color.WHITE)
	else:
		await get_tree().create_timer(1.0).timeout
		GlobalStates.Dialogue_Finished()
	await get_tree().create_timer(0.5).timeout
	if not skip_editor_interface:
		_show_editor_interface()

# Like Danganmake: the balloon is hidden and frozen while the minigame runs
func _set_balloon_paused(paused: bool) -> void:
	GlobalStates._test_paused = paused
	if paused:
		GlobalStates.dialogue_paused.emit()
	else:
		GlobalStates.dialogue_resumed.emit()
	if not show_test_balloon:
		return
	balloon.visible = not paused
	balloon.process_mode = Node.PROCESS_MODE_DISABLED if paused else Node.PROCESS_MODE_INHERIT
	waiting_dialogue = not paused
	if not paused:
		balloon_label.text = "Character_01: Test dialogue after your minigame. Click here (or press Enter) to finish it."

# Clicking the test balloon simulates finishing the dialogue
func _on_balloon_input(event: InputEvent) -> void:
	var click := event as InputEventMouseButton
	if click and click.pressed and click.button_index == MOUSE_BUTTON_LEFT:
		_end_test_dialogue()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_end_test_dialogue()

func _end_test_dialogue() -> void:
	if not waiting_dialogue:
		return
	waiting_dialogue = false
	balloon.visible = false
	print("[TestBench] Test dialogue finished")
	GlobalStates.Dialogue_Finished()

func _is_persistent(node: Node) -> bool:
	return bool(node.get("persistent_state")) if "persistent_state" in node else false
#endregion

#region Signals of the autoloads
func _connect_signals() -> void:
	GlobalStates.Player_won.connect(_on_player_won)
	GlobalStates.Player_lose.connect(_on_player_lose)
	GlobalStates.Hurt.connect(_on_hurt)

	CharacterList.hide_courtroom.connect(func() -> void: courtroom.visible = false)
	CharacterList.show_courtroom.connect(func() -> void: courtroom.visible = true)
	CharacterList.Orange_in.connect(func() -> void: print("[TestBench] Orange filter in (only visible in Danganmake)"))
	CharacterList.Orange_out.connect(func() -> void: print("[TestBench] Orange filter out"))
	CharacterList.FullScreen_afterimage.connect(func() -> void: print("[TestBench] Afterimage (only visible in Danganmake)"))
	CharacterList.request_custom_focus.connect(_on_custom_focus)

	# camera approaches
	CharacterList.request_camera_focus.connect(func(ch: String, fov: int, speed: float) -> void:
		_shot(ch, fov, 2.4, 2.4, 0.0, maxf(speed, 0.01)))
	CharacterList.request_camera_zoom_in.connect(func(ch: String, fov: int, duration: float, z_pos: float) -> void:
		_shot(ch, fov, z_pos + 1.5, z_pos, 0.0, duration))
	CharacterList.request_camera_zoom_out.connect(func(ch: String, fov: int, duration: float, z_pos: float) -> void:
		_shot(ch, fov, z_pos, z_pos + 1.5, 0.0, duration))
	CharacterList.request_camera_zoom_in_rotated.connect(func(ch: String, fov: int, duration: float, angle: float, z_pos: float, y_rot: float, _speed: float) -> void:
		_shot(ch, fov, z_pos + 1.5, z_pos, 0.0, duration, angle, y_rot))
	CharacterList.request_camera_zoom_out_rotated.connect(func(ch: String, fov: int, duration: float, angle: float, z_pos: float, y_rot: float, _speed: float) -> void:
		_shot(ch, fov, z_pos, z_pos + 1.5, 0.0, duration, angle, y_rot))
	CharacterList.request_camera_zoom_in_Top.connect(func(ch: String, fov: int, duration: float, z_pos: float) -> void:
		_shot(ch, fov, z_pos + 1.5, z_pos, 1.2, duration))
	CharacterList.request_slow_camera_L.connect(func(ch: String, fov: int) -> void:
		_shot(ch, fov, 2.4, 2.4, 0.0, 4.0, 0.0, 0.0, -0.6))
	CharacterList.request_slow_camera_R.connect(func(ch: String, fov: int) -> void:
		_shot(ch, fov, 2.4, 2.4, 0.0, 4.0, 0.0, 0.0, 0.6))
	CharacterList.request_camera_Down.connect(func(ch: String, fov: int, duration: float, _speed: float, z_pos: float) -> void:
		_shot(ch, fov, z_pos, z_pos, 0.8, duration, 0.0, 0.0, 0.0, -0.8))
	CharacterList.request_camera_Up.connect(func(ch: String, fov: int, duration: float, _speed: float, z_pos: float) -> void:
		_shot(ch, fov, z_pos, z_pos, -0.8, duration, 0.0, 0.0, 0.0, 0.8))

func _on_custom_focus(path: String, ch_name: String, _custom_data: Dictionary) -> void:
	print("[TestBench] Custom focus '%s' on %s (only previewed inside Danganmake)" % [path, ch_name])
	_shot(ch_name, 50, 2.4, 2.4, 0.0, 0.2)

# it moves the camera to one direction to another
func _shot(ch_name: String, fov: float, from_dist: float, to_dist: float, height: float, duration: float,
		roll: float = 0.0, side_angle: float = 0.0, side_move: float = 0.0, height_move: float = 0.0) -> void:
	if CharacterList.is_camera_locked():
		return
	var target_node := CharacterList.get_character_3d(ch_name)
	if target_node == null:
		push_warning("TestBench: character '%s' is not in the scene" % ch_name)
		return

	var target := target_node.global_position + Vector3.UP * EYE_HEIGHT
	var forward := -target_node.global_transform.basis.z
	forward.y = 0.0
	forward = forward.normalized().rotated(Vector3.UP, deg_to_rad(side_angle))
	var side := forward.cross(Vector3.UP)

	var start := _shot_transform(target, forward, side, from_dist, height, -side_move * 0.5, -height_move * 0.5, roll)
	var end := _shot_transform(target, forward, side, to_dist, height, side_move * 0.5, height_move * 0.5, roll)

	if camera_tween and camera_tween.is_valid():
		camera_tween.kill()
	camera.global_transform = start
	camera_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE)
	camera_tween.tween_property(camera, "global_transform", end, maxf(duration, 0.01))
	camera_tween.tween_property(camera, "fov", fov, minf(duration, 0.3))

func _shot_transform(target: Vector3, forward: Vector3, side: Vector3, dist: float, height: float,
		side_offset: float, height_offset: float, roll: float) -> Transform3D:
	var pos := target + forward * dist + Vector3.UP * (height + height_offset) + side * side_offset
	var look := target + side * side_offset
	var t := Transform3D.IDENTITY.translated(pos).looking_at(look, Vector3.UP)
	if roll != 0.0:
		t.basis = t.basis.rotated(t.basis.z.normalized(), deg_to_rad(roll))
	return t
#endregion

# if the references are missing it will search for it lol
func _find_scenes_if_missing() -> void:
	if minigame_scene != null and editor_interface_scene != null:
		return
	var dir := DirAccess.open("res://")
	if dir == null:
		return
	for folder in dir.get_directories():
		if IGNORED_FOLDERS.has(folder):
			continue
		var base := "res://".path_join(folder)
		if minigame_scene == null and ResourceLoader.exists(base.path_join("Minigame.tscn")):
			minigame_scene = load(base.path_join("Minigame.tscn")) as PackedScene
		if editor_interface_scene == null and ResourceLoader.exists(base.path_join("Editor_Interface.tscn")):
			editor_interface_scene = load(base.path_join("Editor_Interface.tscn")) as PackedScene
