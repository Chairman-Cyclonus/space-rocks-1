extends RigidBody2D

@export var engine_power = 500
@export var rotation_power = 8000
@export var bullet_scene: PackedScene = preload("res://bullet/bullet.tscn")
@export var fire_rate = 0.25

var thrust = Vector2.ZERO
var rotation_direction = 0
var screensize = Vector2.ZERO
var can_shoot = true


enum {INIT, ALIVE, INVUNERABLE, DEAD}
var state = INIT


func _ready():
	change_state(ALIVE)
	screensize = get_viewport_rect().size
	$GunCooldown.wait_time = fire_rate


func change_state(new_state):
	match new_state:
		INIT:
			$CollisionShape2D.set_deferred("disabled", true)

		ALIVE:
			$CollisionShape2D.set_deferred("disabled", false)

		INVUNERABLE:
			$CollisionShape2D.set_deferred("disabled", true)

		DEAD:
			$CollisionShape2D.set_deferred("disabled", true)

	state = new_state


func _process(_delta):
	get_input()


func get_input():
	thrust = Vector2.ZERO
	rotation_direction = 0

	if state in [DEAD, INIT]:
		return

	if Input.is_action_pressed("thrust"):
		thrust = transform.x * engine_power

	rotation_direction = Input.get_axis("rotate_left", "rotate_right")

	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()


func _physics_process(_delta):
	constant_force = thrust
	constant_torque = rotation_direction * rotation_power


func _integrate_forces(physics_state):
	screensize = get_viewport_rect().size
	var xform = physics_state.transform

	xform.origin.x = wrapf(xform.origin.x, 0, screensize.x)
	xform.origin.y = wrapf(xform.origin.y, 0, screensize.y)

	physics_state.transform = xform


func shoot():
	if state == INVUNERABLE:
		return

	if bullet_scene == null:
		return

	can_shoot = false
	$GunCooldown.start()

	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.start($Muzzle.global_transform)


func _on_gun_cooldown_timeout():
	can_shoot = true
