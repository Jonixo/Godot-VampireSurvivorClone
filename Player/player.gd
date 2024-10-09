extends CharacterBody2D

## our movement speed variable
var movement_speed = 40.0
var hp = 80

#attacks
var iceSpear = preload("res://Player/Attack/ice_spear.tscn")

#attackNodes
@onready var iceSpearTimer = get_node("%IceSpearTimer")
@onready var iceSpearAttackTimer = get_node("%IceSpearAttackTimer")

#IceSpear
var icespear_ammo = 0
var icespear_baseammo = 5
var icespear_attackspeed = 1.5
var icespear_level = 1

#enemy related
var enemy_close = []

@onready var sprite = $Sprite2D
@onready var walkTimer = get_node("%walkTimer")

func _ready():
	attack()

## triggers every 1/60th of a sec, godot function
func _physics_process(delta):
	movement ()

## custom movement function	
func movement():
	var x_mov = Input.get_action_strength("right") - Input.get_action_strength("left") ##right is a positive value, left is negative
	var y_mov = Input.get_action_strength("down") - Input.get_action_strength("up") ## down is positive, up is negative, reverse of usual
	var mov = Vector2(x_mov, y_mov) ##convert movement to vector add to movement
	if mov.x > 0: ##Flip sprite to left or right
		sprite.flip_h = true
	elif mov.x < 0:
		sprite.flip_h = false
		
	if mov != Vector2.ZERO: ##thers is movement
		if walkTimer.is_stopped(): ##if timer is not running
			if sprite.frame >= sprite.hframes - 1: ##-1 because frame start at 0, hframe start at 1
				sprite.frame = 0
			else:
				sprite.frame += 1
			walkTimer.start()
	
	velocity = mov.normalized() * movement_speed ## multiply movement speed with normalized vector movement to get velocity
	move_and_slide() ##godot function specificly for characterbody2d 

func attack():
	if icespear_level > 0:
		iceSpearTimer.wait_time = icespear_attackspeed
		if iceSpearTimer.is_stopped():
			iceSpearTimer.start()

func _on_hurt_box_hurt(damage):
	hp -= damage
	print(hp)


func _on_ice_spear_timer_timeout(): ##loading ammunition
	icespear_ammo += icespear_baseammo
	iceSpearAttackTimer.start()


func _on_ice_spear_attack_timer_timeout():
	if icespear_ammo > 0:
		var icespear_attack = iceSpear.instantiate()
		icespear_attack.position = position
		icespear_attack.target = get_random_target()
		icespear_attack.level = icespear_level
		add_child(icespear_attack)
		icespear_ammo -= 1
		if icespear_ammo > 0:
			iceSpearAttackTimer.start()
		else:
			iceSpearAttackTimer.stop()
		
func get_random_target():
	if enemy_close.size() > 0:
		return enemy_close.pick_random().global_position
	else:
		return Vector2.UP


func _on_enemy_detection_area_body_entered(body):
	if not enemy_close.has(body):
		enemy_close.append(body)


func _on_enemy_detection_area_body_exited(body):
	if enemy_close.has(body):
		enemy_close.erase(body)
