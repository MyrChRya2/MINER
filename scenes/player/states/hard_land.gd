class_name PlayerStateHardLand extends PlayerState


func enter() -> void:
	player.apply_animation_stun(0.5, "fall_end")


func physics_process(_delta: float) -> PlayerState:
	player.velocity = Vector2.ZERO
	
	return null
