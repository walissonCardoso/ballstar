extends KinematicBody2D

export var GRAVITY  =  800
export var IMPULSE  = -210
export var HORZ_VEL = 150

export var EXTRA_JUMP = 0.4
export var DASH_WAITING = 0.4
export var DASH_DURATION = 0.1
export var HOLD_FOR_BUBBLE = 2.0
export var DOUBLE_TAP_PRECISION = 0.25

var its_alive = true
var touching_floor = false
var touching_ceiling = false

var velocity = Vector2.ZERO
var timer_extra_jump = 0
var timer_dash_button = 0
var timer_dash = 0

var platform_colliding = null
var enemy_colliding = null

onready var dust_factory = preload("res://Player/Dust.tscn")
onready var screen_size = OS.get_screen_size()

func _ready():
	$Dash.volume_db = Global.get_effects_db()
	$Animation.play("stand")

func _physics_process(delta):
	if not its_alive:
		return
	
	check_collisions()
	read_input(delta)
	check_death_by_fall()
	set_animation()
	
	apply_gravity(delta)
	decrement_timers(delta)
	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)

func read_input(delta):
	if Input.is_action_just_pressed("ui_jump") and touching_floor:
		velocity.y = IMPULSE
		timer_extra_jump = EXTRA_JUMP
	if Input.is_action_pressed("ui_jump") and timer_extra_jump > 0:
		velocity.y += IMPULSE * delta / EXTRA_JUMP
	
	velocity.x = 0
	if Input.is_action_just_pressed("ui_right"):
		$Sprite.scale.x = 1
	if Input.is_action_just_pressed("ui_left"):
		$Sprite.scale.x = -1
	if Input.is_action_pressed("ui_right"):
		velocity.x += HORZ_VEL
	if Input.is_action_pressed("ui_left"):
		velocity.x -= HORZ_VEL
	
	check_dash()

func check_collisions():
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider == null:
			continue
		if collision.collider.is_in_group("PLATFORM"):
			platform_colliding = collision.collider
		if collision.collider.is_in_group("ENEMY"):
			enemy_colliding = collision.collider
	
	check_platform()
	check_enemy_hit()

func check_dash():
	if timer_dash > 0: velocity = $Sprite.scale.x * Vector2(10, 0) * HORZ_VEL
	if timer_dash > -DASH_WAITING: return
	
	if Input.is_action_just_pressed("ui_dash"):
		if timer_dash_button > 0: timer_dash = DASH_DURATION
		else: timer_dash_button = DOUBLE_TAP_PRECISION
	
	# This should be called only once if second condition
	# of this function works correctly
	if timer_dash > 0:
		var dust = dust_factory.instance()
		dust.position.x = position.x
		dust.position.y = position.y + 8
		dust.scale.x = $Sprite.scale.x
		get_parent().add_child(dust)
		$Dash.play()

func check_platform():
	if platform_colliding == null:
		return
	if platform_colliding.player_is_standing:
		touching_floor = true
	else:
		platform_colliding = null
	
	if get_floor_velocity().y != 0:
		velocity.y = get_floor_velocity().y

func check_enemy_hit():
	if enemy_colliding == null:
		return
	if timer_dash > 0:
		enemy_colliding.die()
		enemy_colliding = null
		return
	var bodies = $Feet.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("ENEMY"):
			body.die()
			enemy_colliding = null
			velocity.y = IMPULSE * 0.75
			return
	die()

func check_death_by_fall():
	if position.y > screen_size.y + 32: die()

func set_animation():
	if not its_alive:
		return
	if $Animation.current_animation != "stand" and touching_floor and velocity.x == 0:
		$Animation.play("stand")
	elif $Animation.current_animation != "dash" and timer_dash > 0:
		$Animation.play("dash")
	elif $Animation.current_animation != "jump" and not touching_floor:
		$Animation.play("jump")
	elif $Animation.current_animation != "walk" and touching_floor and abs(velocity.x) > 0:
		$Animation.play("walk")

func apply_gravity(delta):
	touching_floor = $Ground1.is_colliding() or $Ground2.is_colliding()
	touching_ceiling = $Ceiling1.is_colliding() or $Ceiling2.is_colliding()

	if not touching_floor and velocity.y < GRAVITY:
		velocity.y += delta * GRAVITY

func decrement_timers(delta):
	if timer_extra_jump > 0: timer_extra_jump -= delta
	if timer_dash_button > 0: timer_dash_button -= delta
	if timer_dash > -DASH_WAITING: timer_dash -= delta

func die():
	if its_alive:
		its_alive = false
		$HUD.set_lives_counter(Global.player_lives)
		$Animation.play("die")
		yield($Animation, "animation_finished")
		Global.decrease_life()

func update_lives_counter():
	$HUD.update_lives_counter()

func _on_number_flowers_changed(flowers_caught, flowers_to_win):
	$HUD.set_caught_flowers(flowers_caught, flowers_to_win)
