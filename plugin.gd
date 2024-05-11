@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("SimpleSaves", "res://addons/simple_saves/simple_saves.gd")
	add_autoload_singleton("SettingsSaves","res://addons/simple_saves/settings_saves.gd")


func _exit_tree() -> void:
	remove_autoload_singleton("SimpleSaves")
	remove_autoload_singleton("SettingsSaves")
