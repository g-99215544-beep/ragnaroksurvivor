extends Node2D

@export var fire_rate = 0.8
@export var damage = 20.0
@export var bolt_count = 3
@export var bolt_speed = 350.0

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

	# Find closest enemy
	var closest = null
	var min_dist = INF
	for enemy in enemies:
		var dist = global_position.distance_to(enemy.global_position)
		if dist < min_dist:
			min_dist = dist
			closest = enemy

	if not closest:
		return

	# Fire multiple bolts with slight delay between each
	for i in range(bolt_count):
		spawn_bolt(closest, i * 0.1)

func spawn_bolt(target, delay):
	if delay > 0:
		await get_tree().create_timer(delay).timeout

	if not is_instance_valid(target):
		return

	var bolt = SoulBolt.new()
	bolt.target = target
	bolt.damage = damage
	bolt.speed = bolt_speed
	bolt.global_position = global_position + Vector2(randf_range(-8, 8), randf_range(-8, 8))
	get_tree().root.add_child(bolt)

func upgrade():
	level += 1
	match level:
		2:
			damage += 8
		3:
			bolt_count += 1
		4:
			fire_rate += 0.2
		5:
			bolt_speed += 80
		6:
			damage += 12
		7:
			bolt_count += 2
		8:
			fire_rate += 0.3

# Inner class for the homing bolt
class SoulBolt extends Node2D:
	var target = null
	var damage = 20.0
	var speed = 350.0
	var lifetime = 3.0
	var elapsed = 0.0

	func _ready():
		# Draw a purple magic bolt
		queue_redraw()

	func _process(delta):
		elapsed += delta
		if elapsed >= lifetime:
			queue_free()
			return

		if is_instance_valid(target):
			var direction = (target.global_position - global_position).normalized()
			position += direction * speed * delta
			rotation = direction.angle()

			# Check if we hit the target
			if global_position.distance_to(target.global_position) < 12:
				if target.has_method("take_damage"):
					target.take_damage(damage)
				spawn_hit_effect()
				queue_free()
		else:
			queue_free()

	func _draw():
		# Purple magic bolt shape
		draw_circle(Vector2.ZERO, 5, Color(0.7, 0.3, 1.0, 0.9))
		draw_circle(Vector2.ZERO, 3, Color(0.9, 0.7, 1.0, 1.0))

	func spawn_hit_effect():
		var hit = Node2D.new()
		hit.global_position = global_position
		hit.set_script(HitEffect)
		get_tree().root.add_child(hit)

class HitEffect extends Node2D:
	var elapsed = 0.0

	func _process(delta):
		elapsed += delta
		queue_redraw()
		if elapsed >= 0.2:
			queue_free()

	func _draw():
		var alpha = 1.0 - (elapsed / 0.2)
		var radius = 8 + elapsed * 40
		draw_circle(Vector2.ZERO, radius, Color(0.7, 0.3, 1.0, alpha * 0.5))
