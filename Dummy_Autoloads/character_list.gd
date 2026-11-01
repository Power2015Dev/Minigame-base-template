extends Node

# This is the autoload that runs everything in the trial scene


#This dictionary contains all the characters who are on the scene 
# and their emotions.
#"Hajime Hinata": {
		#"Sprites": "filepath/Hajime Hinata",
		#"Idle": "filepath/Hajime Hinata/Idle.png",
		#"Thinking": "filepath/Hajime Hinata/Thinking.png",
	#},
	#"Monokuma": {
		#"Sprites": "characters/characters_sprites/Monokuma",
		#"sitting": "characters/characters_sprites/Monokuma/sitting.png",
		#"sitting_laugh": "filepath/Monokuma/sitting_laugh.png"
var character_in_scene : Dictionary = {}

# This dictionary contains the 3D node of each instantiated character.
var character_in_scene_active_3D: Dictionary = {}

signal request_custom_focus(path: String, ch_name: String, custom_data: Dictionary)
signal request_camera_focus(char_name: String, fov: int, speed: float)
signal request_camera_zoom_in_rotated(char_name: String, fov: int, duration: float, angle : float, Z_Pos : float, Y_Rot : float, speed : float)
signal request_camera_zoom_out_rotated(char_name: String, fov: int, duration: float, angle : float, Z_Pos : float, Y_Rot : float, speed : float)
signal request_camera_zoom_in(char_name: String, fov: int, duration: float, Z_Pos : float)
signal request_camera_zoom_out(char_name: String, fov: int, duration: float, Z_Pos : float)
signal request_camera_zoom_in_Top(char_name: String, fov: int, duration: float, Z_Pos : float)
signal request_slow_camera_L(char_name: String, fov: int)
signal request_slow_camera_R(char_name: String, fov: int)
signal request_camera_Down(char_name: String, fov: int, duration : float, speed: float, Z_Pos: float)
signal request_camera_Up(char_name: String, fov: int, duration : float, speed: float, Z_Pos: float)

signal FullScreen_afterimage
signal Orange_in
signal Orange_out

signal hide_courtroom
signal show_courtroom

func focus_CH_Custom(path: String, ch_name: String, custom_data: Dictionary = {}):
	request_custom_focus.emit(path, ch_name, custom_data)
func focus_CH(char_name: String, fov: int = 50, speed: float = 0.2): 
	request_camera_focus.emit(char_name, fov, speed)
func focus_CH_zoom_in_rotated(char_name: String, fov: int = 50, duration: float = 5.0, angle : float = -15.0, Z_Pos : float = 1.8, Y_Rot : float = 0, speed : float = 0.0): 
	request_camera_zoom_in_rotated.emit(char_name, fov, duration, angle, Z_Pos, Y_Rot, speed)
func focus_CH_zoom_out_rotated(char_name: String, fov: int = 50, duration: float = 5.0, angle : float = -15.0, Z_Pos : float = 1.8, Y_Rot : float = 0, speed : float = 0.0): 
	request_camera_zoom_out_rotated.emit(char_name, fov, duration, angle, Z_Pos, Y_Rot, speed)
func focus_CH_zoom_in(char_name: String, fov: int = 50, duration: float = 5.0, Z_Pos : float = 1.8): 
	request_camera_zoom_in.emit(char_name, fov, duration, Z_Pos)
func focus_CH_zoom_out(char_name: String, fov: int = 50, duration: float = 5.0, Z_Pos : float = 1.8): 
	request_camera_zoom_out.emit(char_name, fov, duration, Z_Pos)
func focus_CH_zoom_in_Top(char_name: String, fov: int = 50, duration: float = 5.0, Z_Pos : float = 1.8): 
	request_camera_zoom_in_Top.emit(char_name, fov, duration, Z_Pos)
func focus_CH_slow_camera_L(char_name: String, fov: int = 50): 
	request_slow_camera_L.emit(char_name, fov)
func focus_CH_slow_camera_R(char_name: String, fov: int = 50): 
	request_slow_camera_R.emit(char_name, fov)
