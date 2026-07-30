class_name PlayerStateJump extends PlayerState

@onready var fire_boots_anim: AnimatedSprite2D = %FireBootsAnim

func enter() -> void:
	fire_boots_anim.visible = true
	fire_boots_anim.play("enable")
	player.player_anim.play("jump")
	
	
func exit() -> void:
	fire_boots_anim.visible = false
	

func physics_process(_delta: float) -> PlayerState:
	player.velocity.x = player.move_dir.x * player.DEFAULT_RUN_SPEED
	if player.move_dir.y < 0:
		player.velocity.y = player.move_dir.y * player.DEFAULT_HOVER_SPEED
		return null
	else:
		return get_node("../Fall")
			
