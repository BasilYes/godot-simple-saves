class_name SSSave
extends Node


signal data_loaded
signal data_saved
signal value_saved(key: String)


enum StorageType {
	FILE = 0,
	YANDEX_GAMES_STATS = 1,
	YANDEX_GAMES_DATA = 2,
}

var _storage_type: StorageType = StorageType.FILE
var _storage_singleton: Node = null
var _data: Dictionary = {}
var _file_path: String = ""
var _is_loading: bool = false


func _ready() -> void:
	_select_storage_type()
	print("init storage ", name, " type ", StorageType.keys()[_storage_type])
	match _storage_type:
		StorageType.FILE:
			_file_path = "user://{}.save".format([ name ], "{}")
		StorageType.YANDEX_GAMES_STATS:
			_storage_singleton = get_node("/root/YandexSDK")
			if not _storage_singleton.is_node_ready():
				await _storage_singleton.ready
			_storage_singleton.init_game()
			_storage_singleton.init_player()
		StorageType.YANDEX_GAMES_DATA:
			_storage_singleton = get_node("/root/YandexSDK")
			if not _storage_singleton.is_node_ready():
				await _storage_singleton.ready
			_storage_singleton.init_game()
			_storage_singleton.init_player()
	_load_data()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_data()


func _select_storage_type() -> void:
	if has_node("/root/YandexSDK") and get_node("/root/YandexSDK").is_working():
		if name.to_lower().contains("stats"):
			_storage_type = StorageType.YANDEX_GAMES_STATS
		else:
			_storage_type = StorageType.YANDEX_GAMES_DATA
		return
	_storage_type = StorageType.FILE


func save_value(key: String, value: Variant, immediate: bool = true) -> void:
	_data[key] = value
	if immediate:
		_save_data()
	value_saved.emit(key)


## Increment saved value, use with numbers (float/int) only
func increment_value(key: String, value: Variant, immediate: bool = true) -> Variant:
	_data[key] = value + _data.get(key, 0)
	match _storage_type:
		StorageType.YANDEX_GAMES_STATS:
			_storage_singleton.increment_stats({key: value})
		_:
			if immediate:
				_save_data()
	value_saved.emit(key)
	return _data[key]


func load_value(key: String, default: Variant = null) -> Variant:
	if _is_loading:
		await data_loaded
	return _data.get(key, default)


# TODO add support for save and load vec2 and vec3
# func save_vec3(key: String, value: Vector3, immediate: bool = true) -> void:
# 	_data[key] = [
# 		value.x,
# 		value.y,
# 		value.z,
# 	]
# 	if immediate:
# 		_save_data()
# 	value_saved.emit(key)


# func load_vec3(key: String, default: Vector3) -> Vector3:
# 	var out = _data.get(key)
# 	if out is Array:
# 		default.x = out[0]
# 		default.y = out[1]
# 		default.z = out[2]
# 	return default


# func save_vec2(key: String, value: Vector2, immediate: bool = true) -> void:
# 	_data[key] = [
# 		value.x,
# 		value.y,
# 	]
# 	if immediate:
# 		_save_data()
# 	value_saved.emit(key)


# func load_vec2(key: String, default: Vector2) -> Vector2:
# 	var out = _data.get(key)
# 	if out is Array:
# 		default.x = out[0]
# 		default.y = out[1]
# 	return default


func _save_data() -> void:
	if not _data:
		return
	match _storage_type:
		StorageType.FILE:
			var file:= FileAccess.open(_file_path, FileAccess.WRITE)
			file.store_string(JSON.stringify(_data, "\t"))
		StorageType.YANDEX_GAMES_STATS:
			_storage_singleton.save_stats(_data)
		StorageType.YANDEX_GAMES_DATA:
			_storage_singleton.save_data(_data)


func _load_data() -> void:
	match _storage_type:
		StorageType.FILE:
			if FileAccess.file_exists(_file_path):
				var file: = FileAccess.open(_file_path, FileAccess.READ)
				var data: Variant = JSON.parse_string(file.get_as_text())
				if data is Dictionary:
					_data = data
					data_loaded.emit()
		StorageType.YANDEX_GAMES_STATS:
			_is_loading = true
			_storage_singleton.load_all_stats()
			_data.merge(await _storage_singleton.stats_loaded, true)
			_is_loading = false
			data_loaded.emit()
		StorageType.YANDEX_GAMES_DATA:
			_is_loading = true
			_storage_singleton.load_all_data()
			_data.merge(await _storage_singleton.data_loaded, true)
			_is_loading = false
			data_loaded.emit()
