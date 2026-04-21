@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_custom_type("GreenHeat", "Node", preload("green_heat.gd"), preload("green_heat.png"))


func _exit_tree() -> void:
	remove_custom_type("GreenHeat")
