extends Node2D

@export var fire_rate = 0.3
@export var damage = 18.0
@export var radius = 120.0
@export var slow_duration = 2.0
@export var slow_amount = 0.5

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

	var hit_count = 0
	for enemy in enemies:
		if is_instance_valid(enemy):
			var dist = global_position.distance_to(enemy.global_position)
			if dist <= radius:
				if enemy.has_method("take_damage"):
					enemy.take_damage(damage)
				# Apply slow effect
				apply_slow(enemy)
				hit_count += 1

	if hit_count > 0:
		spawn_nova_effect()

func apply_slow(enemy):
	if not is_instance_valid(enemy):
		return
	var original_speed = enemy.speed
	enemy.speed *= slow_amount
	# Tint enemy blue while slowed
	var sprite = enemy.get_node_or_null("AnimatedSprite2D")
	if not sprite:
		sprite = enemy.get_node_or_null("Sprite2D")
	if sprite:
		sprite.modulate = Color(0.5, 0.7, 1.0)

	await get_tree().create_timer(slow_duration).timeout

	if is_instance_valid(enemy):
		enemy.speed = original_speed
		if is_instance_valid(sprite):
			sprite.modulate = Color(1, 1, 1)

func spawn_nova_effect():
	var effect = FrostNovaEffect.new()
	effect.global_position = global_position
	effect.max_radius = radius
	get_tree().root.add_child(effect)

func upgrade():
	level += 1
	match level:
		2:
			damage += 8
		3:
			radius += 30
		4:
			fire_rate += 0.1
		5:
			slow_duration += 1.0
		6:
			damage += 12
		7:
			radius += 40
		8:
			slow_amount = 0.3

class FrostNovaEffect extends Node2D:
	var elapsed = 0.0
	var max_radius = 120.0
	var duration = 0.4

	func _process(delta):
		elapsed += delta
		queue_redraw()
		if elapsed >= duration:
			queue_free()

	func _draw():
		var progress = elapsed / duration
		var current_radius = max_radius * progress
		var alpha = 1.0 - progress
		# Ice blue expanding ring
		draw_arc(Vector2.ZERO, current_radius, 0, TAU, 32, Color(0.4, 0.7, 1.0, alpha), 3.0)
		draw_arc(Vector2.ZERO, current_radius * 0.7, 0, TAU, 32, Color(0.6, 0.85, 1.0, alpha * 0.6), 2.0)
