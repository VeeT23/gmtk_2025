extends StaticBody2D

@export var start_day = 0
@export var end_day = 0

func _ready() -> void:
	visible = false
	$CollisionShape2D.disabled = true


func new_day(day : int):
	if day <= end_day and day >= start_day:
		print(self, " Enabled")
		visible = true
		$CollisionShape2D.disabled = false
	else:
		print(self, " Disabled")
		visible = false
		$CollisionShape2D.disabled = true
