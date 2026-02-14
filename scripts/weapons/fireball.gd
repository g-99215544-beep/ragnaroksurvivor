extends Node2D

@export var projectile_scene: PackedScene
@export var fire_rate = 1.0
@export var projectile_speed = 300.0
@export var damage = 15.0
@export var projectile_count = 1
@export var pierce = 1

var level = 1
var time_since_last_shot = 0.0

func _ready():
	if not projectile_scene:
		projectile_scene = preload("res://scenes/projectiles/fireball_projectile.tscn")

func _process(delta):
	time_since_last_shot += delta
	
	if time_since_last_shot >= 1.0 / fire_rate:
		shoot()
		time_since_last_shot = 0.0

func shoot():
	var enemies = get_tree().get_nodes_in_group("enemy")
	if enemies.is_empty():
		return
	
	# Find closest enemy
	var closest_enemy = null
	var min_distance = INF
	
	for enemy in enemies:
		var distance = global_position.distance_to(enemy.global_position)
		if distance < min_distance:
			min_distance = distance
			closest_enemy = enemy
	
	if closest_enemy:
		for i in range(projectile_count):
			var projectile = projectile_scene.instantiate()
			projectile.global_position = global_position
			
			var angle_offset = 0.0
			if projectile_count > 1:
				angle_offset = (i - projectile_count / 2.0) * 0.3
			
			var direction = (closest_enemy.global_position - global_position).normalized()
			direction = direction.rotated(angle_offset)
			
			projectile.setup(direction, projectile_speed, damage, pierce)
			get_tree().root.add_child(projectile)

func upgrade():
	level += 1
	match level:
		2:
			fire_rate += 0.2
		3:
			damage += 5
		4:
			projectile_count += 1
		5:
			pierce += 1
		6:
			projectile_speed += 50
		7:
			fire_rate += 0.3
		8:
			damage += 10
