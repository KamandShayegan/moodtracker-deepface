@tool
extends EditorScript

func _run() -> void:
	var regex = RegEx.new()
	regex.compile("[a-z]+")
	var test_string = 'aosfhiSSFHA92\n'
	print(regex.search(test_string.to_lower()).get_string())
