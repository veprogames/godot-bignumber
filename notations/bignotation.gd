@icon("uid://cv86jxknw1m7j")

## Base class for all Notations that format a [BigNumber]
class_name BigNotation
extends RefCounted

func _init() -> void:
	pass

## The "Name" Part of the formatted Number (e. g. "Trillion", "aa")
func get_suffix(_n: BigNumber) -> String:
	return ""

## The Mantissa Part of the formatted Number (e. g. 123.45)
func get_number(_n: BigNumber, _precision: int = 0) -> String:
	return ""

## The Sign of the formatted Number ("-" if negative)
func get_sign(n: BigNumber) -> String:
	return "-" if n.lt(0) else ""

## A human readable name (e. g. "My Notation")
func get_pretty_name() -> String:
	return ""

## Return a formatted String from a [BigNumber]
## Construct the Number from [method get_number] and [method get_suffix]
func F(n: BigNumber, precision: int = 0) -> String:
	var n_abs: BigNumber = n.Abs()
	return "%s%s%s" % [get_sign(n), get_number(n_abs, precision), get_suffix(n_abs)]
