class_name SSSoundSlider
extends HSlider


@export var bus_name: String = "Master"


func _ready() -> void:
	max_value = 1.0
	step = 0.001
	value_changed.connect(func(val: float) -> void:
		SettingsSaves.save_volume(bus_name, val)
	)
	value = await SettingsSaves.load_volume(bus_name)
