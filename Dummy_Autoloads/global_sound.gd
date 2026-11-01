extends Node

# WARNING
# Nothing you change here will affect the original game 
# I recommend not modifying any functions and using only what is provided.

# --- MENU OPTION VOLUME ---
var music_vol : int = 3
var sfx_vol : int = 3
var voice_vol : int = 3

var sfx: Dictionary = {} 
var music: Dictionary = {}
var voice: Dictionary = {}

# used in the Save file
var current_music_played : String = ""
var current_sfx_played : String = ""
var current_voice_played : String = ""

@onready var music_player = $MUSIC
@onready var voice_player = $voice
@onready var sfx_player = $SFX

signal music_changed

# sfx pool 
var pool_size: int = 15 
var audio_pool: Array = []

func _ready() -> void:
	# We cloned the pool so that multiple SFX could play simultaneously.
	for i in range(pool_size):
		var new_sfx = AudioStreamPlayer.new()
		new_sfx.bus = "SFX" 
		# LE AJUSTAMOS AL VOLUMEN ESTA COSA QUE ME ROMPE LOS OIDOS
		# Nota de power: NO LE VAMOS A BAJAR VOLUMEN IMBECIL
		# CON RAZON LOS SFX SE ESCUCHAN TAN BAJO
		new_sfx.volume_db = 5
		add_child(new_sfx)
		audio_pool.append(new_sfx)
		
	SFX_recursion_list("res://Minigame_SFX", sfx)
	Music_recursion_list("res://Minigame_Music", music)
	voice_recursion_list("res://Minigame_Voices", voice)

func Stop_SFX():
	current_sfx_played = ""
	for player in audio_pool:
		if player.playing:
			player.stop()

func Stop_Voice():
	current_voice_played = ""
	if voice_player.playing:
		voice_player.stop()
		
		
func Pitch_Voice(Pitch : float = 1.0):
	voice_player.pitch_scale = Pitch

# The game recursively accesses your mod folders 
# so place the sounds you're using inside the specific mod 
# where you're using sounds that is in the res.
func Load_SFX(Name : String):
	current_sfx_played = Name
	var stream : AudioStream = null
	
	if sfx.has(Name):
		stream = sfx[Name]

	if stream != null:
		# were searching for a empty pool for the player
		for player in audio_pool:
			if not player.playing:
				player.stream = stream
				player.play()
				return
	else:
		print("SFX was not found: ", Name)
			


# The game recursively accesses your mod folders 
# so place the music you're using inside the specific mod 
# where you're using music that is in the res.
func Load_MUSIC(Nombre : String):
	current_music_played = Nombre
	music_changed.emit()
	
	if music_player.playing:
		music_player.stop()
		
	var stream : AudioStream = null

	if music.has(Nombre):
		stream = music[Nombre]

	if stream != null:
		music_player.stream = stream
		# if the music ends, it will play again
		if not music_player.finished.is_connected(music_player.play):
			music_player.finished.connect(music_player.play)
		music_player.play()
	else:
		print("Music was not found", Nombre)

func Stop_MUSIC():
	current_music_played = ""
	if music_player.playing:
		music_player.stop()

func Stop_FadeOut_MUSIC(time : float = 0.9):
	current_music_played = ""
	if music_player.playing:
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", -80, time)
		await tween.finished
		music_player.volume_db = 0.0
		music_player.stop()

# The game recursively accesses your mod folders 
# so place the voices you're using inside the specific mod 
# where you're using voices that is in the res.
func Load_VOICE(Nombre : String):
	current_voice_played = Nombre
	if voice_player.playing:
		voice_player.stop()
		
	# The game has is own way to find the voices within the roster
	# Essentially, this means that if you call a voice
	# and you include a voice with that same name in your mod
	# the game will find it.
	if voice.has(Nombre): 
		voice_player.stream = voice[Nombre]
		voice_player.play()

