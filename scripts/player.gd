extends CharacterBody2D

@export var speed = 150.0
@export var max_health = 100.0
@export var health = 100.0
@export var base_damage = 10.0
@export var pickup_range = 50.0

var level = 1
var experience = 0
var experience_to_next_level = 3

var weapons = []
var passive_items = []
var damage_cooldown = 0.5
var can_take_damage = true

signal health_changed(new_health, max_health)
signal experience_gained(exp, total_exp, needed_exp)
signal player_leveled_up(new_level)
signal died

func _ready():
	add_to_group("player")
	health_changed.emit(health, max_health)
	
	# Start with basic weapon
	add_weapon("fireball")
	
	# Play idle animation by default
	if $AnimatedSprite2D:
		$AnimatedSprite2D.play("idle")

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_vector = input_vector.normalized()
	
	velocity = input_vector * speed
	move_and_slide()
	
	# Check for enemy collision (contact damage)
	if can_take_damage:
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider and collider.is_in_group("enemy"):
				var damage_amount = 10.0
				if "contact_damage" in collider:
					damage_amount = collider.contact_damage
				take_damage(damage_amount)
				can_take_damage = false
				get_tree().create_timer(damage_cooldown).timeout.connect(func(): can_take_damage = true)
				break
	
	# Update animation
	update_animation(input_vector)

func update_animation(input_vector):
	if not $AnimatedSprite2D:
		# Fallback to Sprite2D if AnimatedSprite2D doesn't exist
		if $Sprite2D and input_vector.x != 0:
			$Sprite2D.flip_h = input_vector.x < 0
		return
	
	# Flip sprite based on movement direction
	if input_vector.x != 0:
		$AnimatedSprite2D.flip_h = input_vector.x < 0
	
	# Play appropriate animation
	if input_vector.length() > 0:
		$AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.play("idle")

func take_damage(amount):
	health -= amount
	health = max(0, health)
	health_changed.emit(health, max_health)
	
	# Spawn damage number (RED for player taking damage)
	spawn_damage_number(amount, Color(1, 0.2, 0.2))
	
	# Visual feedback
	var sprite = $AnimatedSprite2D if $AnimatedSprite2D else $Sprite2D
	if sprite:
		sprite.modulate = Color(1, 0.3, 0.3)
		await get_tree().create_timer(0.1).timeout
		if is_instance_valid(sprite):
			sprite.modulate = Color(1, 1, 1)
	
	if health <= 0:
		die()

func spawn_damage_number(damage_amount, color):
	var damage_label = load("res://scenes/ui/damage_number.tscn").instantiate()
	damage_label.global_position = global_position + Vector2(randf_range(-10, 10), -20)
	damage_label.setup(int(damage_amount), color)
	get_tree().root.add_child(damage_label)

func heal(amount):
	health = min(max_health, health + amount)
	health_changed.emit(health, max_health)

func die():
	died.emit()
	queue_free()

func add_experience(amount):
	experience += amount
	experience_gained.emit(experience, experience, experience_to_next_level)
	
	while experience >= experience_to_next_level:
		level_up()

func level_up():
	level += 1
	experience -= experience_to_next_level
	experience_to_next_level = level + 2
	
	# Heal on level up
	heal(max_health * 0.3)
	
	player_leveled_up.emit(level)

func add_weapon(weapon_name):
	var weapon_scene = load("res://scenes/weapons/" + weapon_name + ".tscn")
	if weapon_scene:
		var weapon_instance = weapon_scene.instantiate()
		add_child(weapon_instance)
		weapons.append(weapon_instance)

func upgrade_stat(stat_name, value):
	match stat_name:
		"max_health":
			max_health += value
			health += value
			health_changed.emit(health, max_health)
		"speed":
			speed += value
		"damage":
			base_damage += value
		"pickup_range":
			pickup_range += value
			var pickup_area = get_node_or_null("PickupArea")
			if pickup_area:
				var collision_shape = pickup_area.get_node_or_null("CollisionShape2D")
				if collision_shape and collision_shape.shape is CircleShape2D:
					collision_shape.shape.radius = pickup_range

func _on_pickup_area_body_entered(body):
	if body.is_in_group("pickup"):
		body.collect(self)

func _on_hurt_box_area_entered(area):
	if area.is_in_group("enemy_attack"):
		take_damage(area.damage)
