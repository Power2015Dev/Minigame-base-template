extends "res://RenameToYourMinigame/minigame.gd"

# Example 4: modifying sprites, the environment, and the room, and returning everything to its original state

const TARGET: String = "Character_01"

@onready var info: Label = $Info

var original_background: Color

func Start_Minigame(_param: Dictionary):
	CharacterList.focus_CH(TARGET, 40, 0.3)
	await CharacterList.Wait(0.5)

	var target_sprite := CharacterList.get_character_sprite_3d(TARGET)
	var env_node := CharacterList.get_world_environment()

	info.text = "Everyone fades except %s" % TARGET
	var tween := create_tween().set_parallel(true)
	for ch_name in CharacterList.get_character_names():
		var sprite := CharacterList.get_character_sprite_3d(ch_name)
		if sprite and sprite != target_sprite:
			tween.tween_property(sprite, "modulate:a", 0.15, 0.5)
	# Bg color
	if env_node and env_node.environment:
		original_background = env_node.environment.background_color
		tween.tween_property(env_node.environment, "background_color", Color(0.35, 0.0, 0.05), 0.5)
	await tween.finished

	info.text = "%s shakes" % TARGET
	if target_sprite:
		var base_scale := target_sprite.scale
		var base_pos := target_sprite.position
		await create_tween().tween_property(target_sprite, "scale", base_scale * 1.3, 0.3).finished
		var shake := create_tween()
		for i in 8:
			shake.tween_property(target_sprite, "position", base_pos + Vector3(randf_range(-0.08, 0.08), randf_range(-0.05, 0.05), 0.0), 0.04)
		shake.tween_property(target_sprite, "position", base_pos, 0.04)
		shake.tween_property(target_sprite, "scale", base_scale, 0.3)
		await shake.finished

	# hide the courtroom
	info.text = "Courtroom hidden"
	CharacterList.Hide_Courtroom()
	await CharacterList.Wait(1.0)
	CharacterList.Show_Courtroom()

	info.text = "Restoring"
	var restore := create_tween().set_parallel(true)
	for ch_name in CharacterList.get_character_names():
		var sprite := CharacterList.get_character_sprite_3d(ch_name)
		if sprite:
			restore.tween_property(sprite, "modulate:a", 1.0, 0.5)
	if env_node and env_node.environment:
		restore.tween_property(env_node.environment, "background_color", original_background, 0.5)
	await restore.finished
	Win()
