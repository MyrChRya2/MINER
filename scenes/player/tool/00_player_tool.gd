@icon("res://scenes/player/tool/tool.svg")
class_name PlayerTool extends Node2D


@export var tool_name: String = "Tool"
@export var show_when_select: bool = true

var is_active: bool = false
var is_using: bool = false


func activate() -> void:
	is_active = true
	if show_when_select:
		visible = true
	
	
func deactivate() -> void:
	is_active = false
	visible = false
	if is_using:
		stop_use()
		
		
func can_use(_player: Player) -> bool:
	return true
	
	
func start_use() -> void:
	if not is_active or is_using:
		return
		
	if not show_when_select:
		visible = true
		
	is_using = true
	
	_on_use_start()
	
	
func stop_use() -> void:
	if not is_using:
		return
		
	if not show_when_select:
		visible = false
	is_using = false
	_on_use_stop()
	
	
func _on_use_start() -> void:
	pass
	
	
func _on_use_stop() -> void:
	pass
	
	
func update_facing(_facing_right: bool) -> void:
	pass
	

func handle_down_input(_pressed: bool, _facing_right: bool) -> void:
	pass
	
	
func process(_delta: float) -> void:
	pass
	
	
func physics_process(_delta: float) -> void:
	pass