func focus_CH_Down(char_name: String, fov: int = 50, duration: float = 5.0, speed: float = 0.2, Z_Pos: float = 1.8):
	request_camera_Down.emit(char_name, fov, duration, speed, Z_Pos)
func focus_CH_Up(char_name: String, fov: int = 50, duration: float = 5.0, speed: float = 0.2, Z_Pos: float = 1.8):
	request_camera_Up.emit(char_name, fov, duration, speed, Z_Pos)

func CH_EXPRESSION_3D(Character_name: String, expression: String):
	# This function checks the name you provided 
	# and searches for it among the 16 or plus nodes in the scene
	# if it finds the node it selects it to change the expression
	# to the specified emotion.
	pass


func Wait(time: float):
	await get_tree().create_timer(time).timeout
func Show_Orange_filter():
	Orange_in.emit()
func Hide_Orange_filter():
	Orange_out.emit()
func fade_in(time: float):
	# Asynchronous fade-in
	pass
func fade_out(time: float):
	# Asynchronous fade-out
	pass
func fullscreen_afterimage():
	FullScreen_afterimage.emit()

func Hide_Courtroom():
	hide_courtroom.emit()
func Show_Courtroom():
	show_courtroom.emit()

func Hide_all_in_Courtroom():
	hide_courtroom.emit()
	
	if character_in_scene_active_3D.is_empty():
		return
		
	# Los valores son los nodos, las claves son los nombres
	for character in character_in_scene_active_3D.values():
		if is_instance_valid(character):
			character.visible = false
func Show_all_in_Courtroom():
	show_courtroom.emit()
	
	if character_in_scene_active_3D.is_empty():
		return
		
	for character in character_in_scene_active_3D.values():
		if is_instance_valid(character):
			character.visible = true


#region 3D getters
# Inside the template these return the TestBench stage (placeholder characters,
# camera and environment) so you can test your 3D code without exporting the pck.
# Inside Danganmake they return the real courtroom nodes.

# Template only, the TestBench fills these
var _camera_3d: Camera3D = null
var _world_root: Node3D = null
var _courtroom: Node3D = null
var _world_environment: WorldEnvironment = null
var _character_sprites: Dictionary = {}
var _added_3d_nodes: Array[Node] = []
var _camera_locked: bool = false
var _saved_camera_transform: Transform3D
var _saved_camera_fov: float = 50.0

## The camera of the courtroom.
func get_camera_3d() -> Camera3D:
	return _camera_3d if is_instance_valid(_camera_3d) else null

## The root node of the 3D world. Add your own 3D nodes with add_3d_node().
func get_world_root() -> Node3D:
	return _world_root if is_instance_valid(_world_root) else null

## The courtroom model (the one hidden by Hide_Courtroom()).
func get_courtroom() -> Node3D:
	return _courtroom if is_instance_valid(_courtroom) else null

## The WorldEnvironment of the trial. Change its Environment with care,
## heavy effects (SDFGI, SSAO, SSR, volumetric fog) they come at a high performance cost
func get_world_environment() -> WorldEnvironment:
	return _world_environment if is_instance_valid(_world_environment) else null

## Names of the characters in the room (courtroom or free roam map).
func get_character_names() -> PackedStringArray:
	return PackedStringArray(get_characters_3d().keys())

## Emotions of a character: { "Idle": "path/Idle.png", "Thinking": "path/Thinking.png" }
## The "Sprites" key (the folder) is not included.
func get_character_emotions(ch_name: String) -> Dictionary:
	var data: Dictionary = character_in_scene.get(ch_name.strip_edges(), {})
	var emotions := data.duplicate()
	emotions.erase("Sprites")
	emotions.erase("id")
	return emotions

## The 3D node of a character (its podium position). Returns null if it isn't in the scene.
func get_character_3d(ch_name: String) -> Node3D:
	var node = character_in_scene_active_3D.get(ch_name.strip_edges())
	return node if is_instance_valid(node) else null

