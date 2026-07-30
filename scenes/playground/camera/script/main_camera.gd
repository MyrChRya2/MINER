extends Camera2D


@onready var player: Player = $"../Player"

@onready var camera_anchor: Marker2D = $CameraAnchor

#region /// PD ctrl

@export var kp: float = 10.0
@export var kd: float = 2.0
@export var max_acce: float = 1000.0
@export var max_speed: float = 500

#endregion

@export var hard_lock_thld: float = 1
@export var dynamic_damping: bool = true

# 内部状态
var camera_vel: Vector2 = Vector2.ZERO
var prev_error_pos: Vector2 = Vector2.ZERO
var prev_vel: Vector2 = Vector2.ZERO
var is_docked: bool = false

func _ready() -> void:
	#current_limit_rect = get_tree().current_scene.get_node("MapMetadata").get_room_rect()
	pass
	
func _process(_delta: float) -> void:
	if not player:
		return
		
	var target_pos = player.global_position
	var anchor = player.get_node("PlayerAnchor") as Marker2D
	if anchor:
		target_pos = anchor.global_position
		
	# 当前位置误差
	var error_pos = target_pos - global_position
	var error_dis = error_pos.length()
	
	# 硬锁判定
	if is_docked:
		if error_dis > hard_lock_thld * 2:
			is_docked = false
			camera_vel = player.velocity * 0.5
		else:
			global_position = target_pos
			camera_vel = player.velocity
			_update_debug_data(_delta)
			return
	
	
	# PD控制
	if error_dis < hard_lock_thld:
		is_docked = true
		global_position = target_pos
		camera_vel = player.velocity
		_update_debug_data(_delta)
		return
		
		
	# 计算微分项
	var error_derivative = (error_pos - prev_error_pos) / _delta
	prev_error_pos = error_pos
	
	var adj_kd = kd
	if dynamic_damping:
		var dis_factor = clamp(1.0 - error_dis / 200, 0.0, 1.0)
		adj_kd = kd * (1.0 + dis_factor * 2.0)
		
	
	var aimed_vel = player.velocity + (error_pos * kp) + (error_derivative * adj_kd)
	aimed_vel = aimed_vel.limit_length(max_speed)
	
	camera_vel = camera_vel.move_toward(aimed_vel, max_acce * _delta)
	
	if camera_vel.dot(error_pos) < 0:
		camera_vel = camera_vel.move_toward(aimed_vel, max_acce * 2 * _delta)
		
	global_position = global_position + camera_vel * _delta
	
	if camera_anchor:
		camera_anchor.global_position = global_position
		
	_update_debug_data(_delta)
	
	
func _update_debug_data(_delta: float):
	if DebugManager:
		var accel = (camera_vel - prev_vel).length() / (_delta if _delta > 0 else 0.001)
		DebugManager.set_value("camera_vel", camera_vel.length())
		DebugManager.set_value("camera_accel", accel)
		DebugManager.set_value("is_hard_locked", is_docked)
	prev_vel = camera_vel
