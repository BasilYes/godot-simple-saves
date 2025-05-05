class_name SSSettingsSave
extends SSSave


const BUS_PREFIX = "$bus_"
const VOLUME_POSTFIX = "_volume"
const MUTE_POSTFIX = "_mute"
const LANGUAGE_KEY = "$user_locale"


func _ready():
	data_loaded.connect(func() -> void:
		var bus_name: String
		var volume: float
		var mute: bool
		for i in AudioServer.bus_count:
			bus_name = BUS_PREFIX + AudioServer.get_bus_name(i) + VOLUME_POSTFIX
			if _data.has(bus_name):
				volume = _data[bus_name]
				AudioServer.set_bus_volume_db(i, linear_to_db(volume))
				AudioServer.set_bus_mute(i, not volume)
			bus_name = BUS_PREFIX + AudioServer.get_bus_name(i) + MUTE_POSTFIX
			if _data.has(bus_name):
				mute = _data[bus_name]
				AudioServer.set_bus_mute(i, mute and db_to_linear(AudioServer.get_bus_volume_db(i)))
		if _data.has(LANGUAGE_KEY):
			TranslationServer.set_locale(_data[LANGUAGE_KEY])
	)
	super()


func _select_storage_type() -> void:
	_storage_type = StorageType.FILE


func save_volume(bus_name: String, value: float) -> void:
	var bus_id: int = AudioServer.get_bus_index(bus_name)
	if bus_id == -1:
		push_warning("No sound bus named " + bus_name, "\n", get_stack())
		return
	AudioServer.set_bus_volume_db(bus_id, linear_to_db(value))
	AudioServer.set_bus_mute(bus_id, not value)
	save_value(BUS_PREFIX + bus_name + VOLUME_POSTFIX, value, true)


func load_volume(bus_name: String) -> float:
	return await load_value(BUS_PREFIX + bus_name + VOLUME_POSTFIX, 1.0)


func save_mute_volume(bus_name: String, mute: bool) -> void:
	var bus_id: int = AudioServer.get_bus_index(bus_name)
	if bus_id == -1:
		push_warning("No sound bus named " + bus_name, "\n", get_stack())
		return
	AudioServer.set_bus_mute(bus_id, mute and db_to_linear(AudioServer.get_bus_volume_db(bus_id)))
	save_value(BUS_PREFIX + bus_name + MUTE_POSTFIX, mute, true)


func load_mute_volume(bus_name: String) -> bool:
	return await load_value(BUS_PREFIX + bus_name + MUTE_POSTFIX, false)

func save_locale(code: String) -> void:
	if not code or code == TranslationServer.get_locale():
		return
	else:
		_data[LANGUAGE_KEY] = code
		TranslationServer.set_locale(code)

func load_locale() -> String:
		return await load_value(LANGUAGE_KEY, TranslationServer.get_locale())
