extends Area2D

@export var exp_value = 1
@export var move_speed = 400.0

var player = null
var is_collected = false

func _ready():
	add_to_group("pickup")

func _physics_process(delta):
	if player and not is_collected:
		var direction = (player.global_position - global_position).normalized()
		global_position += direction * move_speed * delta

func collect(player_node):
	if is_collected:
		return
	
	is_collected = true
	player_node.add_experience(exp_value)
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		player = body
		collect(body)

func _on_magnet_area_body_entered(body):
	if body.is_in_group("player") and not player:
		player = body
