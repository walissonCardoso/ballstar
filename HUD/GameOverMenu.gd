extends ColorRect

func _ready():
	pass

func _on_Animation_animation_finished(anim_name):
	if anim_name == "fade in":
		$Menu.grab_focus()

func _on_Menu_pressed():
	get_tree().change_scene("res://Menu/Menu.tscn")
