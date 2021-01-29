extends Node

var player_lives = 0
var current_level = 0
var max_level = 6
var music_volume = 1
var effects_volume = 1
var is_full_screen = false

func _ready():
	OS.set_window_title("Ball Star")
	OS.set_window_maximized(true)

func decrease_life():
	player_lives -= 1
	save_game()
	
	if player_lives == 0:
		game_over()
	else:
		var _success = get_tree().reload_current_scene()

func inc_life():
	player_lives += 1

func start_level(level, lives):
	current_level = level
	player_lives = lives
	save_game()
	
	var path = "res://LevelType1/Level_" + str(current_level) + ".tscn"
	var _success = get_tree().change_scene(path)

func next_level():
	current_level += 1
	
	if current_level <= max_level:
		save_game()
		var path = "res://LevelType1/Level_" + str(current_level) + ".tscn"
		var _success = get_tree().change_scene(path)
	else:
		player_lives = 0
		save_game()
		var _success = get_tree().change_scene("res://HUD/VictoryMenu.tscn")

func game_over():
	var _success = get_tree().change_scene("res://HUD/GameOverMenu.tscn")

func save_game():
	var save_dict = {
		"player_lives": player_lives,
		"current_level": current_level
	}
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)
	save_game.store_line(to_json(save_dict))
	save_game.close()

func can_load():
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
		return false
		
	save_game.open("user://savegame.save", File.READ)
	var save_dict = parse_json(save_game.get_line())
	if save_dict.player_lives <= 0:
		return false
	return true

func load_game():
	var save_game = File.new()
	save_game.open("user://savegame.save", File.READ)
	var save_dict = parse_json(save_game.get_line())
	
	start_level(save_dict.current_level, save_dict.player_lives)

func get_music_db():
	if music_volume == 0: return -80
	else: return -(1 - music_volume) * 36 - 6

func get_effects_db():
	if effects_volume == 0: return -80
	else: return -(1 - effects_volume) * 36 - 6
