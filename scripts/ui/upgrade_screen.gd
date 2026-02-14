extends Control

var available_upgrades = []
var player = null

signal upgrade_selected

func _ready():
	visible = false
	player = get_tree().get_first_node_in_group("player")
	process_mode = Node.PROCESS_MODE_ALWAYS

func show_upgrades():
	visible = true
	get_tree().paused = true
	generate_upgrade_options()

func generate_upgrade_options():
	# Clear existing buttons
	for child in $Panel/VBoxContainer/UpgradeButtons.get_children():
		child.queue_free()
	
	available_upgrades = get_random_upgrades(3)
	
	for upgrade in available_upgrades:
		var button = Button.new()
		button.text = upgrade.name + "\n" + upgrade.description
		button.custom_minimum_size = Vector2(300, 80)
		button.pressed.connect(_on_upgrade_selected.bind(upgrade))
		$Panel/VBoxContainer/UpgradeButtons.add_child(button)

func get_random_upgrades(count):
	var all_upgrades = [
		{
			"name": "New Weapon: Lightning",
			"description": "Chain lightning that jumps between enemies",
			"type": "weapon",
			"weapon": "lightning"
		},
		{
			"name": "Fireball Upgrade",
			"description": "Improve your fireball skill",
			"type": "weapon_upgrade",
			"weapon": "fireball"
		},
		{
			"name": "Max Health +20",
			"description": "Increase maximum health",
			"type": "stat",
			"stat": "max_health",
			"value": 20
		},
		{
			"name": "Speed +15",
			"description": "Move faster",
			"type": "stat",
			"stat": "speed",
			"value": 15
		},
		{
			"name": "Damage +5",
			"description": "Increase base damage",
			"type": "stat",
			"stat": "damage",
			"value": 5
		},
		{
			"name": "Pickup Range +20",
			"description": "Collect items from further away",
			"type": "stat",
			"stat": "pickup_range",
			"value": 20
		}
	]
	
	# Filter out weapon upgrades for weapons the player doesn't have
	var valid_upgrades = []
	for upgrade in all_upgrades:
		if upgrade.type == "weapon_upgrade":
			var has_weapon = false
			for weapon in player.weapons:
				if weapon.name.to_lower().contains(upgrade.weapon):
					has_weapon = true
					break
			if has_weapon:
				valid_upgrades.append(upgrade)
		elif upgrade.type == "weapon":
			# Check if player already has this weapon
			var has_weapon = false
			for weapon in player.weapons:
				if weapon.name.to_lower().contains(upgrade.weapon):
					has_weapon = true
					break
			if not has_weapon:
				valid_upgrades.append(upgrade)
		else:
			valid_upgrades.append(upgrade)
	
	# Shuffle and pick random ones
	valid_upgrades.shuffle()
	return valid_upgrades.slice(0, min(count, valid_upgrades.size()))

func _on_upgrade_selected(upgrade):
	if not player:
		return
	
	match upgrade.type:
		"weapon":
			player.add_weapon(upgrade.weapon)
		"weapon_upgrade":
			for weapon in player.weapons:
				if weapon.name.to_lower().contains(upgrade.weapon):
					if weapon.has_method("upgrade"):
						weapon.upgrade()
					break
		"stat":
			player.upgrade_stat(upgrade.stat, upgrade.value)
	
	visible = false
	get_tree().paused = false
	
	var game_manager = get_node_or_null("/root/Main/GameManager")
	if game_manager:
		game_manager.resume_game()
