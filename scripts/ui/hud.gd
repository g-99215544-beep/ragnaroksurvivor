extends CanvasLayer

@onready var health_bar = $MarginContainer/VBoxContainer/HealthBar
@onready var health_label = $MarginContainer/VBoxContainer/HealthBar/HealthLabel
@onready var exp_bar = $MarginContainer/VBoxContainer/ExpBar
@onready var level_label = $MarginContainer/VBoxContainer/LevelLabel
@onready var timer_label = $MarginContainer/VBoxContainer/TimerLabel

var player = null

func _ready():
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	if player:
		player.health_changed.connect(_on_health_changed)
		player.experience_gained.connect(_on_experience_gained)
		player.player_leveled_up.connect(_on_level_up)
		player.job_changed.connect(_on_job_changed)

		# Initialize displays
		_on_health_changed(player.health, player.max_health)
		_on_level_up(player.level)

func _process(delta):
	# Update timer
	var game_manager = get_node_or_null("/root/Main/GameManager")
	if game_manager:
		var time = int(game_manager.game_time)
		var minutes = time / 60
		var seconds = time % 60
		timer_label.text = "%02d:%02d" % [minutes, seconds]
	
	# Update health bar every frame in case signal doesn't fire
	if player and is_instance_valid(player):
		_on_health_changed(player.health, player.max_health)

func _on_health_changed(current_health, max_health):
	if not health_bar or not health_label:
		return
		
	health_bar.max_value = max_health
	health_bar.value = current_health
	health_label.text = "%d / %d" % [int(current_health), int(max_health)]

func _on_experience_gained(current_exp, total_exp, needed_exp):
	if not exp_bar:
		return
	exp_bar.value = (float(current_exp) / float(needed_exp)) * 100

func _on_level_up(new_level):
	if not level_label:
		return
	var job = "Mage"
	if player and is_instance_valid(player):
		job = player.job_class.capitalize()
	level_label.text = "%s Lv.%d" % [job, new_level]
	if exp_bar:
		exp_bar.value = 0

func _on_job_changed(new_job):
	if not level_label or not player:
		return
	level_label.text = "%s Lv.%d" % [new_job.capitalize(), player.level]
