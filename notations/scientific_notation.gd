class_name ScientificNotation
extends BigNotation


func _init() -> void:
	super._init()


func get_number(n: BigNumber, precision: int = 0) -> String:
	var format_string: String = "%%.%df" % precision
	return format_string % n.m


func get_suffix(n: BigNumber) -> String:
	return "e%d" % n.e
