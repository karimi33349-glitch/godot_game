extends Node

signal chapter_changed(chapter: int)
signal level_changed(level: int)
signal coins_changed(value: int)

var current_chapter := 0
var current_level := 0

var coins := 0
var score := 0
var stars: Dictionary = {}


func set_chapter(chapter: int) -> void:
	current_chapter = max(chapter, 0)
	current_level = 0

	chapter_changed.emit(current_chapter)
	level_changed.emit(current_level)


func set_level(chapter: int, level: int) -> void:
	current_chapter = max(chapter, 0)
	current_level = max(level, 0)

	chapter_changed.emit(current_chapter)
	level_changed.emit(current_level)


func add_coin(value: int) -> void:
	coins += value
	coins_changed.emit(coins)


func remove_coin(value: int) -> void:
	coins = max(0, coins - value)
	coins_changed.emit(coins)


func reset_game() -> void:
	current_chapter = 0
	current_level = 0
	coins = 0
	score = 0
	stars.clear()

	SaveManager.reset_save()

	chapter_changed.emit(current_chapter)
	level_changed.emit(current_level)
	coins_changed.emit(coins)
