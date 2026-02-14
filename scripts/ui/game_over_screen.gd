extends Control

func _ready():
	visible = false

func show_screen():
	visible = true
	get_tree().paused = true
	
	var game_manager = get_node_or_null("/root/Main/GameManager")
	if game_manager:
		var time = int(game_manager.game_time)
		var minutes = time / 60
		var seconds = time % 60
		$Panel/VBoxContainer/TimeLabel.text = "Survived: %02d:%02d" % [minutes, seconds]
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		$Panel/VBoxContainer/LevelLabel.text = "Reached Level: %d" % player.level

func _on_restart_button_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_button_pressed():
	get_tree().quit()
