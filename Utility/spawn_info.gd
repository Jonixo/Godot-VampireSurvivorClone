extends Resource

class_name Spawn_info ##custom class to use it in enemy spawn mechanics

@export var time_start:int
@export var time_end:int
@export var enemy:Resource
@export var enemy_num:int
@export var enemy_spawn_delay:int


var spawn_delay_counter = 0
