class_name Player extends CharacterBody2D


@onready var player_anim: AnimatedSprite2D = $PlayerAnim


#region /// State Machine Variables

var current_state: PlayerState = null
@onready var states_machine_container: Node = $States
const BUFFER_STATES: Array[String] = ["Fall"]

#endregion


#region /// 物理参数

const DEFAULT_RUN_SPEED: float = 50
const DEFAULT_GRAVITATIONAL_ACCELERATION: float = 980.0 * 0.5
const DEFAULT_HOVER_SPEED: float = -80.0 

var is_falling_off_ledge: bool = false
#endregion

#全局锁
var  input_locked: bool = false
var move_input: float = 0.0


func  _ready() -> void:
	initialize_states()
	pass
	
	
func _process(_delta: float) -> void:
	if current_state:
		var next_state = current_state.process(_delta)
		if next_state != null:
			change_state(next_state)
	pass
	
	
func _physics_process(_delta: float) -> void:
	if input_locked:
		move_input = 0.0
	else:
		move_input = Input.get_axis("move_left", "move_right")
		
	velocity.y += DEFAULT_GRAVITATIONAL_ACCELERATION * _delta
	
	move_and_slide()
	
	if current_state:
		var next_state = current_state.physics_process(_delta)
		move_and_slide()
		if next_state != null:
			change_state(next_state)
			
	if player_anim:
		if velocity.x != 0:
			player_anim.flip_h = velocity.x > 0
	pass


func initialize_states() -> void:
	#收集所有子状态并注入 player 引用
	for child in states_machine_container.get_children():
		if child is PlayerState:
			child.player = self
			child.init()
	#默认进入第一个状态
	if states_machine_container.get_child_count() > 0:
		current_state = states_machine_container.get_child(0)
		current_state.enter()
		
		
func change_state(new_state:PlayerState) -> void:
	if new_state == null:
		print("⚠️ change_state 收到 null，忽略")
		return
	if new_state == current_state:
		print("ℹ️ 尝试切换到当前状态 [", current_state.name, "]，已忽略")
		return
		
	var from_name = "NULL"
	if current_state:
		from_name = current_state.name
	var to_name = new_state.name
	
	if current_state != null and from_name == "Jump" and to_name in ["Idle", "Run"]:
		if from_name in BUFFER_STATES:
			push_error("⭕ 异常切换 [状态机] ", from_name, " -> ", to_name, " （跳过了必要的过渡状态）")
	
	print("🔄 [状态机] ", from_name, " -> ", to_name)
	
	if current_state:
		current_state.exit()
		
	current_state = new_state
	current_state.enter()


func apply_animation_stun(anim_name: String, target_state: PlayerState = null) -> void:
	if input_locked:
		return
	
	input_locked = true
	player_anim.play(anim_name)
	
	await  player_anim.animation_finished
	
	input_locked = false
	
	if target_state != null:
		change_state(target_state)
