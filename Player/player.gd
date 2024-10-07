extends CharacterBody2D

## our movement speed variable
var movement_speed = 40.0
@onready var sprite = $Sprite2D
@onready var walkTimer = get_node("%walkTimer")

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
