class_name PlayerStateRun extends PlayerState


func enter() -> void:
	player.player_anim.play("run")
	
	
func physics_process(_delta: float) -> PlayerState:
	var move_dir = player.move_input
	if move_dir != 0:
		player.velocity.x = move_dir * player.DEFAULT_RUN_SPEED
	elif player.is_on_floor():
		return get_node("../Idle")
		
	if Input.is_action_just_pressed("jump"):
		return get_node("../Jump")
	return null
