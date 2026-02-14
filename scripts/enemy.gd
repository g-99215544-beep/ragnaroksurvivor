extends CharacterBody2D

@export var speed = 80.0
@export var max_health = 30.0
@export var health = 30.0
@export var damage = 5.0
@export var exp_value = 1
@export var contact_damage = 10.0

var player = null

signal died

func _ready():
	add_to_group("enemy")
	
	# Play idle animation by default
	if $AnimatedSprite2D:
		$AnimatedSprite2D.play("idle")

func _physics_process(delta):
	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
		
		# Update animation
		update_animation(direction)

func update_animation(direction):
	if not $AnimatedSprite2D:
		# Fallback to Sprite2D
		if $Sprite2D and direction.x != 0:
			$Sprite2D.flip_h = direction.x < 0
		return
	
	# Flip sprite based on direction
	if direction.x != 0:
		$AnimatedSprite2D.flip_h = direction.x < 0
	
	# Play walk animation when moving
	if velocity.length() > 0:
		$AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.play("idle")

func set_player(p):
	player = p

func take_damage(amount):
	health -= amount
	
	# Spawn damage number (WHITE for dealing damage to enemy)
	spawn_damage_number(amount, Color(1, 1, 1))
	
	# Visual feedback
	var sprite = $AnimatedSprite2D if $AnimatedSprite2D else $Sprite2D
	if sprite:
		sprite.modulate = Color(1, 0.5, 0.5)
		await get_tree().create_timer(0.1).timeout
		if is_instance_valid(self) and is_instance_valid(sprite):
			sprite.modulate = Color(1, 1, 1)
	
	if health <= 0:
		die()

func spawn_damage_number(damage_amount, color):
	var damage_label = load("res://scenes/ui/damage_number.tscn").instantiate()
	damage_label.global_position = global_position + Vector2(randf_range(-15, 15), -25)
	damage_label.setup(int(damage_amount), color)
	get_tree().root.add_child(damage_label)

func die():
	died.emit()
	
	# Spawn experience gem (1 exp each)
	var exp_gem_scene = preload("res://scenes/pickups/exp_gem.tscn")
	var exp_gem = exp_gem_scene.instantiate()
	exp_gem.global_position = global_position
	exp_gem.exp_value = 1
	get_parent().add_child(exp_gem)
	
	# Random chance to spawn health potion
	if randf() < 0.1:
		var health_potion_scene = preload("res://scenes/pickups/health_potion.tscn")
		var health_potion = health_potion_scene.instantiate()
		health_potion.global_position = global_position + Vector2(randf_range(-20, 20), randf_range(-20, 20))
		get_parent().add_child(health_potion)
	
	queue_free()
