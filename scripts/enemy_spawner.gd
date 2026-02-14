extends Node2D

@export var enemy_scenes: Array[PackedScene] = []
@export var spawn_interval = 2.0
@export var spawn_distance = 350.0
@export var max_enemies = 100

var player = null
var time_since_spawn = 0.0
var difficulty_multiplier = 1.0
var game_time = 0.0

func _ready():
	# Load enemy scenes
	enemy_scenes.append(preload("res://scenes/enemies/poring.tscn"))
	enemy_scenes.append(preload("res://scenes/enemies/lunatic.tscn"))
	
	# IMPORTANT: Find the player
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	
	if not player:
		print("ERROR: Player not found!")

func _process(delta):
	if not player:
		return
	
	game_time += delta
	time_since_spawn += delta
	
	# Increase difficulty over time
	difficulty_multiplier = 1.0 + (game_time / 60.0)
	
	# Decrease spawn interval as game progresses
	var current_spawn_interval = max(0.5, spawn_interval - (game_time / 120.0))
	
	if time_since_spawn >= current_spawn_interval:
		spawn_enemy()
		time_since_spawn = 0.0

func spawn_enemy():
	var current_enemies = get_tree().get_nodes_in_group("enemy").size()
	if current_enemies >= max_enemies:
		return
	
	if enemy_scenes.is_empty() or not player:
		return
	
	# Random enemy type
	var enemy_scene = enemy_scenes[randi() % enemy_scenes.size()]
	var enemy = enemy_scene.instantiate()
	
	# Spawn at random position around player (CLOSER NOW)
	var angle = randf() * TAU
	var spawn_pos = player.global_position + Vector2(cos(angle), sin(angle)) * spawn_distance
	enemy.global_position = spawn_pos
	
	# Apply difficulty scaling
	if enemy.has_method("set_player"):
		enemy.set_player(player)
	
	enemy.max_health *= difficulty_multiplier
	enemy.health *= difficulty_multiplier
	enemy.speed *= min(1.5, 1.0 + (difficulty_multiplier - 1.0) * 0.3)
	
	get_tree().root.add_child(enemy)
