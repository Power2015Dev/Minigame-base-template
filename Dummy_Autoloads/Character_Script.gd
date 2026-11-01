extends Control

# This is the autoload that runs everything in the 2D/Free Roam scene

# if you use dialogue manager you need to delete this
class DialogueResource extends Resource:
	pass

# Signas for the game to comunicate with the main scene

signal World_Screen_Shake(Node_affected : String, intensity : float, time : float)
signal evidence_frame(Truth_Bullet: String)
signal remove_evidence_frame
signal evidence_showing_frame(Truth_Bullet: String)
signal remove_showing_evidence_frame

signal evidence_anim_finished
signal remove_evidence_anim_finished

signal evidence_showing_anim_finished
signal remove_showing_evidence_anim_finished

signal free_roam_scene_changed
signal free_roam_scene_changing(new_Scene : String)

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


func _ready() -> void:
	pass

# Only works when the Free Roam scene is active
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


func CH_EXPRESSION_3D(emocion: String):
	# Only works when the Free Roam scene is active
	pass

func Show_3D_Court():
	# Enable the courtroom (Deprecated)
	pass

func Hide_3D_Court():
	# Hide the courtroom (Deprecated)
	pass

func load_map():
	# Load the map 3D inserted the game already does this automatically when you enter the scene.
	pass

func Move_to_hostage_camera(alias : String):
	# Move the camera position to the alias you asigned
	pass 
	
func Activate_main_camera():
	# Disable the camera controlled by the CharacterBody (character) to give priority to the Move_to_hostage_camera.
	pass

func Deactive_main_camera():
	# Disable the camera controlled by the Move_to_hostage_camera to give priority to the CharacterBody (character).
	pass

func Character_body_top_Prority():
	# (legacy) This gives the camera of CharacterBody (Character)
	# some priority (though no more than a dialogue) 
	# and unlocks its movement.
	# 
	pass

func Character_body_low_Prority():
	# (legacy) This gives a lower priority to the camera 
	# of CharacterBody (Character)
	# and locks its movement.
	pass

#region Free roam
func _get_map() -> Node:
	# returns the live node of the map
	return null

func Set_Flag(flag: String):
	# set a flag in the free roam scene
	pass

## Pauses the main dialogue and places the player on the map (CharacterBody or
## point-and-click, depending on the scene). The main dialogue resumes once
## ALL flags are met, regardless of the order or the scene the player is in.
## goals: flags separated by commas, e.g: "talked:Main_Scene/Marker_0, visited:kitchen"
func Free_Roam_Until(goals: String):
	# is an asynchronous function
	# await StoryState.free_roam_completed
	pass

## Secondary dialogue (marker / On_Enter) layered over the main one.
## It resides in the autoload to persist through a Change_Scene event during the dialogue.
func Play_side_dialogue(resource: DialogueResource, title: String = "start", extra_states: Array = [], talk_key: String = "", sets_flag: String = ""):
	pass

## Plays <scene>/On_Enter.dialogue if it exists. Returns true if dialogue was present.
func Play_scene_enter() -> bool:
	# example of how it works
	# const SCENE_ENTER_DIALOGUE = "On_Enter"
	# var path = [current_trial_location].path_join("assets/Maps/scenes").path_join(GlobalEditor.in_scene).path_join(SCENE_ENTER_DIALOGUE + ".dialogue")
	# if not FileAccess.file_exists(path):
		# return false
	# var resource = DialogueManager.create_resource_from_text(file.get_as_text())
	# Play_side_dialogue(resource, "start")
	return true
#endregion

func Show_Scenario():
	# Show Custom 3D MAP
	pass

func Hide_Scenario():
	# Hide Custom 3D MAP
	pass

func CH_EXPRESSION(character_name: String, emotion_name: String):
	# Change the expression of the character in 
	# the 2D scene with a ghost delay effect 
	# Free Roam is not affected by the ghost delay effect
	pass

func CH_EXPRESSION_OLD(nombre_personaje_bruto: String, nombre_emocion_bruta: String):
	# Unlike the standard CH_EXPRESSION, 
	# this one has no ghost delay effect it is instantaneous.
	pass
	
func fadein():
	# asynchronous function that affects only the character node
	pass

func fadeout():
	# asynchronous function that affects only the character node
	pass


