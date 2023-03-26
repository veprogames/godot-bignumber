class_name BigNotation
extends RefCounted

func _init():
	pass

func get_suffix(_n: BigNumber) -> String:
	return ""

func get_number(_n: BigNumber) -> String:
	return ""

func F(n: BigNumber) -> String:
	return "%s%s" % [get_number(n), get_suffix(n)]
