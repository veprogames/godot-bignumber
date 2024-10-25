## A Sequenced Notation is A Notation where every set magnitude (1000), the next element is
## determined out of an n-based sequence
##
## e. g.
## Sequence := ~abcd
## 1 -> 1, 1_000 -> a, 1_000_000 -> b; c, d, a~, aa, ab; dd, a~~; ...
class_name BaseSequenceNotation
extends BigNotation

var sequence: PackedStringArray = PackedStringArray()

## [field sequence_] can be an Array of Strings or a single String, which will be split
## for each character
func _init(sequence_: Variant) -> void:
	super()
	
	assert(sequence_ is Array or sequence_ is String, 
		"[BigNumber] Sequence must be Array[String] or String")
	if sequence_ is Array:
		@warning_ignore("unsafe_call_argument") # sequence_ is Array
		self.sequence = PackedStringArray(sequence_)
	elif sequence_ is String:
		@warning_ignore("unsafe_method_access") # sequence_ is String
		self.sequence = sequence_.split()

## Calculate the Suffix
func get_sequence_for_number(n: BigNumber) -> String:
	var length: int = len(sequence)
	
	var result: String = ""
	@warning_ignore("integer_division")
	var remaining_units: int = n.e / 3
	
	while remaining_units > 0:
		var next_part: String = self.sequence[remaining_units % length]
		result = "%s%s" % [next_part, result]
		remaining_units /= length
	
	return result

## Note: Significant Digits go in the following form:
## 1.00, 10.0, 100, 999
func get_number(n: BigNumber, precision: int = 0) -> String:
	var mantissa_1000: float = n.m * 10 ** (n.e % 3)
	var significant_digits: int = 2 - (n.e % 3) + precision
	significant_digits = maxi(significant_digits, 0)
	
	var format_string: String = "%%.%df" % significant_digits
	return format_string % (mantissa_1000)

## Note: If the number is below +-1000, an empty Suffix is returned
func get_suffix(n: BigNumber) -> String:
	if n.e < 3:
		return ""
	return get_sequence_for_number(n)
