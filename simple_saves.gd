class_name SSSave
extends Node


signal data_loaded
signal data_saved
signal value_saved(key: String)


enum StorageType {
	LOCAL_STORAGE = 0,
}

var _storage_type: StorageType = StorageType.LOCAL_STORAGE
var _data: Dictionary = {}
var _save_file: String :
	set(value):
		_save_data()
		_save_file = value
		_load_data()


func _ready() -> void:
	match _storage_type:
		StorageType.LOCAL_STORAGE:
			_save_file = "user://{}.save".format([ name ], "{}")
		_:
			return


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_data()


func save_value(key: String, value: Variant, immediate: bool = true) -> void:
	_data[key] = value
	if immediate:
		_save_data()
	value_saved.emit(key)


func load_value(key: String, default: Variant = null) -> Variant:
	return _data.get(key, default)


func save_vec3(key: String, value: Vector3, immediate: bool = true) -> void:
	_data[key] = [
		value.x,
		value.y,
		value.z,
	]
	if immediate:
		_save_data()
	value_saved.emit(key)


func load_vec3(key: String, default: Vector3) -> Vector3:
	var out = _data.get(key)
	if out is Array:
		default.x = out[0]
		default.y = out[1]
		default.z = out[2]
	return default


func save_vec2(key: String, value: Vector2, immediate: bool = true) -> void:
	_data[key] = [
		value.x,
		value.y,
	]
	if immediate:
		_save_data()
	value_saved.emit(key)


func load_vec2(key: String, default: Vector2) -> Vector2:
	var out = _data.get(key)
	if out is Array:
		default.x = out[0]
		default.y = out[1]
	return default


func _save_data() -> void:
	if not _data:
		return
	var file:= FileAccess.open(_save_file, FileAccess.WRITE)
	file.store_string(JSON.stringify(_data, "\t"))


func _load_data() -> void:
	if FileAccess.file_exists(_save_file):
		var file: = FileAccess.open(_save_file, FileAccess.READ)
		var data: Variant = JSON.parse_string(file.get_as_text())
		if data is Dictionary:
			_data = data
			data_loaded.emit()
