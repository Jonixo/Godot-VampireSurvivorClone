extends CharacterBody2D

## our movement speed variable
var movement_speed = 40.0
var hp = 80
var last_movement = Vector2.UP

var experience = 0
var experience_level = 1
var collected_experience = 0

#attacks
var iceSpear = preload("res://Player/Attack/ice_spear.tscn")
var tornado = preload("res://Player/Attack/tornado.tscn")
var javelin = preload("res://Player/Attack/javelin.tscn")

#attackNodes
@onready var iceSpearTimer = get_node("%IceSpearTimer")
@onready var iceSpearAttackTimer = get_node("%IceSpearAttackTimer")
@onready var tornadoTimer = get_node("%TornadoTimer")
@onready var tornadoAttackTimer = get_node("%TornadoAttackTimer")
@onready var javelinBase = get_node("%JavelinBase")

#IceSpear
var icespear_ammo = 0
var icespear_baseammo = 1
var icespear_attackspeed = 1.5
var icespear_level = 1

#Tornado
var tornado_ammo = 0
var tornado_baseammo = 1
var tornado_attackspeed = 3
var tornado_level = 1

#Javelin
var javelin_ammo = 3
var javelin_level = 1




#enemy related
var enemy_close = []

@onready var sprite = $Sprite2D
@onready var walkTimer = get_node("%walkTimer")

#GUI
@onready var expBar = get_node("%ExperienceBar")
@onready var lblLevel = get_node("%lbl_level")
@onready var levelPanel = get_node("%LevelUp")
@onready var upgradeOption = get_node("%UpgradeOptions")
@onready var itemOptions = preload("res://Utility/item_option.tscn")
@onready var snd_levelup = get_node("%snd_levelup")

func _ready():
	attack()
	set_exp_bar(experience,calculate_experiencecap())

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
		last_movement = mov
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
	if tornado_level > 0:
		tornadoTimer.wait_time = tornado_attackspeed
		if tornadoTimer.is_stopped():
			tornadoTimer.start()
	if javelin_level > 0:
		spawn_javelin()
			
func _on_hurt_box_hurt(damage, _angle, _knockback): ##we dont need angle or knockback here but function needs args
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
			
func _on_tornado_timer_timeout():
	tornado_ammo += tornado_baseammo
	tornadoAttackTimer.start()


func _on_tornado_attack_tımer_timeout():
	if tornado_ammo > 0:
		var tornado_attack = tornado.instantiate()
		tornado_attack.position = position
		tornado_attack.last_movement = last_movement
		tornado_attack.level = tornado_level
		add_child(tornado_attack)
		tornado_ammo -= 1
		if tornado_ammo > 0:
			tornadoAttackTimer.start()
		else:
			tornadoAttackTimer.stop()
			
func spawn_javelin():
	var get_javelin_total = javelinBase.get_child_count()
	var calc_spawns = javelin_ammo - get_javelin_total
	while calc_spawns > 0:
		var javelin_spawn = javelin.instantiate()
		javelin_spawn.global_position  = global_position
		javelinBase.add_child(javelin_spawn)
		calc_spawns -= 1
		
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


func _on_grab_area_area_entered(area):
	if area.is_in_group("loot"):
		area.target = self


func _on_collect_area_area_entered(area):
	if area.is_in_group("loot"):
		var gem_exp = area.collect()
		calculate_experience(gem_exp)
	
func calculate_experience(gem_exp):
	var exp_required = calculate_experiencecap()
	collected_experience += gem_exp
	if experience + collected_experience > exp_required:
		collected_experience -= exp_required - experience
		experience_level += 1
		experience = 0
		exp_required = calculate_experiencecap()
		levelup()
		calculate_experience(0)
	else:
		experience += collected_experience
		collected_experience = 0
		
	set_exp_bar(experience,exp_required)
	
func calculate_experiencecap():
	var exp_cap = experience_level
	if experience_level < 20:
		exp_cap = experience_level*5
	elif experience_level < 40:
		exp_cap = 95 + (experience_level - 19) * 8
	else:
		exp_cap  = 255 + (experience_level - 39) * 12
	return exp_cap
		
func set_exp_bar(set_value = 1,set_max_value = 100):
	expBar.value = set_value
	expBar.max_value = set_max_value

func levelup():
	snd_levelup.play()
	lblLevel.text = str("Level:",experience_level)
	var tween = levelPanel.create_tween()
	tween.tween_property(levelPanel,"position",Vector2(220,50),0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.play()
	levelPanel.visible = true
	
	var options = 0
	var optionsmax = 3
	while options < optionsmax:	
		var option_choice  = itemOptions.instantiate()
		upgradeOption.add_child(option_choice)
		options += 1
		
	get_tree().paused = true
	
func upgrade_character(upgrade):
	var option_children = upgradeOption.get_children()
	for i in option_children:
		i.queue_free()
	levelPanel.visible = false
	levelPanel.position = Vector2(800,50)
	get_tree().paused = false
	calculate_experience(0)
