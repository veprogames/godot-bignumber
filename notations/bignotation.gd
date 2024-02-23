@icon("res://godot-bignumber/notation.png")

## Base class for all Notations that format a [BigNumber]
class_name BigNotation
extends RefCounted

func _init():
	pass

## The "Name" Part of the formatted Number (e. g. "Trillion", "aa")
func get_suffix(_n: BigNumber) -> String:
	return ""

## The Mantissa Part of the formatted Number (e. g. 123.45)
func get_number(_n: BigNumber) -> String:
	return ""

## A human readable name (e. g. "My Notation")
func get_pretty_name() -> String:
	return ""

## Return a formatted String from a [BigNumber]
## Construct the Number from [method get_number] and [method get_suffix]
func F(n: BigNumber) -> String:
	return "%s%s" % [get_number(n), get_suffix(n)]
