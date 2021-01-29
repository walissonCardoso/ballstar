extends Area2D

var never_caught = true

func _ready():
	$Caught.volume_db = Global.get_effects_db()
	add_to_group("FLOWER")

func _on_Flower_body_entered(body):
	if body.get_name() == "Player" and never_caught:
		never_caught = false
		get_parent().get_parent().inc_flowers_caught()
		$Caught.play()
		$AnimationPlayer.play("disapear")

func _on_animation_finished(_anim_name):
	queue_free()
