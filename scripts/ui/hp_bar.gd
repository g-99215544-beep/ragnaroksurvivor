extends ProgressBar

var parent = null
var background_style = null
var fill_style = null

func _ready():
	# Get parent reference
	parent = get_parent()
	
	# Safety check
	if not parent:
		queue_free()
		return
	
	# Style the HP bar
	modulate = Color(1, 1, 1, 1)
	show_percentage = false
	
	# Create background style (gray bar)
	background_style = StyleBoxFlat.new()
	background_style.bg_color = Color(0.2, 0.2, 0.2, 0.8)
	background_style.set_corner_radius_all(2)
	add_theme_stylebox_override("background", background_style)
	
	# Create initial fill style (green)
	fill_style = StyleBoxFlat.new()
	fill_style.bg_color = Color(0.2, 0.8, 0.2)
	fill_style.set_corner_radius_all(2)
	add_theme_stylebox_override("fill", fill_style)
	
	# Connect to parent's health changes if available
	if parent.has_signal("health_changed"):
		parent.health_changed.connect(_on_health_changed)
	
	# Wait a frame then update
	await get_tree().process_frame
	update_health()

func _process(_delta):
	# Update every frame
	update_health()

func update_health():
	# Safety checks
	if not is_instance_valid(parent):
		return
	if not "health" in parent:
		return
	if not "max_health" in parent:
		return
		
	max_value = parent.max_health
	value = parent.health
	
	# Avoid division by zero
	if parent.max_health <= 0:
		return
	
	# Color coding based on health percentage
	var health_percent = (parent.health / parent.max_health) * 100
	
	# Update fill color based on health
	if health_percent > 50:
		fill_style.bg_color = Color(0.2, 0.8, 0.2)
	elif health_percent > 25:
		fill_style.bg_color = Color(0.9, 0.9, 0.2)
	else:
		fill_style.bg_color = Color(0.9, 0.2, 0.2)
	
	add_theme_stylebox_override("fill", fill_style)

func _on_health_changed(current_health, max_health):
	update_health()
