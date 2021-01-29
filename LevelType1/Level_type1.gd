extends TileMap

onready var flowers_caught = 0
onready var flowers_to_win = $Flowers.get_child_count()

signal number_flowers_changed(flowers_caught, flowers_to_win)

func _ready():
	emit_signal("number_flowers_changed", flowers_caught, flowers_to_win)
	$Background1/BackgroundMusic.volume_db = Global.get_music_db()

func inc_flowers_caught():
	flowers_caught += 1
	emit_signal("number_flowers_changed", flowers_caught, flowers_to_win)
	
	if flowers_caught == flowers_to_win:
		Global.next_level()
