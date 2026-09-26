extends Node

signal word_correct(word:String)
signal word_wrong(word:String)
signal word_already_found(word:String)
signal level_completed()

var answers: Array = []
var solved_words: Array = []

func setup(level_answers: Array):
	answers = level_answers.duplicate()
	solved_words.clear()


func submit_word(word: String) -> bool:
	
	word = word.strip_edges()
	
	if word.is_empty():
		return false

	if !answers.has(word):
		word_wrong.emit(word)
		return false

	if solved_words.has(word):
		word_already_found.emit(word)
		return false

	solved_words.append(word)

	word_correct.emit(word)


	if solved_words.size() == answers.size():
		level_completed.emit()

	return true


func reset():
	answers = []
	solved_words = []

func get_total_answers() -> int:
	return answers.size()


func get_found_answers() -> int:
	return solved_words.size()


func is_level_completed() -> bool:
	return solved_words.size() == answers.size()


func has_word(word: String) -> bool:
	return answers.has(word)
