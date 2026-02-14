extends Node2D

@export var fire_rate = 0.2
@export var damage = 35.0
@export var radius = 180.0
@export var wave_count = 3

var level = 1
var time_since_last_shot = 0.0

func _process(delta):
	time_since_last_shot += delta

	if time_since_last_shot >= 1.0 / fire_rate:
		cast()
		time_since_last_shot = 0.0

func cast():
	var enemies = get_tree().get_nodes_in_group("enemy")
	if enemies.is_empty():
		return

	for i in range(wave_count):
		spawn_wave(i * 0.25)

func spawn_wave(delay):
	if delay > 0:
		await get_tree().create_timer(delay).timeout

	var wave_radius = radius * (0.5 + randf() * 0.5)
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		if is_instance_valid(enemy):
			if global_position.distance_to(enemy.global_position) <= wave_radius:
				if enemy.has_method("take_damage"):
					enemy.take_damage(damage)

	# Visual shockwave
	var effect = QuakeWave.new()
	effect.global_position = global_position
	effect.max_radius = wave_radius
	get_tree().root.add_child(effect)

func upgrade():
	level += 1
	match level:
		2:
			damage += 15
		3:
			radius += 40
		4:
			wave_count += 1
		5:
			fire_rate += 0.08
		6:
			damage += 20
		7:
			radius += 50
		8:
			wave_count += 2

class QuakeWave extends Node2D:
	var elapsed = 0.0
	var max_radius = 180.0
	var duration = 0.35

	func _process(delta):
		elapsed += delta
		queue_redraw()
		if elapsed >= duration:
			queue_free()

	func _draw():
		var progress = elapsed / duration
		var current_radius = max_radius * progress
		var alpha = 1.0 - progress
		# Brown/earth shockwave
		draw_arc(Vector2.ZERO, current_radius, 0, TAU, 32, Color(0.6, 0.4, 0.2, alpha), 4.0)
		draw_arc(Vector2.ZERO, current_radius * 0.85, 0, TAU, 32, Color(0.8, 0.6, 0.3, alpha * 0.5), 2.0)
