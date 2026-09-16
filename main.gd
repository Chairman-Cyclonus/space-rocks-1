extends Node
# MY EYES ARE BLOOD SHOT 
@export var rock_scene: PackedScene = preload("res://Rock/Rock.tscn")
var screensize = Vector2.ZERO

func _ready():
	get_viewport().size_changed.connect(_resize)
	_resize()
	$Player.position = screensize / 2
	for i in range(3):
		spawn_rock(3)

func _resize():
	screensize = get_viewport().get_visible_rect().size
	var curve = Curve2D.new()
	for point in [Vector2.ZERO, Vector2(screensize.x, 0), screensize, Vector2(0, screensize.y), Vector2.ZERO]:
		curve.add_point(point)
	$RockPath.curve = curve
	$Background.position = screensize / 2
	$Background.scale = screensize / $Background.texture.get_size()

func spawn_rock(size, pos = null, vel = null):
	if pos == null:
		$RockPath/RockSpawn.progress_ratio = randf()
		pos = $RockPath/RockSpawn.global_position
	if vel == null:
		vel = Vector2.RIGHT.rotated(randf_range(0, TAU)) * randf_range(50, 125)
	var rock = rock_scene.instantiate()
	rock.start(pos, vel, size)
	rock.exploded.connect(_on_rock_exploded)
	add_child(rock)

func _on_rock_exploded(size, radius, pos, vel):
	if size <= 1:
		return
	var direction = vel.normalized().orthogonal()
	if direction.is_zero_approx():
		direction = Vector2.UP
	for offset in [-1, 1]:
		var split_direction = direction * offset
		call_deferred("spawn_rock", size - 1, pos + split_direction * radius * 0.6, vel + split_direction * 80)
