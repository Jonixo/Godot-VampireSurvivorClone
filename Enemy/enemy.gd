extends CharacterBody2D


@export var movement_speed = 20.0 ##Export shows up in inspector menu

@onready var player = get_tree().get_first_node_in_group("player") ##onready var gets a value after the nodes are loaded

func _physics_process(delta):
	var direction = global_position.direction_to(player.global_position)
	velocity = direction*movement_speed
	move_and_slide()
