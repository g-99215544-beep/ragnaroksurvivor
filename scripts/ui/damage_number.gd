extends Label

var damage_value = 0
var velocity = Vector2.ZERO
var lifetime = 1.0
var elapsed = 0.0

func setup(damage: int, color: Color):
	damage_value = damage
	text = str(damage)
	modulate = color
	
	# Random upward velocity with slight horizontal variation (like RO)
	velocity = Vector2(randf_range(-20, 20), randf_range(-80, -120))
	
	# Font settings
	add_theme_font_size_override("font_size", 20)
	
	# Outline for better visibility (like RO damage numbers)
	add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	add_theme_constant_override("outline_size", 3)

func _ready():
	# Start slightly transparent and scale up
	modulate.a = 0.0
	scale = Vector2(0.5, 0.5)
	
	# Animate in
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.1)
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
	
	# Then animate out
	tween.chain().tween_property(self, "modulate:a", 0.0, 0.5).set_delay(0.4)
	tween.tween_property(self, "scale", Vector2(0.8, 0.8), 0.5).set_delay(0.4)

func _process(delta):
	elapsed += delta
	
	# Apply velocity (floating up and slowing down)
	position += velocity * delta
	velocity.y += 100 * delta  # Gravity effect to slow down
	velocity.x *= 0.95  # Horizontal dampening
	
	if elapsed >= lifetime:
		queue_free()
