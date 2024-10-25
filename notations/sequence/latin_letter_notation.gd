## Use the Latin Alphabet as a sequence (~a-zA-Z)
class_name LatinLetterNotation
extends BaseSequenceNotation

func _init(prefixed: bool = false) -> void:
	super("~abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", prefixed)
