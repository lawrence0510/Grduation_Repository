extends Node

func process_command(input: String):
	var words = input.split(" ", false)
	if words.size() == 0:
		return "ERRor: no words parsed"
	
	var first_word = words[0].to_lower()
	var second_word = ""
	if words.size() > 1:
		second_word = words[1].to_lower()
	
	match first_word:
		"go":
			return go(second_word)
		_:
			return "Unreconginzed"

func go(second_word: String) -> String:
	if second_word == "":
		return "go where?"
	return "you go to %s" % second_word
