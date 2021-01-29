extends "res://state_machine.gd"

export (float) var WALK_VELOCITY = 20
export (bool) var enable_flying = false
export (Vector2) var fly_to_point = Vector2.ZERO

onready var init_point = Vector2(position.x, position.y)
onready var destination_point = null

onready var velocity = Vector2.ZERO
onready var screen_size = OS.get_screen_size()
onready var GRAVITY = 250

func _ready():
	$DeathSound.volume_db = Global.get_effects_db()
	$Buzz.volume_db = Global.get_effects_db()
	
	add_to_group("ENEMY")
	add_state("falling")
	add_state("walking")
	add_state("flying")
	add_state("dead")
	call_deferred("set_state", states.falling)

func _physics_process(delta):
	_state_logic(delta)
	var return_state = _get_transition(delta)
	if return_state != null:
		set_state(return_state)

func _state_logic(delta):
	if state == states.falling:
		apply_gravity(delta)
		move_bug()
	elif state == states.walking:
		apply_gravity(delta)
		check_enemy_collision()
		check_player_collision()
		check_border()
		move_bug()
	elif state == states.flying:
		move_to_position()
		check_target_distance()
		check_player_collision()
	elif state == states.dead:
		apply_gravity(delta)
		move_bug()
		delete_if_outside()

func _get_transition(_delta):
	match state:
		states.falling:
			if touching_ground():
				return states.walking
		states.walking:
			if destination_point != null:
				return states.flying
		states.flying:
			if destination_point == null:
				return states.falling
	return null

# warning-ignore:unused_argument
func _enter_state(new_state, old_state):
	match new_state:
		states.walking:
			init_velocity()
			$CollisionNormal.disabled = false
			$AnimationPlayer.play("walk")
		states.flying:
			$Sprite.scale.x = sign(position.x - destination_point.x)
			$CollisionFlying.disabled = false
			$AnimationPlayer.play("fly")
			$Buzz.play()
		states.falling:
			$CollisionNormal.disabled = false
		states.dead:
			$CollisionNormal.disabled = true
			$CollisionFlying.disabled = true
			$AnimationPlayer.play("die")
			$DeathSound.play()
			velocity.y = -100
			velocity.x = 0

func _exit_state(old_state, _new_state):
	match old_state:
		states.walking:
			$CollisionNormal.disabled = true
		states.flying:
			$CollisionFlying.disabled = true
			$Buzz.stop()
		states.falling:
			$CollisionNormal.disabled = true
		states.dead:
			pass

func init_velocity():
	$Sprite.scale.x = 1
	velocity = Vector2(-WALK_VELOCITY, 10)
	if randf() < 0.5:
		invert_movement()

func touching_ground():
	return $DownLeft.is_colliding() or $DownRight.is_colliding()

func apply_gravity(delta):
	if velocity.y < GRAVITY:
		velocity.y += delta * GRAVITY

func move_bug():
	velocity.y = move_and_slide(velocity).y

func check_border():
	if not $DownLeft.is_colliding() and velocity.x < 0:
		invert_movement()
	if not $DownRight.is_colliding() and velocity.x > 0:
		invert_movement()

func check_enemy_collision():
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.is_in_group("ENEMY"):
			invert_movement()
			break

func check_player_collision():
	# Enemy hit hit is detected by player object. But, if player
	# is not moving, collision is not detected. We have to detect it on
	# enemy
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.name == "Player":
			collision.collider.check_enemy_hit()
			break

func delete_if_outside():
	if position.y + 32 > screen_size.y:
		queue_free()

func invert_movement():
	$Sprite.scale.x = sign(velocity.x)
	velocity.x = -velocity.x

func move_to_position():
	var direction = (destination_point - position).normalized()
	if destination_point.y > position.y:
		direction.x = 2 * direction.x
	else:
		direction.y = 2 * direction.y + 0.5 * sign(direction.y)
	
	direction = direction.normalized()
	velocity = direction * WALK_VELOCITY * 4
	velocity = move_and_slide(velocity)

func check_target_distance():
	if position.distance_squared_to(destination_point) > 20:
		return
	fly_to_point = Vector2(init_point.x, init_point.y)
	init_point = Vector2(position.x, position.y)
	destination_point = null
	$Travel.paused = false

func die():
	if state != states.dead:
		set_state(states.dead)

func _on_Travel_timeout():
	if enable_flying:
		init_point = Vector2(position.x, position.y)
		destination_point = Vector2(fly_to_point.x, fly_to_point.y)
		$Travel.paused = true
