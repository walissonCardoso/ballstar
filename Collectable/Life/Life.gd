extends Area2D

var never_caught = true

func _ready():
	$Caught.volume_db = Global.get_effects_db()
	add_to_group("EXTRA_LIFE")
	$AnimationPlayer.play("glow")

func _on_Life_body_entered(player):
	if player.get_name() == "Player" and never_caught:
		never_caught = false
		Global.inc_life()
		player.update_lives_counter()
		$Caught.play()
		$AnimationPlayer.play("disapear")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "disapear":
		queue_free()
