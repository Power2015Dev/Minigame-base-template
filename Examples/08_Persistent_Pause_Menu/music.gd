extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# WARNING this function is not called like this in danganmake
	# just use the sounds of your sounds folder on your mod
	GlobalSound.Music_recursion_list("res://Examples/08_Persistent_Pause_Menu", GlobalSound.music)
	
	call_deferred("music_plays")

func music_plays():
	GlobalSound.Load_MUSIC("funnysong")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
