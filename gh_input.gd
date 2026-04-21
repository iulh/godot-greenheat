extends RefCounted
class_name GreenHeatInput

var _packet: Variant

enum InputType {
	UNKNOWN,
	CLICK,
	HOVER,
	DRAG,
	RELEASE
}

func _string_to_type_enum(type: String):
	match type:
		"click": return InputType.CLICK
		"hover": return InputType.HOVER
		"drag": return InputType.DRAG
		"release": return InputType.RELEASE
		_: return InputType.UNKNOWN

var mobile: bool:
	get():
		return _packet["mobile"]
var position: Vector2:
	get():
		return Vector2(_packet["x"], _packet["y"])
var button: String:
	get():
		return _packet["button"]
var is_shift_pressed: bool:
	get():
		return _packet["shift"]
var is_ctrl_pressed: bool:
	get():
		return _packet["ctrl"]
var is_alt_pressed: bool:
	get():
		return _packet["alt"]
var time: float:
	get():
		return _packet["time"]
var latency: float:
	get():
		return _packet["latency"]
var type: InputType:
	get():
		return _string_to_type_enum(_packet["type"])
var id: String:
	get():
		return _packet["id"]
var is_anonymous: bool:
	get():
		return _packet["isAnonymous"]

func  to_string():
	return "<GHI:%s_%s>" % [type, id]