func Left_Slide(ch_name: String, emotion_name: String):
	# Moves the bg and the character to one side
	# to make movement effect.
	# it make the contrary slide (Slide_Right) 
	# when you reach the screen limit
	pass

func Right_Slide(nombre_personaje_bruto: String, nombre_emocion_bruta: String):
	# Moves the bg and the character to one side
	# to make movement effect.
	# it make the contrary slide (Slide_Left) 
	# when you reach the screen limit
	pass

# Only 3 node are affected, the bg, dialogue and Character
# also you can call all for all the nodes to be affected
func Screen_Shake(Node_affected : String, intensity : float, time : float):
	World_Screen_Shake.emit(Node_affected, intensity, time)

func Stop_Screen_Shake():
	# pretty self explanatory
	# this function is also called when you pass a dialogue
	pass


func Screen_Flash():
	pass
		
func Wait(seconds: float):
	pass
	
func Play_Video(video_name: String):
	# .ogv video only soported
	# check in the video folder
	pass
	
func Show_image(img_name : String):
	# png, jpg, jpeg only soported
	# check in the Image folder
	pass
	
func Remove_image():
	pass
		
func Custom_balloon(name : String):
	# check in the custom text box folder
	pass
	
func screen_fade_in(speed: float = 1.0, Color_Choice: Color = Color.BLACK):
	pass

func screen_fade_out(speed: float = 1.0, Color_Choice: Color = Color.BLACK):
	pass
	
func Obtain_Evidence(Truth_Bullet: String):
	# asynchronous function
	# await evidence_anim_finished
	pass
	
func Remove_Evidence():
	# asynchronous function
	# await remove_evidence_anim_finished
	pass

func Show_Evidence(Truth_Bullet: String):
	# asynchronous function
	# await evidence_showing_anim_finished
	pass
	
func Remove_Show_Evidence():
	# asynchronous function
	# await remove_showing_evidence_anim_finished
	pass

func Change_bg(bg_name: String):
	# check in the bg folder
	pass
	
## DEPRECATED
func Memory(memory: int):
	# play memory dialogue 
	pass


func Disable_Orange():
	pass
		
func Enable_Orange():
	pass

func _load_external_image(path: String) -> Texture2D:
	if path == "": return null
	if path.begins_with("res://") and ResourceLoader.exists(path):
		var res = load(path)
		if res is Texture2D: return res
	if FileAccess.file_exists(path):
		var img = Image.load_from_file(path)
		if img != null and not img.is_empty():
			return ImageTexture.create_from_image(img)
	return null

# It will return a dictionary containing the character's 2D information.
func Get_CH_Config(ch_name: String) -> Dictionary:
	# example of the game do it
	#return Autoload.CH_configs.get(ch_name, {
		#"2D_scale": 0.8, 
		#"2D_offset_x": -1200.0, 
		#"2D_offset_y": -540.0
	#})
	return {}

func Change_Scene(new_scene: String):
	free_roam_scene_changing.emit(new_scene)
	await free_roam_scene_changed


#region Free roam / 2D getters
# Inside the template these return null or empty values.

## The CharacterBody3D the player controls in the free roam scene, null in point-and-click.
func get_player_body() -> CharacterBody3D:
	return null

## The camera active in the free roam scene (player camera or hostage camera).
func get_active_camera_3d() -> Camera3D:
	return null

## Hostage cameras of the current map: { "alias": Transform3D }
## Use them to place your own camera or with Move_to_hostage_camera(alias)
func get_hostage_cameras() -> Dictionary:
	return {}

## Name of the free roam scene the player is in, "" outside free roam.
func get_current_scene_name() -> String:
	return ""

## Flags already set in the free roam (see Set_Flag and Free_Roam_Until)
func get_flags() -> PackedStringArray:
	return PackedStringArray()

func has_flag(flag: String) -> bool:
	return get_flags().has(flag.strip_edges())

## Name of the character and emotion shown in the 2D scene: { "character": "", "emotion": "" }
func get_current_character_2d() -> Dictionary:
	return {"character": "", "emotion": ""}

## The TextureRect of the 2D background, so you can tween it or change its material.
func get_background_node() -> TextureRect:
	return null

## The Sprite2D of the 2D character.
func get_character_node_2d() -> Sprite2D:
	return null
#endregion
