extends Node2D

func _ready():
	$Menu.grab_focus()
	$TrailSound.play()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fire":
		$FireWork.emitting = true
		$AnimationLight.play("light")
		$ExplosionSound.play()

func _on_AnimationLight_animation_finished(anim_name):
	if anim_name == "light":
		$AnimationFireWorks.play("fire")
		$TrailSound.play()

func _on_Menu_pressed():
	get_tree().change_scene("res://Menu/Menu.tscn")
