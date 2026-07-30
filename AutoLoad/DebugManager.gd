extends Node


var _data: Dictionary = {}


signal  data_update(key: String, value: Variant)


func set_value(key: String, value: Variant):
	_data[key] = value
	data_update.emit(key, value)
	

func get_value(key: String) -> Variant:
	return _data.get(key)
	
	
func get_all_data() -> Dictionary:
	return _data.duplicate()
	
	
func clear() -> void:
	_data.clear()
