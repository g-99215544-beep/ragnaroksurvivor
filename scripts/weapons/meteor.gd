extends Node2D

@export var fire_rate = 0.25
@export var damage = 60.0
@export var impact_radius = 80.0
@export var meteor_count = 1

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

	for i in range(meteor_count):
		# Target random enemy position
		var target_enemy = enemies[randi() % enemies.size()]
		if is_instance_valid(target_enemy):
			var target_pos = target_enemy.global_position + Vector2(randf_range(-30, 30), randf_range(-30, 30))
			spawn_meteor(target_pos, i * 0.3)

func spawn_meteor(target_pos, delay):
	if delay > 0:
		await get_tree().create_timer(delay).timeout

	# Warning indicator
	var warning = MeteorWarning.new()
	warning.global_position = target_pos
	warning.radius = impact_radius
	get_tree().root.add_child(warning)

	await get_tree().create_timer(0.6).timeout

	# Impact damage
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		if is_instance_valid(enemy):
			if target_pos.distance_to(enemy.global_position) <= impact_radius:
				if enemy.has_method("take_damage"):
					enemy.take_damage(damage)

	# Impact effect
	var impact = MeteorImpact.new()
	impact.global_position = target_pos
	impact.radius = impact_radius
	get_tree().root.add_child(impact)

func upgrade():
	level += 1
	match level:
		2:
			damage += 20
		3:
			meteor_count += 1
		4:
			impact_radius += 20
		5:
			fire_rate += 0.1
		6:
			damage += 30
		7:
			meteor_count += 1
		8:
			impact_radius += 30

class MeteorWarning extends Node2D:
	var elapsed = 0.0
	var radius = 80.0

	func _process(delta):
		elapsed += delta
		queue_redraw()
		if elapsed >= 0.6:
			queue_free()

	func _draw():
		var alpha = 0.15 + (elapsed / 0.6) * 0.25
		draw_circle(Vector2.ZERO, radius, Color(1.0, 0.3, 0.1, alpha))
		draw_arc(Vector2.ZERO, radius, 0, TAU, 32, Color(1.0, 0.5, 0.2, alpha + 0.2), 2.0)

class MeteorImpact extends Node2D:
	var elapsed = 0.0
	var radius = 80.0

	func _process(delta):
		elapsed += delta
		queue_redraw()
		if elapsed >= 0.4:
			queue_free()

	func _draw():
		var progress = elapsed / 0.4
		var alpha = 1.0 - progress
		# Fiery explosion
		draw_circle(Vector2.ZERO, radius * (0.5 + progress * 0.5), Color(1.0, 0.6, 0.1, alpha * 0.6))
		draw_circle(Vector2.ZERO, radius * 0.4 * (1.0 - progress), Color(1.0, 0.9, 0.3, alpha))
