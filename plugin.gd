@tool
extends EditorPlugin


func _enable_plugin() -> void:
	add_autoload_singleton("SimpleSaves", "simple_saves.gd")
	add_autoload_singleton("SettingsSaves","settings_saves.gd")


func _disable_plugin() -> void:
	remove_autoload_singleton("SimpleSaves")
	remove_autoload_singleton("SettingsSaves")
