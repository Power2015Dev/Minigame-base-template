@tool
extends EditorScript

# Gives new UIDs to your minigame folder so two minigames made from a
# copied folder don't collide inside Danganmake.
# Dummy_Autoloads and the root files are not touched, so the autoloads stay.
#
# How to use:
# 1. Close every scene of your minigame folder.
# 2. Open this script in the Script editor and press File > Run (Ctrl+Shift+X).
# 3. Project > Reload Current Project.

const IGNORED_FOLDERS: PackedStringArray = [".godot", ".git", "Dummy_Autoloads", "addons"]

var _header_regex := RegEx.create_from_string("^\\[(gd_scene|gd_resource)[^\\]]*?\\suid=\"(uid://[a-z0-9]+)\"")
var _uid_attr_regex := RegEx.create_from_string("uid=\"(uid://[a-z0-9]+)\"")
var _import_regex := RegEx.create_from_string("(?m)^uid=\"(uid://[a-z0-9]+)\"")

func _run() -> void:
	var folders := _get_minigame_folders()
	if folders.is_empty():
		push_warning("Regenerate UIDs: no minigame folder was found")
		return

	# if a scene is open the editor would save the old uid
	for scene_path in EditorInterface.get_open_scenes():
		for folder in folders:
			if scene_path.begins_with(folder + "/"):
				push_error("Regenerate UIDs: close '%s' first and run it again" % scene_path)
				return

	var files: PackedStringArray = []
	for folder in folders:
		_collect_files(folder, files)

	# new uid for every file
	var uid_map := {}
	for path in files:
		if path.ends_with(".tscn") or path.ends_with(".tres"):
			_renew_header_uid(path, uid_map)
		elif path.ends_with(".uid") or path.ends_with(".import"):
			_renew_side_file_uid(path, uid_map)

	# update the refs that has been broken before
	var updated_refs := 0
	for path in files:
		if path.ends_with(".tscn") or path.ends_with(".tres"):
			if _update_references(path, uid_map):
				updated_refs += 1

	EditorInterface.get_resource_filesystem().scan()
	print("Regenerate UIDs: %d UIDs renewed in %s, %d files with updated references." % [uid_map.size(), ", ".join(folders), updated_refs])
	print("Regenerate UIDs: now use Project > Reload Current Project.")

func _get_minigame_folders() -> PackedStringArray:
	var result: PackedStringArray = []
	var dir := DirAccess.open("res://")
	if dir == null:
		return result
	for folder in dir.get_directories():
		if not IGNORED_FOLDERS.has(folder):
			result.append("res://".path_join(folder))
	return result

func _collect_files(folder: String, files: PackedStringArray) -> void:
	var dir := DirAccess.open(folder)
	if dir == null:
		return
	for file in dir.get_files():
		files.append(folder.path_join(file))
	for sub in dir.get_directories():
		_collect_files(folder.path_join(sub), files)

func _new_uid_text() -> String:
	return ResourceUID.id_to_text(ResourceUID.create_id())

func _renew_header_uid(path: String, uid_map: Dictionary) -> void:
	var text := FileAccess.get_file_as_string(path)
	var lines := text.split("\n")
	if lines.is_empty():
		return
	var found := _header_regex.search(lines[0])
	if found == null:
		return
	var old_uid := found.get_string(2)
	var new_uid := _new_uid_text()
	uid_map[old_uid] = new_uid
	lines[0] = lines[0].replace(old_uid, new_uid)
	_save_text(path, "\n".join(lines))

#.uid of scripts/shaders and .import of textures, audio, models
func _renew_side_file_uid(path: String, uid_map: Dictionary) -> void:
	var text := FileAccess.get_file_as_string(path)
	var old_uid := ""
	if path.ends_with(".uid"):
		old_uid = text.strip_edges()
		if not old_uid.begins_with("uid://"):
			return
	else:
		var found := _import_regex.search(text)
		if found == null:
			return
		old_uid = found.get_string(1)
	var new_uid := _new_uid_text()
	uid_map[old_uid] = new_uid
	_save_text(path, text.replace(old_uid, new_uid))

# this only change [ext_resource ...], never the content of the properties
func _update_references(path: String, uid_map: Dictionary) -> bool:
	var lines := FileAccess.get_file_as_string(path).split("\n")
	var changed := false
	for i in lines.size():
		if not lines[i].begins_with("[ext_resource"):
			continue
		var found := _uid_attr_regex.search(lines[i])
		if found != null and uid_map.has(found.get_string(1)):
			lines[i] = lines[i].replace(found.get_string(1), uid_map[found.get_string(1)])
			changed = true
	if changed:
		_save_text(path, "\n".join(lines))
	return changed

func _save_text(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Regenerate UIDs: can't write '%s'" % path)
		return
	file.store_string(text)
	file.close()
