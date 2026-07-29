class_name PlayerStateJump extends PlayerState

@onready var fire_boots_anim: AnimatedSprite2D = %FireBootsAnim

func enter() -> void:
	fire_boots_anim.visible = true
	fire_boots_anim.play("enable")
	
	
func exit() -> void:
	fire_boots_anim.visible = false
	

func physics_process(_delta: float) -> PlayerState:
	var move_dir = player.move_input
	if move_dir != 0:
		player.velocity.x = move_dir * player.DEFAULT_RUN_SPEED
	else:
		player.velocity.x = 0
	
	if Input.is_action_pressed("jump"):
		player.velocity.y = player.DEFAULT_HOVER_SPEED
		return null
	if not Input.is_action_pressed("jump"):
			return get_node("../Fall")
			
	return null
