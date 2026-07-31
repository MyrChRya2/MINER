class_name PlayerStateFall extends PlayerState


var is_landing: bool = false
@export var LANDING_THRESHOLD: float = 0.5

func enter() -> void:
	player.fall_timer = 0.0
	player.player_anim.play("fall_start")
	
	
func physics_process(_delta: float) -> PlayerState:
	player.velocity.x = player.move_dir.x * player.DEFAULT_RUN_SPEED
	
	if player.move_dir.y != 0 and not player.input_locked:
		return get_node("../Jump")
	
	if player.velocity.y >= 0:
		player.fall_timer += _delta
	
	if not player.is_on_floor() and player.fall_timer > 0.2:
		if player.player_anim.animation == "fall_start":
			player.player_anim.play("fall")
			
	if player.is_on_floor():
		if player.fall_timer >LANDING_THRESHOLD:
			return get_node("../HardLand")
		else:
			if player.move_dir.x != 0:
				return get_node("../Run")
			else:
				return get_node("../Idle")
	return null
