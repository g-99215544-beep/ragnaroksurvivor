extends Node

var player = null
var game_time = 0.0
var is_paused = false

signal game_over

func _ready():
	player = get_tree().get_first_node_in_group("player")
	if player:
		player.died.connect(_on_player_died)
		player.player_leveled_up.connect(_on_player_level_up)

func _process(delta):
	if not is_paused:
		game_time += delta

func _on_player_died():
	is_paused = true
	game_over.emit()
	show_game_over_screen()

func _on_player_level_up(new_level):
	is_paused = true
	show_upgrade_screen()

func show_upgrade_screen():
	var upgrade_screen = get_node_or_null("/root/Main/UI/UpgradeScreen")
	if upgrade_screen:
		upgrade_screen.show_upgrades()

func show_game_over_screen():
	var game_over_screen = get_node_or_null("/root/Main/UI/GameOverScreen")
	if game_over_screen:
		game_over_screen.show_screen()

func resume_game():
	is_paused = false

func restart_game():
	get_tree().reload_current_scene()
