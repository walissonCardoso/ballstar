extends ColorRect

func _input(_event):
	if Input.is_action_just_pressed("ui_pause"):
		get_tree().paused = true
		show()
	if Input.is_action_just_released("ui_pause"):
		$Continue.grab_focus()

func _on_Continue_button_down():
	get_tree().paused = false
	hide()

func _on_Menu_button_down():
	get_tree().paused = false
	var _sucess = get_tree().change_scene("res://Menu/Menu.tscn")
