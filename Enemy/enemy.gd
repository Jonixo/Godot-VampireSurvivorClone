extends CharacterBody2D


@export var movement_speed = 20.0 ##Export shows up in inspector menu
@export var hp = 10
@export var knockback_recovery = 3.5
var knockback = Vector2.ZERO

@onready var player = get_tree().get_first_node_in_group("player") ##onready var gets a value after the nodes are loaded
@onready var sprite = $Sprite2D
@onready var walkTimer = get_node("%walkTimer")
@onready var anim = $AnimationPlayer ##we want mobs to always animate to we use animation player
@onready var snd_hit = $snd_hit

var deart_anim = preload("res://Enemy/explosion.tscn")

signal remove_from_Array(object)


func _ready():
	anim.play("walk")

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	var direction = global_position.direction_to(player.global_position)
	velocity = direction*movement_speed
	velocity += knockback
	move_and_slide()
	
	if direction.x > .1:
		sprite.flip_h = true
	elif direction.x < -.1:
		sprite.flip_h = false

func death():
	emit_signal("remove_from_array")
	var enemy_death = deart_anim.instantiate()
	enemy_death.scale = sprite.scale
	enemy_death.global_position = global_position
	get_parent().call_deferred("add_child",enemy_death)
	queue_free() #deleted the enemy is hp lower than 1

func _on_hurt_box_hurt(damage, angle, knockback_amount):
	hp -= damage
	knockback = angle * knockback_amount
	if hp <= 0:
		death()
	else:
		snd_hit.play()
