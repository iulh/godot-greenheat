@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_custom_type("GreenHeat", "Node", preload("res://addons/green_heat/green_heat.gd"), preload("res://addons/green_heat/green_heat.png"))


func _exit_tree() -> void:
	remove_custom_type("GreenHeat")
