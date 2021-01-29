extends "res://state_machine.gd"

export (float) var detection_radius = 100
export (float) var flying_speed = 60

onready var velocity = Vector2.ZERO
onready var screen_size = OS.get_screen_size()
onready var GRAVITY = 250

var player_reference = null
var current_direction = null

func _ready():
	$HitSound.volume_db = Global.get_effects_db()
	$Flying.volume_db = Global.get_effects_db()
	
	add_to_group("ENEMY")
	add_state("idle")
	add_state("flying")
	add_state("dead")
	call_deferred("set_state", states.idle)
	
	$DetectionArea/CollisionShape2D.shape.radius = detection_radius

func _physics_process(delta):
	_state_logic(delta)
	var return_state = _get_transition(delta)
	if return_state != null:
		set_state(return_state)

func _state_logic(delta):
	if state == states.idle:
		pass
	elif state == states.flying:
		move_towards_player()
		facing_direction()
		check_player_collision()
	elif state == states.dead:
		apply_gravity(delta)
		delete_if_outside()

func _get_transition(_delta):
	match state:
		states.idle:
			pass
		states.flying:
			pass
	return null

func _enter_state(new_state, _old_state):
	match new_state:
		states.idle:
			$AnimationPlayer.play("idle")
		states.flying:
			$AnimationPlayer.play("flying")
			$Flying.play()
		states.dead:
			$Collision.disabled = true
			$AnimationPlayer.play("dead")
			$HitSound.play()
			velocity.y = 0
			velocity.x = 0

func _exit_state(old_state, _new_state):
	match old_state:
		states.flying:
			$Flying.stop()

func apply_gravity(delta):
	if velocity.y < GRAVITY:
		velocity.y += delta * GRAVITY
	velocity.y = move_and_slide(velocity).y

func move_towards_player():
	var player_pos = player_reference.position
	if current_direction == null:
		current_direction = (player_pos - position).normalized()
	
	var real_direction = (player_pos - position).normalized()
	current_direction = (current_direction + real_direction).normalized()
	velocity = current_direction * flying_speed
	velocity = move_and_slide(velocity)

func facing_direction():
	if $Sprite.scale.x != sign(-current_direction.x):
		$Sprite.scale.x = -$Sprite.scale.x

func check_player_collision():
	# Enemy hit is detected by player object. But, if player
	# is not moving, collision is not detected. We have to detect it on
	# enemy
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.name == "Player":
			collision.collider.check_enemy_hit()
			break

func die():
	if state != states.dead:
		set_state(states.dead)

func delete_if_outside():
	if position.y + 32 > screen_size.y:
		queue_free()

func _on_DetectionArea_body_entered(body):
	if body.name == 'Player' and state != states.flying:
		set_state(states.flying)
		player_reference = body
