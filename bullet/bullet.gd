extends Area2D

@export var speed = 1000
var velocity = Vector2.ZERO
var lifetime = 2.0
var spent = false



func start(_transform):
	global_transform = _transform
	velocity = transform.x * speed


func _physics_process(delta):
	position += velocity * delta
	lifetime -= delta
	if lifetime <= 0:
		queue_free()


func _on_visible_on_screen_enabler_2d_screen_exited():
	queue_free()


func _on_body_entered(body):
	if not spent and body.is_in_group("rocks"):
		spent = true
		body.explode()
		queue_free()
