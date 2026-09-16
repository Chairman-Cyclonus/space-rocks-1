extends RigidBody2D

signal exploded(size, radius, pos, vel)

var size = 3
var radius = 1.0
var scale_factor = 0.2
var exploding = false

func start(spawn_position, velocity, rock_size):
	position = spawn_position
	size = rock_size
	mass = 1.5 * size
	$Sprite2D.scale = Vector2.ONE * scale_factor * size
	radius = $Sprite2D.texture.get_size().x / 2 * $Sprite2D.scale.x
	var shape = CircleShape2D.new()
	shape.radius = radius
	$CollisionShape2D.shape = shape
	linear_velocity = velocity
	angular_velocity = randf_range(-PI, PI)
	$Explosion.scale = Vector2.ONE * 0.75 * size

func _integrate_forces(physics_state):
	var screensize = get_viewport_rect().size
	var xform = physics_state.transform
	xform.origin.x = wrapf(xform.origin.x, -radius, screensize.x + radius)
	xform.origin.y = wrapf(xform.origin.y, -radius, screensize.y + radius)
	physics_state.transform = xform

func explode():
	if exploding:
		return
	exploding = true
	$CollisionShape2D.set_deferred("disabled", true)
	$Sprite2D.hide()
	$Explosion.show()
	$Explosion/AnimationPlayer.play("explosion")
	exploded.emit(size, radius, position, linear_velocity)
	angular_velocity = 0
	await $Explosion/AnimationPlayer.animation_finished
	queue_free()
