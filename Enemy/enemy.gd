extends CharacterBody2D


@export var movement_speed = 20.0 ##Export shows up in inspector menu
@export var hp = 10

@onready var player = get_tree().get_first_node_in_group("player") ##onready var gets a value after the nodes are loaded
@onready var sprite = $Sprite2D
@onready var walkTimer = get_node("%walkTimer")
@onready var anim = $AnimationPlayer ##we want mobs to always animate to we use animation player

func _ready():
	anim.play("walk")

func _physics_process(delta):
	var direction = global_position.direction_to(player.global_position)
	velocity = direction*movement_speed
	move_and_slide()
	
	if direction.x > .1:
		sprite.flip_h = true
	elif direction.x < -.1:
		sprite.flip_h = false


func _on_hurt_box_hurt(damage):
	hp -= damage
	if hp <= 0:
		queue_free() #deleted the enemy is hp lower than 1
	print(hp)
