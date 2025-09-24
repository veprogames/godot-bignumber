class_name StandardNotation
extends BigNotation

const start: Array[String] = ["", "K", "M", "B", "T"]
const ones: Array[String] = ["", "U", "D", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No"]
const tens: Array[String] = ["", "Dc", "Vi", "Tg", "Qd", "Qg", "Sx", "Sp", "Og", "Ng"]
const hundreds: Array[String] = ["", "C", "DC", "TC", "QaC", "QiC", "SxC", "SpC", "OgC", "NoC"]


func _init() -> void:
	super._init()


func get_number(n: BigNumber, precision: int = 0) -> String:
	var mantissa_1000: float = n.m * 10 ** (n.e % 3)
	
	var format_string: String = "%%.%df" % precision
	return format_string % (mantissa_1000)


func get_suffix(n: BigNumber) -> String:
	@warning_ignore("integer_division")
	var index: int = n.e / 3
	if index < start.size():
		return start[index]
	
	index -= 1
	
	var one: String = ones[index % ones.size()]
	index /= 10
	var ten: String = tens[index % tens.size()]
	index /= 10
	var hundred: String = hundreds[index % hundreds.size()]
	
	@warning_ignore("integer_division")
	var thousand: int = int(index / 10)
	var thousand_string: String = ""
	if thousand > 0:
		thousand_string = "[%dMI]" % thousand if thousand > 1 else "MI"
	
	return thousand_string + hundred + one + ten
