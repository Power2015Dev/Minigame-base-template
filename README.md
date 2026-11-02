
# Minigame base template

This is a template you can use to inject your own DanganMake minigames.

Even though the template is designed with minigames in mind, you aren’t strictly limited to that your imagination allows you to create any events you’d like, whether for an intro or a trial.

## Testing without exporting (TestBench)

Press **F5**. The template opens `Dummy_Autoloads/TestBench/test_bench.tscn`, which loads your minigame the same way Danganmake does:

1. It shows your `Editor_Interface`.
2. When you press **Insert**, it calls `get_data()` and `set_data()`, then `Start_Minigame()` with that data.
3. When you emit `Player_won`, the minigame is freed (or kept alive if `persistent_state = true`). When you emit `Player_lose`, the TestBench tells you that you lost and restarts the minigame with the same data after 2 seconds. Inside Danganmake it is different: the game over dialogue appears, the health is restored and the same minigame keeps running without restarting, only `Player_won` ends it. Emit `Player_lose` once per defeat: each one opens a game over.
4. A test dialogue appears, like the trial dialogue going on (`GlobalStates.dialogue_line_shown` is emitted with it). Click it (or press Enter) to finish it: that emits `GlobalStates.dialogue_finished`, then the interface appears again.

Esc goes to whoever claimed `"menu"` with `GlobalStates.claim_action()`. `GlobalStates.save_game()` then `load_game()` simulates closing the game and loading a save: persistent minigames are freed and `Resume_Minigame()` is called on a new one with the inserts made so far.

Inside Danganmake the trial dialogue never stops by itself, so mark where the part of your minigame ends with `do GlobalStates.Dialogue_Finished()` in the dialogue file. Persistent minigames can connect to `dialogue_finished` to continue after that dialogue.

The scene also has a placeholder courtroom: 16 characters (`Character_01` to `Character_16`), a camera, a WorldEnvironment and a fake dialogue balloon. All the 3D getters (`CharacterList.get_camera_3d()`, `get_character_3d()`, `get_character_sprite_3d()`, `add_3d_node()`...) return these objects, so you can see your 3D changes right away. The `focus_CH` camera shots are only approximations of the real ones.

Everything is in the scene, so you can edit it visually: each character is an instance of `test_character.tscn` and its node name is the character name. Duplicate, rename, move or delete them inside `Characters`, change the sprite in `test_character.tscn`, or add your own meshes to test your 3D work. If you renamed your minigame folder outside Godot, the TestBench finds `Minigame.tscn` and `Editor_Interface.tscn` by itself.

The `TestBench` and `Tools` folders are excluded from the export.

## Duplicate UIDs

If you copied a minigame folder to make a new one, both minigames have the same UIDs and Danganmake may load the wrong one. To fix it:

1. Close the scenes of your minigame.
2. Open `Dummy_Autoloads/Tools/regenerate_minigame_uids.gd` in the Script editor and press **File > Run** (Ctrl+Shift+X).
3. **Project > Reload Current Project**.

It only changes the UIDs of your minigame folders, `Dummy_Autoloads` is never touched, so the autoloads keep working. Cloning the repository for each new minigame is still the cleanest way.

## Autoloads

The autoloads are registered by path (`res://Dummy_Autoloads/...`) in `project.godot`. Don't delete or re-add them from Project Settings, and don't delete the `.uid` files of `Dummy_Autoloads`.

## Template API (getters)

Inside the template these functions return the TestBench objects, empty values or a placeholder texture. Inside Danganmake they return the real data.

| Autoload | Functions |
| --- | --- |
| `GlobalStates` | `get_current_balloon()`, `is_dialogue_paused()`, `get_current_dialogue()`, signals `dialogue_paused`, `dialogue_resumed`, `dialogue_finished` |
| `GlobalStates` | signal `dialogue_line_shown(line)`, every line shown as `{"character", "text", "id", "voice"}` (`voice` is the voice line that played with it, `""` if none) |
| `GlobalStates` | `get_persistent_minigames()`, `get_persistent_minigame(name)`, `remove_persistent_minigame(name)`, `free_persistent_minigames()` |
| `GlobalStates` | `set_game_paused(paused)`, `is_game_paused()`, signal `pause_changed(paused)` |
| `GlobalStates` | `return_to_title()`, `is_test_mode()`, `save_game()`, `has_save()`, `load_game()` |
| `GlobalStates` | `claim_action(action, callback)`, `release_action(action)`, `is_action_claimed(action)` |
| `GlobalStates` | `get_truth_bullet_list()`, each one as `{"name", "description", "image"}` |
| `GlobalStates` | `set_custom_value(key, value)`, `get_custom_value(key, default)`, `has_custom_value(key)`, `erase_custom_value(key)` (saved with the trial) |
| `GlobalStates` | `get_custom_focus_list()`, `get_custom_focus_path(name)`, `get_images()`, `get_image_texture(name)`, `get_backgrounds()`, `get_background_texture(name)`, `get_current_background()`, `get_videos()`, `get_video_stream(name)`, `get_custom_balloons()`, `get_trial_assets_path()` |
| `GlobalStates` | `get_platform()`, `is_mobile()`, `is_touch_available()` |
| `CharacterList` | `get_camera_3d()`, `get_world_root()`, `get_courtroom()`, `get_world_environment()` |
| `CharacterList` | `get_character_names()`, `get_character_emotions(name)`, `get_character_3d(name)`, `get_characters_3d()`, `get_character_sprite_3d(name)`, `get_character_position(name)` |
| `CharacterList` | `add_3d_node(node)`, `free_3d_nodes()`, `take_camera_control()`, `release_camera_control(restore)`, `is_camera_locked()`, `get_character_at_screen(screen_pos)`, `screen_to_world(screen_pos)` (needs collisions) |
| `CharacterScript` | `get_player_body()`, `get_active_camera_3d()`, `get_hostage_cameras()`, `get_current_scene_name()`, `get_flags()`, `has_flag(flag)`, `get_current_character_2d()`, `get_background_node()`, `get_character_node_2d()` |
| `GlobalSound` | `get_sfx_names()`, `get_music_names()`, `get_voice_names()`, `get_sfx_stream(name)`, `get_music_stream(name)`, `get_voice_stream(name)`, `get_current_music()`, `get_music_position()` |
| `GlobalSound` | `get_volume(bus)`, `set_volume(bus, level)` (0 to 6, like Options), `set_audio_paused(bus, paused)`, `set_audio_plays_while_paused(bus, plays)`. `bus` is `"Music"`, `"SFX"` or `"Voice"` |

