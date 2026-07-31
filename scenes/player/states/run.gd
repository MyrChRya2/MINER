class_name PlayerStateRun extends PlayerState


func enter() -> void:
	player.player_anim.play("run")
	
	
func physics_process(_delta: float) -> PlayerState:
	var move_dir = player.move_dir.x
	if move_dir != 0:
		player.velocity.x = player.move_dir.x * player.DEFAULT_RUN_SPEED
	elif player.is_on_floor():
		return get_node("../Idle")
		
	if Input.is_action_just_pressed("jump"):
		return get_node("../Jump")
		
	if not player.is_on_floor() and player.velocity.y >= 0:
		player.is_falling_off_ledge = true
		return get_node("../Fall")

	return null
