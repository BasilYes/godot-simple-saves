class_name SSSettingsSave
extends SSSave


const BUS_PREFIX = "bus_"
const VOLUME_POSTFIX = "_volume"
const MUTE_POSTFIX = "_mute"


func _ready():
	data_loaded.connect(func() -> void:
		var bus_name: String
		var volume: float
		var mute: bool
		for i in AudioServer.bus_count:
			bus_name = BUS_PREFIX + AudioServer.get_bus_name(i) + VOLUME_POSTFIX
			if _data.has(bus_name):
				volume = _data[bus_name]
				AudioServer.set_bus_volume_db(i, (volume - 1.0) * 80.0)
				AudioServer.set_bus_mute(i, not volume)
			bus_name = BUS_PREFIX + AudioServer.get_bus_name(i) + MUTE_POSTFIX
			if _data.has(bus_name):
				mute = _data[bus_name]
				AudioServer.set_bus_mute(i, mute and AudioServer.get_bus_volume_db(i) > -80.0)
	)
	super()


func _select_storage_type() -> void:
	_storage_type = StorageType.FILE


func save_volume(bus_name: String, value: float) -> void:
	var bus_id: int = AudioServer.get_bus_index(bus_name)
	if bus_id == -1:
		push_warning("No sound bus named " + bus_name, "\n", get_stack())
		return
	var volume: float = (value - 1.0) * 80.0
	AudioServer.set_bus_volume_db(bus_id, volume)
	AudioServer.set_bus_mute(bus_id, not value)
	save_value(BUS_PREFIX + bus_name + VOLUME_POSTFIX, value, true)


func load_volume(bus_name: String) -> float:
	return await load_value(BUS_PREFIX + bus_name + VOLUME_POSTFIX, 1.0)


func save_mute_volume(bus_name: String, mute: bool) -> void:
	var bus_id: int = AudioServer.get_bus_index(bus_name)
	if bus_id == -1:
		push_warning("No sound bus named " + bus_name, "\n", get_stack())
		return
	AudioServer.set_bus_mute(bus_id, mute and AudioServer.get_bus_volume_db(bus_id) > -80.0)
	save_value(BUS_PREFIX + bus_name + MUTE_POSTFIX, mute, true)


func load_mute_volume(bus_name: String) -> bool:
	return await load_value(BUS_PREFIX + bus_name + MUTE_POSTFIX, false)