func SFX_recursion_list(file_path : String, sfxlist : Dictionary):
	var sfx_directory = DirAccess.open(file_path)
	if sfx_directory:
		var files = sfx_directory.get_files()
		
		for sounds in files:
			var real_name = sounds
			
			if sounds.ends_with(".import"):
				real_name = sounds.replace(".import", "")
				
			if not real_name.ends_with(".mp3") and not real_name.ends_with(".ogg") and not real_name.ends_with(".wav"):
				continue
				
			var clean_name = real_name.get_basename()
			
			if not sfxlist.has(clean_name):
				var route = file_path.path_join(real_name)
				sfxlist[clean_name] = load(route)
				
		var subfile = sfx_directory.get_directories()
		for file in subfile:
			var new_file_path = file_path.path_join(file)
			SFX_recursion_list(new_file_path, sfxlist)
	else:
		print("folder Minigame_SFX was not found", file_path)
		
func Music_recursion_list(file_path : String, musiclist : Dictionary):
	var music_directory = DirAccess.open(file_path)
	if music_directory:
		var files = music_directory.get_files()
		
		for sounds in files:
			var real_name = sounds
			
			if sounds.ends_with(".import"):
				real_name = sounds.replace(".import", "")
				
			if not real_name.ends_with(".mp3") and not real_name.ends_with(".ogg") and not real_name.ends_with(".wav"):
				continue
				
			var clean_name = real_name.get_basename()
			
			if not musiclist.has(clean_name):
				var route = file_path.path_join(real_name)
				musiclist[clean_name] = load(route)
				
		var subfile = music_directory.get_directories()
		for file in subfile:
			var new_file_path = file_path.path_join(file)
			Music_recursion_list(new_file_path, musiclist)
	else:
		print("folder Minigame_Music was not found", file_path)
		
func voice_recursion_list(file_path : String, voicelist : Dictionary):
	var voice_directory = DirAccess.open(file_path)
	if voice_directory:
		var files = voice_directory.get_files()
		
		for sounds in files:
			var real_name = sounds
			if sounds.ends_with(".import"):
				real_name = sounds.replace(".import", "")
			if not real_name.ends_with(".mp3") and not real_name.ends_with(".ogg") and not real_name.ends_with(".wav"):
				continue
				
			var clean_name = real_name.get_basename() # Ej: "chiaki_ALTERED-1"
			
			if not voicelist.has(clean_name):
				var route = file_path.path_join(real_name)
				voicelist[clean_name] = load(route)
				
		var subfiles = voice_directory.get_directories()
		for file in subfiles:
			var new_file_path = file_path.path_join(file)
			voice_recursion_list(new_file_path, voicelist)
	else:
		print("folder Minigame_Voices was not found ", file_path)


#region Audio getters
# Names are the file name without extension.
# Inside Danganmake they include the sounds of the game, the trial and your mod.

func get_sfx_names() -> PackedStringArray:
	return PackedStringArray(sfx.keys())

func get_music_names() -> PackedStringArray:
	return PackedStringArray(music.keys())

func get_voice_names() -> PackedStringArray:
	return PackedStringArray(voice.keys())

## Returns the AudioStream so you can play it in your own AudioStreamPlayer/3D.
## Use the "SFX", "Music" or "Voice" bus so the player volume options apply.
func get_sfx_stream(sound_name: String) -> AudioStream:
	return sfx.get(sound_name.strip_edges()) as AudioStream

func get_music_stream(music_name: String) -> AudioStream:
	return music.get(music_name.strip_edges()) as AudioStream

func get_voice_stream(voice_name: String) -> AudioStream:
	return voice.get(voice_name.strip_edges()) as AudioStream

func get_current_music() -> String:
	return current_music_played

## Position of the music in seconds, useful to sync animations with the beat.
func get_music_position() -> float:
	if music_player.playing:
		## WARNING:
		## this ain't taking output latency into account
		## look for a tutorial on that.
		return music_player.get_playback_position()
	return 0.0
#endregion
