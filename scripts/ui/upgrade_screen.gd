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

	available_upgrades = get_random_upgrades(5)

	for upgrade in available_upgrades:
		var button = Button.new()
		button.text = upgrade.name + "\n" + upgrade.description
		button.custom_minimum_size = Vector2(300, 60)
		button.pressed.connect(_on_upgrade_selected.bind(upgrade))
		$Panel/VBoxContainer/UpgradeButtons.add_child(button)

func get_random_upgrades(count):
	var all_upgrades = [
		# Mage weapons (available from start)
		{
			"name": "New Skill: Soul Strike",
			"description": "Homing magic bolts that chase enemies",
			"type": "weapon",
			"weapon": "soul_strike"
		},
		{
			"name": "New Skill: Lightning",
			"description": "Chain lightning that jumps between enemies",
			"type": "weapon",
			"weapon": "lightning"
		},
		{
			"name": "New Skill: Frost Nova",
			"description": "AoE ice blast that slows enemies",
			"type": "weapon",
			"weapon": "frost_nova"
		},
		# Weapon upgrades
		{
			"name": "Fireball Upgrade",
			"description": "Improve your fireball skill",
			"type": "weapon_upgrade",
			"weapon": "fireball"
		},
		{
			"name": "Soul Strike Upgrade",
			"description": "More bolts, more damage",
			"type": "weapon_upgrade",
			"weapon": "soul_strike"
		},
		{
			"name": "Lightning Upgrade",
			"description": "Longer chains, more damage",
			"type": "weapon_upgrade",
			"weapon": "lightning"
		},
		{
			"name": "Frost Nova Upgrade",
			"description": "Wider range, stronger slow",
			"type": "weapon_upgrade",
			"weapon": "frost_nova"
		},
		# Stat upgrades
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

	# Add wizard skills if player has changed job
	if player.job_class == "wizard":
		all_upgrades.append_array([
			{
				"name": "New Skill: Meteor",
				"description": "Rain fire from the sky",
				"type": "weapon",
				"weapon": "meteor"
			},
			{
				"name": "New Skill: Earthquake",
				"description": "Shockwaves damage nearby enemies",
				"type": "weapon",
				"weapon": "earthquake"
			},
			{
				"name": "New Skill: Lord of Vermilion",
				"description": "Lightning storm on enemy clusters",
				"type": "weapon",
				"weapon": "lord_of_vermilion"
			},
			{
				"name": "Meteor Upgrade",
				"description": "Bigger explosions, more meteors",
				"type": "weapon_upgrade",
				"weapon": "meteor"
			},
			{
				"name": "Earthquake Upgrade",
				"description": "More shockwaves, wider radius",
				"type": "weapon_upgrade",
				"weapon": "earthquake"
			},
			{
				"name": "Lord of Vermilion Upgrade",
				"description": "More lightning strikes",
				"type": "weapon_upgrade",
				"weapon": "lord_of_vermilion"
			}
		])

	# Filter out weapon upgrades for weapons the player doesn't have
	var valid_upgrades = []
	for upgrade in all_upgrades:
		if upgrade.type == "weapon_upgrade":
			var has_weapon = false
			for weapon in player.weapons:
				if weapon.name.to_lower().replace(" ", "").contains(upgrade.weapon.replace("_", "")):
					has_weapon = true
					break
			if has_weapon:
				valid_upgrades.append(upgrade)
		elif upgrade.type == "weapon":
			# Check if player already has this weapon
			var has_weapon = false
			for weapon in player.weapons:
				if weapon.name.to_lower().replace(" ", "").contains(upgrade.weapon.replace("_", "")):
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
				if weapon.name.to_lower().replace(" ", "").contains(upgrade.weapon.replace("_", "")):
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
