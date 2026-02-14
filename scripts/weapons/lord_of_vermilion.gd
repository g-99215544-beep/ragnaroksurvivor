extends Node2D

@export var fire_rate = 0.15
@export var damage = 45.0
@export var radius = 200.0
@export var strike_count = 5

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

	# Find cluster of enemies - target the densest area
	var best_pos = global_position
	var best_count = 0
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var count = 0
		for other in enemies:
			if is_instance_valid(other) and enemy.global_position.distance_to(other.global_position) <= radius:
				count += 1
		if count > best_count:
			best_count = count
			best_pos = enemy.global_position

	# Rain lightning strikes on the area
	for i in range(strike_count):
		spawn_strike(best_pos, i * 0.12)

func spawn_strike(center_pos, delay):
	if delay > 0:
		await get_tree().create_timer(delay).timeout

	var strike_pos = center_pos + Vector2(randf_range(-radius * 0.6, radius * 0.6), randf_range(-radius * 0.6, radius * 0.6))

	# Damage enemies near strike
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		if is_instance_valid(enemy):
			if strike_pos.distance_to(enemy.global_position) <= 40:
				if enemy.has_method("take_damage"):
					enemy.take_damage(damage)

	# Lightning bolt visual
	var bolt = LovBolt.new()
	bolt.global_position = strike_pos
	get_tree().root.add_child(bolt)

func upgrade():
	level += 1
	match level:
		2:
			damage += 15
		3:
			strike_count += 2
		4:
			fire_rate += 0.05
		5:
			radius += 50
		6:
			damage += 20
		7:
			strike_count += 3
		8:
			fire_rate += 0.08

class LovBolt extends Node2D:
	var elapsed = 0.0

	func _ready():
		queue_redraw()

	func _process(delta):
		elapsed += delta
		queue_redraw()
		if elapsed >= 0.25:
			queue_free()

	func _draw():
		var alpha = 1.0 - (elapsed / 0.25)
		# Lightning bolt from sky
		var top = Vector2(randf_range(-5, 5), -150)
		var mid1 = Vector2(randf_range(-12, 12), -100)
		var mid2 = Vector2(randf_range(-8, 8), -50)
		var bottom = Vector2.ZERO

		# Main bolt
		draw_line(top, mid1, Color(1.0, 1.0, 0.5, alpha), 3.0)
		draw_line(mid1, mid2, Color(1.0, 1.0, 0.5, alpha), 3.0)
		draw_line(mid2, bottom, Color(1.0, 1.0, 0.5, alpha), 3.0)

		# Glow at impact
		draw_circle(Vector2.ZERO, 15 * alpha, Color(1.0, 1.0, 0.7, alpha * 0.5))

		# Branch
		draw_line(mid1, mid1 + Vector2(randf_range(8, 18), randf_range(-15, -25)), Color(0.8, 0.8, 1.0, alpha * 0.6), 1.5)
