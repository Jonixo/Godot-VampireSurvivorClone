extends Timer

@export_enum("Cooldown","HıtOnce","DisableHitBox") var HurtBoxType = 0

@onready var collission = $CollisionShape2d
@onready var disableTimer = $DisableTimer

signal hurt(damage) ##To detect if a  area entered to a different area
