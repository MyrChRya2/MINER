extends CanvasLayer


@onready var container: VBoxContainer = $Panel/VBoxContainer


var _label_map: Dictionary = {}


func _ready() -> void:
	visible = true
	_sync_all_data()
	
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_F3:
		visible = !visible
		
		
func _process(_delta: float) -> void:
	if not visible:
		return
	_sync_all_data()
	
	
func _sync_all_data() -> void:
	var all_data = DebugManager.get_all_data()
	
	for key in all_data:
		var value = all_data[key]
		
		var label = _label_map.get(key)
		if not _label_map.has(key):
			label = Label.new()
			label.name = key
			label.text = str(key) + ": " + str(value)
			container.add_child(label)
			_label_map[key] = label
		
		if value is float:
			label.text = key + ": " + str(value).pad_decimals(2)
		else:
			label.text = str(key) + ": " + str(value)
