extends Node

signal chapter_changed(chapter: int)
signal level_changed(level: int)
signal coins_changed(value: int)

var current_chapter := 0
var current_level := 0

var coins := 0
var score := 0
var stars := {}


func _ready() -> void:

	# پیش‌فرض:
	current_chapter = 0
	current_level = 0


func set_chapter(chapter: int):

	current_chapter = chapter
	current_level = 0

	chapter_changed.emit(
		current_chapter
	)

	level_changed.emit(
		current_level
	)


func set_level(
	chapter: int,
	level: int
):

	current_chapter = chapter
	current_level = level

	chapter_changed.emit(
		current_chapter
	)

	level_changed.emit(
		current_level
	)


func add_coin(value: int):

	coins += value

	coins_changed.emit(
		coins
	)


func remove_coin(value: int):

	coins = max(
		0,
		coins - value
	)

	coins_changed.emit(
		coins
	)


func reset_game():

	current_chapter = 0
	current_level = 0

	coins = 0
	score = 0
	stars.clear()

	SaveManager.reset_save()

	chapter_changed.emit(
		current_chapter
	)

	level_changed.emit(
		current_level
	)

	coins_changed.emit(
		coins
	)
