extends CanvasLayer

const LIFE_ICON = preload("res://HUD/LifeIcon.tscn")

func _ready():
	$Level.text = "Level %02d" % Global.current_level
	update_lives_counter()

func set_caught_flowers(flowers_caught, flowers_to_win):
	$Flowers.text = "Flowers: %d" % flowers_caught + " of %d" % flowers_to_win

func update_lives_counter():
	set_lives_counter(Global.player_lives)

func set_lives_counter(lives):
	for child in $Lives.get_children():
		child.queue_free()
	
	$Multiplier.text = str(lives) + ' x'
	if lives <= 3:
		$Multiplier.visible = false
		for life in lives:
			var life_icon = LIFE_ICON.instance()
			var icon_size = life_icon.texture.get_size()
			
			life_icon.position.x += $Lives.rect_size.x - 2 * life * icon_size.x
			life_icon.position.x -= int(icon_size.x / 2)
			life_icon.position.y += int(icon_size.y / 2) - 4
			
			$Lives.add_child(life_icon)
	else:
		$Multiplier.visible = true
		var life_icon = LIFE_ICON.instance()
		var icon_size = life_icon.texture.get_size()
		
		life_icon.position.x += $Lives.rect_size.x - int(icon_size.x / 2)
		life_icon.position.y += int(icon_size.y / 2) - 4
		$Lives.add_child(life_icon)
