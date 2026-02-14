extends Area2D

var direction = Vector2.RIGHT
var speed = 300.0
var damage = 10.0
var pierce = 1
var hit_enemies = []

func setup(dir, spd, dmg, prc):
	direction = dir.normalized()
	speed = spd
	damage = dmg
	pierce = prc
	rotation = direction.angle()

func _ready():
	add_to_group("projectile")
	set_collision_layer_bit(2, true)
	set_collision_mask_bit(1, true)

func _physics_process(delta):
	position += direction * speed * delta
	
	# Remove if too far from origin
	if global_position.length() > 2000:
		queue_free()

func _on_area_entered(area):
	if area.is_in_group("enemy") or area.get_parent().is_in_group("enemy"):
		var enemy = area if area.is_in_group("enemy") else area.get_parent()
		
		if not enemy in hit_enemies:
			if enemy.has_method("take_damage"):
				enemy.take_damage(damage)
			hit_enemies.append(enemy)
			
			pierce -= 1
			if pierce <= 0:
				queue_free()

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		if not body in hit_enemies:
			if body.has_method("take_damage"):
				body.take_damage(damage)
			hit_enemies.append(body)
			
			pierce -= 1
			if pierce <= 0:
				queue_free()

func set_collision_layer_bit(bit, value):
	if value:
		collision_layer |= (1 << bit)
	else:
		collision_layer &= ~(1 << bit)

func set_collision_mask_bit(bit, value):
	if value:
		collision_mask |= (1 << bit)
	else:
		collision_mask &= ~(1 << bit)
