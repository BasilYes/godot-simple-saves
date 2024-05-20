@tool
extends EditorPlugin


func _enable_plugin() -> void:
	add_autoload_singleton("SimpleSaves", "res://addons/simple_saves/simple_saves.gd")
	add_autoload_singleton("SettingsSaves","res://addons/simple_saves/settings_saves.gd")


func _disable_plugin() -> void:
	remove_autoload_singleton("SimpleSaves")
	remove_autoload_singleton("SettingsSaves")