Nodes added with `CharacterList.add_3d_node()` are freed and the camera is given back automatically when your minigame leaves the tree (see `_exit_tree()` in `minigame.gd`).

## Coming back after loading a save

A persistent minigame only exists because its `Custom_Minigame` line ran. After loading a save (even after closing the game) or testing from a bookmark, the dialogue starts after that line. To come back, add this optional method to your main script:

```gdscript
func Resume_Minigame(info: Dictionary) -> bool:
	var state = GlobalStates.get_custom_value("my_state", null)
	if state == null and not info.calls.is_empty():
		state = info.calls.back() # rebuild from the last insert's params
	if state == null:
		return false # for example a save made before the first insert
	persistent_state = true
	_rebuild(state)
	return true
```

`info` holds `"from"` (`"save"` or `"test"`), `"line"` (the dialogue line the game starts at), `"name"` (the minigame's name in `metadata.json`) and `"calls"` (the params of every `Custom_Minigame` line of this minigame before the starting line, in order).

- Keep what you want back in a custom value (`set_custom_value`) every time it changes: it is saved with the trial.
- Return `true` to stay (it becomes a persistent minigame) or `false` to be freed.
- If the minigame is still alive (a save loaded without closing the game) it is called on that same node, so it can run on a minigame that is already set up. Otherwise a new node is added to the root of the tree, after its `_ready()`.
- Don't emit `Player_won` or `Player_lose` here: no dialogue line is waiting.
- The params in `info.calls` are read as JSON, so numbers come back as floats.

## Your own pause menu

1. Set `process_mode = PROCESS_MODE_ALWAYS` on your minigame, or it stops with the game.
2. Claim the action in `_ready()`: `GlobalStates.claim_action("menu", _open_my_menu)`.
3. Pause with `GlobalStates.set_game_paused(true)`. The music, SFX and voice pause too, unless you call `GlobalSound.set_audio_plays_while_paused("Music", true)` first.
4. Danganmake only checks the claim while the game is not paused, so close the menu from your own `_input()` and call `get_viewport().set_input_as_handled()`. Otherwise the same Esc reaches Danganmake after the game resumes and opens the menu again.

`Examples/08_Persistent_Pause_Menu` does all of this. Press Insert, then Esc.

## WARNING

Under no circumstances should you use operating system functions or HTTP requests.

Be aware of malware; if you suspect that a .pck file from a creator contains malware, DO NOT INSTALL IT, and report it on the official Discord.

We recommend that you upload your minigame as open-source code on GitHub to avoid such issues.

## Please be mindful of what you do. 




## Authors

- [@power2015](https://github.com/Power2015Dev)
- [@FreddysDark-on](https://github.com/FreddysDark-on)



## Documentation

Below, you'll find the documentation for more information on the functions and what you can use.

[Danganmake Documentation](https://power2015dev.github.io/Danganmake-Engine/content.html)


## Installation

Download Godot 4.7 from its official website.
[Godot](https://godotengine.org/es/)

Open Godot and import the project using the `project.godot` file.

This is a template you can work on once opened, but it is important not to change the current filters in the resources if the filters aren't applied, you need to go to the resources menu when exporting the project and enter this in the filters:

```bash
res://Dummy_Autoloads/*, res://Minigame_Music/*, res://Examples/*, res://Minigame_SFX/*, res://Minigame_Voices/*, 
res://default_bus_layout.tres, res://export_presets.cfg, res://icon.svg, res://iconDanganmake.png,
res://README.md, res://Danganmakeicon.ico
```

And when exporting, you need to make sure to export a `zip` or `pck` file.


    