extends Node

onready var anim_player = get_node("AnimationPlayer")
var slide_velocity = 50

func _ready():
	$Camera2D/Settings/FullScreen.pressed = Global.is_full_screen
	$Camera2D/Main/NewGame.grab_focus()
	
	if not Global.can_load():
		$Camera2D/Main/LoadGame.disabled = true
		
	set_volume()

func _process(delta):
	$Camera2D.position.x += delta * slide_velocity

func _on_NewGame_pressed():
	Global.start_level(0, 4)

func _on_Main_LoadGame_pressed():
	$Button.play()
	Global.load_game()

func _on_main_Settings_pressed():
	$Button.play()
	anim_player.play("main_exit")
	yield(anim_player, "animation_finished")
	anim_player.play_backwards("settings_exit")
	$Camera2D/Settings/Back.grab_focus()

func _on_Settings_MusicSlider_value_changed(new_volume):
	Global.music_volume = new_volume
	set_volume()

func _on_Settings_EffectSlider_value_changed(new_volume):
	Global.effects_volume = new_volume
	set_volume()
	$Confirm.play()

func _on_Settings_FullScreen_pressed():
	Global.is_full_screen = not Global.is_full_screen
	OS.window_fullscreen = Global.is_full_screen

func _on_Settings_Back_pressed():
	$Button.play()
	anim_player.play("settings_exit")
	yield(anim_player, "animation_finished")
	anim_player.play_backwards("main_exit")
	$Camera2D/Main/NewGame.grab_focus()

func _on_main_Quit_pressed():
	get_tree().quit()

func set_volume():
	$Music.volume_db = Global.get_music_db()
	$Confirm.volume_db = Global.get_effects_db()
	$Button.volume_db = Global.get_effects_db()
	
	$Camera2D/Settings/MusicSlider.value = Global.music_volume
	$Camera2D/Settings/EffectSlider.value = Global.effects_volume
