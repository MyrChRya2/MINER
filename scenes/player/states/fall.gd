class_name PlayerStateFall extends PlayerState


var fall_timer: float = 0.0
var is_landing: bool = false

func enter() -> void:
	fall_timer = 0.0
	is_landing = false
	player.player_anim.play("fall_start")
	
	
func physics_process(_delta: float) -> PlayerState:
	var move_dir = player.move_input
	if move_dir != 0:
		player.velocity.x = move_dir * player.DEFAULT_RUN_SPEED
	else:
		player.velocity.x = 0
		
	fall_timer += _delta
	
	if Input.is_action_just_pressed("jump"):
		return get_node("../Jump")
	
	if not player.is_on_floor() and fall_timer > 0.2:
		if player.player_anim.animation == "fall_start":
			player.player_anim.play("fall")
		
	if player.is_on_floor():
		var LANDING_THRESHOLD = 0.6
		
		if fall_timer > LANDING_THRESHOLD:
			if not is_landing:
				is_landing = true
				var target_state = get_node("../Idle")
				player.apply_animation_stun("fall_end", target_state)
				return null
		else:
			if move_dir != 0:
				return get_node("../Run")
			else:
				return get_node("../Idle")
	return null
