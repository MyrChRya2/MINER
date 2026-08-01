class_name Player extends CharacterBody2D


@onready var player_anim: AnimatedSprite2D = $PlayerAnim

var fall_timer: float = 0.0

#region /// State Machine Variables

var current_state: PlayerState = null
@onready var states_machine_container: Node = $States
const BUFFER_STATES: Array[String] = ["Fall"]

#endregion

#region /// Tools Varriables

@onready var tool_container: Node = $Tool
var current_tool_index: int = 0
var tool_list: Array[PlayerTool] = []

#endregion

#region /// 物理参数

const DEFAULT_RUN_SPEED: float = 100.0
const DEFAULT_GRAVITATIONAL_ACCELERATION: float = 980.0 * 0.4
const DEFAULT_HOVER_SPEED: float = 120.0 

var is_falling_off_ledge: bool = false

#endregion

# 全局锁
var  input_locked: bool = false
var move_dir: Vector2 = Vector2.ZERO


# 摄像机偏移
@export var DEFAULT_CAMARA_SHIFT: float = 20.0


var facing_right: bool = true


func  _ready() -> void:
	initialize_states()
	_discover_tools()
	_activate_current_tool()
	pass
	
	
func _process(_delta: float) -> void:
	if current_state:
		var next_state = current_state.process(_delta)
		if next_state != null:
			change_state(next_state)
	
	_handle_tool_input()
	
	tool_list[current_tool_index].process(_delta)
	if not tool_list.is_empty():
		tool_list[current_tool_index].update_facing(facing_right)
		
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
	
	
	if current_state:
		var next_state = current_state.physics_process(_delta)
		move_and_slide()
		if next_state != null:
			change_state(next_state)
			
	position = position.round()
			
	if velocity.x != 0:
		facing_right = velocity.x > 0
		player_anim.flip_h = facing_right
		
		if has_node("PlayerAnchor"):
			var anchor = get_node("PlayerAnchor")
			anchor.position = Vector2(DEFAULT_CAMARA_SHIFT if facing_right else -DEFAULT_CAMARA_SHIFT, 0)
				

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
		
		
func _handle_tool_input() -> void:
	var tool = tool_list[current_tool_index] if not tool_list.is_empty() else null
	#if Input.is_action_just_pressed("next_tool"):
		#switch_tool(1)
	#elif Input.is_action_just_pressed("prev_tool"):
		#switch_tool(-1)
		
	if Input.is_action_pressed("use"):
		if tool_list.is_empty():
			push_error("使用工具失败: 当前没有可用工具")
			return
			
		if not tool.is_active:
			push_error("使用工具失败: 当前工具未激活 (索引 %d)" % current_tool_index)
			return
		
		if not tool.can_use(self):
			if tool.is_using:
				tool.stop_use()
			return
			
		tool.start_use()
		
	else:
		if not tool_list.is_empty() and current_tool_index < tool_list.size():
			tool_list[current_tool_index].stop_use()
			
		
		
	#if Input.is_action_just_pressed("down") or Input.is_action_just_released("down"):
		#if not tool_list.is_empty() and current_tool_index < tool_list.size():
			#tool_list[current_tool_index].handle_down_input(Input.is_action_pressed("down"), facing_right)
	pass
		

func _discover_tools() -> void:
	for child in tool_container.get_children():
		if child is PlayerTool:
			tool_list.append(child)
			child.deactivate()

		
func _activate_current_tool() -> void:
	if tool_list.is_empty():
		return
		
	for tool in tool_list:
		tool.deactivate()
		
	tool_list[current_tool_index].activate()


func switch_tool(direction: int) -> void:
	if tool_list.is_empty():
		return
	current_tool_index = (current_tool_index + direction) % tool_list.size()
	_activate_current_tool()
	

func apply_animation_stun(duration: float, anim_name: String = "") -> void:
	if input_locked:
		return
	
	input_locked = true
	
	if anim_name != "":
		player_anim.play(anim_name)
	await  get_tree().create_timer(duration).timeout
	
	input_locked = false
	
	change_state($States/Idle)
