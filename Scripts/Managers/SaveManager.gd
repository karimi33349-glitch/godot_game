extends Node

const SAVE_PATH := "user://save.json"
const SAVE_VERSION := 1

var save_data: Dictionary = {}


func _ready() -> void:
	load_game()


func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		create_new_save()
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		create_new_save()
		return

	var json := JSON.new()
	var error := json.parse(file.get_as_text())
	file.close()

	if error != OK or typeof(json.data) != TYPE_DICTIONARY:
		push_error("SaveManager: save.json is invalid; creating a new save.")
		create_new_save()
		return

	save_data = json.data
	_migrate_save()
	_save_if_changed()


func create_new_save() -> void:
	save_data = {
		"save_version": SAVE_VERSION,
		"highest_unlocked_chapter": 0,
		"highest_unlocked_level": 0
	}
	save_game()


func save_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: Could not open save file for writing.")
		return

	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()


func _save_if_changed() -> void:
	if not save_data.has("save_version") or int(save_data["save_version"]) != SAVE_VERSION:
		save_data["save_version"] = SAVE_VERSION
		save_game()


func _migrate_save() -> void:
	var changed := false

	if not save_data.has("save_version"):
		save_data["save_version"] = SAVE_VERSION
		changed = true

	# Migrate the previous unlocked_levels format once.
	if not save_data.has("highest_unlocked_chapter") or not save_data.has("highest_unlocked_level"):
		var best_chapter := 0
		var best_level := 0

		if save_data.has("unlocked_levels") and typeof(save_data["unlocked_levels"]) == TYPE_DICTIONARY:
			for chapter_key in save_data["unlocked_levels"]:
				var chapter := int(chapter_key)
				var levels = save_data["unlocked_levels"][chapter_key]
				if typeof(levels) != TYPE_ARRAY:
					continue

				for level_value in levels:
					var level := int(level_value)
					if chapter > best_chapter or (chapter == best_chapter and level > best_level):
						best_chapter = chapter
						best_level = level

		save_data["highest_unlocked_chapter"] = best_chapter
		save_data["highest_unlocked_level"] = best_level
		changed = true

	# Old saves may still contain unlocked_levels. It is no longer used.
	if save_data.has("unlocked_levels"):
		save_data.erase("unlocked_levels")
		changed = true

	if not save_data.has("highest_unlocked_chapter"):
		save_data["highest_unlocked_chapter"] = 0
		changed = true

	if not save_data.has("highest_unlocked_level"):
		save_data["highest_unlocked_level"] = 0
		changed = true

	if int(save_data["highest_unlocked_chapter"]) < 0:
		save_data["highest_unlocked_chapter"] = 0
		changed = true

	if int(save_data["highest_unlocked_level"]) < 0:
		save_data["highest_unlocked_level"] = 0
		changed = true

	if changed:
		save_game()


func unlock_level(chapter: int, level: int, auto_save := true) -> void:
	if chapter < 0 or level < 0:
		return

	var highest_chapter := get_highest_unlocked_chapter()
	var highest_level := get_highest_unlocked_level()

	if chapter > highest_chapter:
		save_data["highest_unlocked_chapter"] = chapter
		save_data["highest_unlocked_level"] = level
	elif chapter == highest_chapter and level > highest_level:
		save_data["highest_unlocked_level"] = level

	if auto_save:
		save_game()


func unlock_next_level(chapter: int, level: int) -> void:
	unlock_level(chapter, level + 1)


func unlock_chapter(chapter: int) -> void:
	unlock_level(chapter, 0)


func is_level_unlocked(chapter: int, level: int) -> bool:
	if chapter < 0 or level < 0:
		return false

	var highest_chapter := get_highest_unlocked_chapter()
	var highest_level := get_highest_unlocked_level()

	if chapter < highest_chapter:
		return true

	if chapter > highest_chapter:
		return false

	return level <= highest_level


func get_highest_unlocked_chapter() -> int:
	return int(save_data.get("highest_unlocked_chapter", 0))


func get_highest_unlocked_level() -> int:
	return int(save_data.get("highest_unlocked_level", 0))


func get_highest_unlocked_position() -> Vector2i:
	return Vector2i(
		get_highest_unlocked_chapter(),
		get_highest_unlocked_level()
	)


func reset_save() -> void:
	create_new_save()
