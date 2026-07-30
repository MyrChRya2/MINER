class_name Player extends CharacterBody2D


@onready var player_anim: AnimatedSprite2D = $PlayerAnim
@onready var fall_timer_labe: Label = %FallTimerLabe

var fall_timer: float = 0.0

#region /// State Machine Variables

var current_state: PlayerState = null
@onready var states_machine_container: Node = $States
const BUFFER_STATES: Array[String] = ["Fall"]

#endregion


#region /// 物理参数

const DEFAULT_RUN_SPEED: float = 50
const DEFAULT_GRAVITATIONAL_ACCELERATION: float = 980.0 * 0.5
const DEFAULT_HOVER_SPEED: float = 80.0 

var is_falling_off_ledge: bool = false
#endregion

# 全局锁
var  input_locked: bool = false
var move_dir: Vector2 = Vector2.ZERO


# 摄像机偏移
@export var DEFAULT_CAMARA_SHIFT: float = 20.0


func  _ready() -> void:
	initialize_states()
	pass
	
	
func _process(_delta: float) -> void:
	if current_state:
		var next_state = current_state.process(_delta)
		if next_state != null:
			change_state(next_state)
			
	fall_timer_labe.text = str(fall_timer).pad_decimals(2)
	pass
	
	
func _physics_process(_delta: float) -> void:
	if input_locked:
		move_dir = Vector2.ZERO
	else:
		var input_h = Input.get_axis("move_left", "move_right")
		var input_v = -1.0 if Input.is_action_pressed("jump") else 0.0
		move_dir = Vector2(input_h, input_v)
		
	velocity.y += DEFAULT_GRAVITATIONAL_ACCELERATION * _delta
	
	velocity = velocity.round()
	
	move_and_slide()
	
	if current_state:
		var next_state = current_state.physics_process(_delta)
		move_and_slide()
		if next_state != null:
			change_state(next_state)
			
	position = position.round()
			
	if player_anim and velocity.x != 0:
		player_anim.flip_h = velocity.x > 0
		if has_node("PlayerAnchor"):
			var anchor = get_node("PlayerAnchor")
			if player_anim.flip_h:
				anchor.position = Vector2(DEFAULT_CAMARA_SHIFT, 0)
			else:
				anchor.position = Vector2(-DEFAULT_CAMARA_SHIFT, 0)
				
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


func apply_animation_stun(duration: float, anim_name: String = "") -> void:
	if input_locked:
		return
	
	input_locked = true
	
	if anim_name != "":
		player_anim.play(anim_name)
	await  get_tree().create_timer(duration).timeout
	
	input_locked = false
	
	change_state($States/Idle)
