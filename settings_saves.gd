class_name SSSettingsSave
extends SSSave


const BUS_VOLUME_PREFIX = "bus_"
const BUS_VOLUME_POSTFIX = "_volume"


func _ready():
	data_loaded.connect(func() -> void:
		var bus_name: String
		var volume: float
		for i in AudioServer.bus_count:
			bus_name = BUS_VOLUME_PREFIX + AudioServer.get_bus_name(i) + BUS_VOLUME_POSTFIX
			if _data.has(bus_name):
				volume = _data[bus_name]
				AudioServer.set_bus_volume_db(i, (volume - 1.0) * 80.0)
				AudioServer.set_bus_mute(i, not volume)
	)
	super()


func save_volume(bus_name: String, value: float) -> void:
	var bus_id: int = AudioServer.get_bus_index(bus_name)
	if bus_id == -1:
		push_warning("No sound bus named " + bus_name, "\n", get_stack())
		return
	var volume: float = (value - 1.0) * 80.0
	AudioServer.set_bus_volume_db(bus_id, volume)
	AudioServer.set_bus_mute(bus_id, not value)
	save_value(BUS_VOLUME_PREFIX + bus_name + BUS_VOLUME_POSTFIX, value, true)


func load_volume(bus_name: String) -> float:
	return load_value(BUS_VOLUME_PREFIX + bus_name + BUS_VOLUME_POSTFIX, 1.0)
