class_name PlayerToolDrill extends PlayerTool


@onready var anim: AnimatedSprite2D = %DrillAnim
	
var original_offset: Vector2
var facing_right: bool = true


func can_use(_player: Player) -> bool:
	return _player.is_on_floor()

func _on_use_start() -> void:
	anim.play("enable")
	print("钻头启动！")

	
func _on_use_stop() -> void:
	anim.stop()
	anim.frame = 0
	print("钻头停止")

func process(_delta: float) -> void:
	if Input.is_action_pressed("down"):
		anim.rotation = PI/2 if facing_right else -PI/2
	else:
		anim.rotation = 0.0


func update_facing(new_facing: bool) -> void:
	anim.flip_h = facing_right
	facing_right = new_facing
	anim.position.x = abs(original_offset.x) if facing_right else -abs(original_offset.x)
	
