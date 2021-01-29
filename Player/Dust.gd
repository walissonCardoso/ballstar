extends Sprite

func _ready():
	$Dust.play("dust")

func _on_Dust_animation_finished(_anim_name):
	queue_free()