## Returns a copy of { "Character name": Node3D }
func get_characters_3d() -> Dictionary:
	var result := {}
	for ch_name in character_in_scene_active_3D:
		if is_instance_valid(character_in_scene_active_3D[ch_name]):
			result[ch_name] = character_in_scene_active_3D[ch_name]
	return result

## The Sprite3D of a character, the one CH_EXPRESSION_3D() changes.
func get_character_sprite_3d(ch_name: String) -> Sprite3D:
	var sprite = _character_sprites.get(ch_name.strip_edges())
	return sprite if is_instance_valid(sprite) else null

## Global position of a character, Vector3.ZERO if it isn't in the scene.
func get_character_position(ch_name: String) -> Vector3:
	var node := get_character_3d(ch_name)
	return node.global_position if node != null else Vector3.ZERO

## Adds your node to the 3D world. Every node added here is freed
## when you call free_3d_nodes() (minigame.gd does it in _exit_tree).
func add_3d_node(node: Node3D) -> void:
	var root := get_world_root()
	if node == null or root == null:
		push_warning("add_3d_node: there is no 3D world loaded")
		return
	root.add_child(node)
	_added_3d_nodes.append(node)

func free_3d_nodes() -> void:
	for node in _added_3d_nodes:
		if is_instance_valid(node):
			node.queue_free()
	_added_3d_nodes.clear()

## Takes control of the camera: the focus_CH functions stop moving it
## until you call release_camera_control(). Returns the camera.
func take_camera_control() -> Camera3D:
	var cam := get_camera_3d()
	if cam != null and not _camera_locked:
		_saved_camera_transform = cam.global_transform
		_saved_camera_fov = cam.fov
	_camera_locked = cam != null
	return cam

## Gives the camera back. If restore is true it goes back to where it was.
func release_camera_control(restore: bool = true) -> void:
	var cam := get_camera_3d()
	if cam != null and _camera_locked and restore:
		cam.global_transform = _saved_camera_transform
		cam.fov = _saved_camera_fov
	_camera_locked = false

func is_camera_locked() -> bool:
	return _camera_locked

## Converts a screen position (mouse, touch) into a point of the 3D world.
## It needs collisions: your own nodes or maps that have them. Returns null if nothing is hit.
func screen_to_world(screen_pos: Vector2, max_distance: float = 100.0) -> Variant:
	var cam := get_camera_3d()
	if cam == null:
		return null
	var from := cam.project_ray_origin(screen_pos)
	var to := from + cam.project_ray_normal(screen_pos) * max_distance
	var query := PhysicsRayQueryParameters3D.create(from, to)
	var hit := cam.get_world_3d().direct_space_state.intersect_ray(query)
	return hit.get("position") if not hit.is_empty() else null

## Returns the name of the character under a screen position (mouse, touch), "" if none.
## Characters don't have collisions inside Danganmake, so use this one for them
## instead of screen_to_world(). max_distance is in pixels.
func get_character_at_screen(screen_pos: Vector2, max_distance: float = 120.0) -> String:
	var cam := get_camera_3d()
	if cam == null:
		return ""
	var best := ""
	var best_dist := max_distance
	var characters := get_characters_3d()
	for ch_name in characters:
		var sprite := get_character_sprite_3d(ch_name)
		var point: Vector3 = sprite.global_position if sprite else characters[ch_name].global_position
		if cam.is_position_behind(point):
			continue
		var dist := cam.unproject_position(point).distance_to(screen_pos)
		if dist < best_dist:
			best_dist = dist
			best = ch_name
	return best

# Template only, called by the TestBench
func _register_test_stage(camera: Camera3D, root: Node3D, courtroom: Node3D, environment: WorldEnvironment, characters: Dictionary, sprites: Dictionary) -> void:
	_camera_3d = camera
	_world_root = root
	_courtroom = courtroom
	_world_environment = environment
	character_in_scene_active_3D = characters
	_character_sprites = sprites
	for ch_name in characters:
		if not character_in_scene.has(ch_name):
			character_in_scene[ch_name] = {"Sprites": "", "Idle": ""}
#endregion
