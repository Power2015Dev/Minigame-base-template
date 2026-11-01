
# Minigame base template

This is a template you can use to inject your own DanganMake minigames.

Even though the template is designed with minigames in mind, you aren’t strictly limited to that your imagination allows you to create any events you’d like, whether for an intro or a trial.

## Testing without exporting (TestBench)

Press **F5**. The template opens `Dummy_Autoloads/TestBench/test_bench.tscn`, which loads your minigame the same way Danganmake does:

1. It shows your `Editor_Interface`.
2. When you press **Insert**, it calls `get_data()` and `set_data()`, then `Start_Minigame()` with that data.
3. When you emit `Player_won` or `Player_lose`, the minigame is freed (or kept alive if `persistent_state = true`).
4. A test dialogue appears, like the trial dialogue going on. Click it (or press Enter) to finish it: that emits `GlobalStates.dialogue_finished`, then the interface appears again.

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
| `GlobalStates` | `get_persistent_minigames()`, `get_persistent_minigame(name)`, `remove_persistent_minigame(name)` |
| `GlobalStates` | `set_custom_value(key, value)`, `get_custom_value(key, default)`, `has_custom_value(key)`, `erase_custom_value(key)` (saved with the trial) |
| `GlobalStates` | `get_custom_focus_list()`, `get_custom_focus_path(name)`, `get_images()`, `get_image_texture(name)`, `get_backgrounds()`, `get_background_texture(name)`, `get_current_background()`, `get_videos()`, `get_video_stream(name)`, `get_custom_balloons()`, `get_trial_assets_path()` |
| `GlobalStates` | `get_platform()`, `is_mobile()`, `is_touch_available()` |
| `CharacterList` | `get_camera_3d()`, `get_world_root()`, `get_courtroom()`, `get_world_environment()` |
| `CharacterList` | `get_character_names()`, `get_character_emotions(name)`, `get_character_3d(name)`, `get_characters_3d()`, `get_character_sprite_3d(name)`, `get_character_position(name)` |
| `CharacterList` | `add_3d_node(node)`, `free_3d_nodes()`, `take_camera_control()`, `release_camera_control(restore)`, `is_camera_locked()`, `get_character_at_screen(screen_pos)`, `screen_to_world(screen_pos)` (needs collisions) |
| `CharacterScript` | `get_player_body()`, `get_active_camera_3d()`, `get_hostage_cameras()`, `get_current_scene_name()`, `get_flags()`, `has_flag(flag)`, `get_current_character_2d()`, `get_background_node()`, `get_character_node_2d()` |
| `GlobalSound` | `get_sfx_names()`, `get_music_names()`, `get_voice_names()`, `get_sfx_stream(name)`, `get_music_stream(name)`, `get_voice_stream(name)`, `get_current_music()`, `get_music_position()` |

Nodes added with `CharacterList.add_3d_node()` are freed and the camera is given back automatically when your minigame leaves the tree (see `_exit_tree()` in `minigame.gd`).

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


    