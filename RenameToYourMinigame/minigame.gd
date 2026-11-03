extends CanvasLayer

# HERE YOU CAN START CREATING YOUR MINIGAME
# WARNING: DO NOT USE OPERATING SYSTEM FUNCTIONS HARMFUL OR HTTP REQUESTS.

var input_Keys : Array = []


var persistent_state : bool = false

func _ready() -> void:
	# You can add your own input maps here.
	# Custom_key("move_forwards", KEY_W)
	# Custom_Mouse_key("shoot", MOUSE_BUTTON_LEFT)
	
	# if you make persistent_state = true
	# it won't destroy the scene after you emit the Player_won signal
	# useful for HUD things that you want to make it stay 
	pass

func Start_Minigame(param : Dictionary):
	# Don't declare start_minigame() in _ready 
	# unless you are testing the minigame itself.
	# Press F5 to test it with the TestBench, it calls this function
	# with the data of your Editor_Interface, like Danganmake does.
	#
	# Some examples of what you can get:
	# var balloon := GlobalStates.get_current_balloon()
	# if balloon: balloon.set("visible", false)
	#
	# var cam := CharacterList.take_camera_control()
	# var target := CharacterList.get_character_position("Character_01")
	# create_tween().tween_property(cam, "fov", 30.0, 1.0)
	#
	# var sprite := CharacterList.get_character_sprite_3d("Character_01")
	# if sprite: create_tween().tween_property(sprite, "modulate:a", 0.0, 0.5)
	#
	# var cube := MeshInstance3D.new()
	# cube.mesh = BoxMesh.new()
	# CharacterList.add_3d_node(cube)
	pass

# Optional: to bring a persistent minigame back after loading a save
# The example testbenches inherit this script be aware of that.
#
# func Resume_Minigame(info: Dictionary) -> bool:
# 	var state = GlobalStates.get_custom_value("my_state", null)
# 	if state == null and not info.calls.is_empty():
# 		state = info.calls.back()
# 	if state == null:
# 		return false
# 	persistent_state = true
# 	return true

func Win():
	# deleting the inputs you declared after win
	for actions in input_Keys:
		if InputMap.has_action(actions):
			InputMap.erase_action(actions)
	
	GlobalStates.Player_won.emit()
func Lose():
	GlobalStates.Player_lose.emit()

## Add a key or a command you can even include controller commands. 
func Custom_key(action: String, key: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
		var evento = InputEventKey.new()
		evento.keycode = key
		input_Keys.append(action)
		InputMap.action_add_event(action, evento)

## Add a mouse key (like left click or right click etc.)
func Custom_Mouse_key(action : String, MouseEvent: MouseButton) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
		var evento = InputEventMouseButton.new()
		evento.button_index = MouseEvent
		input_Keys.append(action)
		InputMap.action_add_event(action, evento)


## This executes when the minigame is destroyed.
func _exit_tree() -> void:
	# free the 3D nodes and the camera returns back
	CharacterList.free_3d_nodes()
	if CharacterList.is_camera_locked():
		CharacterList.release_camera_control()
	# free the keys and mouse key action
	for action in input_Keys:
		if InputMap.has_action(action):
			InputMap.erase_action(action)
	input_Keys.clear()
