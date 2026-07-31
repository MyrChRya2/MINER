class_name PlayerToolDrill extends PlayerTool


@onready var anim: AnimatedSprite2D = %DrillAnim
	
	
func _on_use_start() -> void:
	print("钻头启动！")
	anim.play("enable")

	
func _on_use_stop() -> void:
	anim.stop()
	anim.frame = 0
	print("钻头停止")
