extends Node2D

@export var fire_rate = 0.5
@export var damage = 25.0
@export var chain_count = 3
@export var chain_range = 200.0

var level = 1
var time_since_last_shot = 0.0

func _process(delta):
	time_since_last_shot += delta
	
	if time_since_last_shot >= 1.0 / fire_rate:
		cast_lightning()
		time_since_last_shot = 0.0

func cast_lightning():
	var enemies = get_tree().get_nodes_in_group("enemy")
	if enemies.is_empty():
		return
	
	# Find closest enemy
	var target = find_closest_enemy(global_position, enemies)
	if not target:
		return
	
	var hit_enemies = []
	var current_target = target
	
	for i in range(chain_count):
		if current_target and is_instance_valid(current_target):
			# Deal damage
			if current_target.has_method("take_damage"):
				current_target.take_damage(damage)
			
			hit_enemies.append(current_target)
			
			# Visual effect
			spawn_lightning_effect(global_position if i == 0 else hit_enemies[i-1].global_position, current_target.global_position)
			
			# Find next target
			var next_enemies = []
			for enemy in enemies:
				if not enemy in hit_enemies and is_instance_valid(enemy):
					if current_target.global_position.distance_to(enemy.global_position) <= chain_range:
						next_enemies.append(enemy)
			
			current_target = find_closest_enemy(current_target.global_position, next_enemies)
		else:
			break

func find_closest_enemy(from_position, enemy_list):
	var closest = null
	var min_distance = INF
	
	for enemy in enemy_list:
		if is_instance_valid(enemy):
			var distance = from_position.distance_to(enemy.global_position)
			if distance < min_distance:
				min_distance = distance
				closest = enemy
	
	return closest

func spawn_lightning_effect(from_pos, to_pos):
	var lightning = Line2D.new()
	lightning.add_point(from_pos)
	lightning.add_point(to_pos)
	lightning.width = 3
	lightning.default_color = Color(0.5, 0.5, 1, 1)
	get_tree().root.add_child(lightning)
	
	# Remove after short duration
	await get_tree().create_timer(0.1).timeout
	if is_instance_valid(lightning):
		lightning.queue_free()

func upgrade():
	level += 1
	match level:
		2:
			damage += 10
		3:
			chain_count += 1
		4:
			fire_rate += 0.2
		5:
			chain_range += 50
		6:
			damage += 15
		7:
			chain_count += 2
		8:
			fire_rate += 0.3
