class_name ThousandSepNotation
extends BigNotation

func _init() -> void:
	super._init()

func get_number(n: BigNumber) -> String:
	var negative := n.lt(0)
	var n_str := "%.0f" % absf(n.as_float())
	var result = ""
	var c := 0
	for i in range(len(n_str) - 1, -1, -1):
		result = n_str[i] + result
		if c % 3 == 2 and i > 0:
			result = "," + result
		c += 1
	if negative:
		result = "-" + result
	return result
