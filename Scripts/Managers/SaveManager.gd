extends Node


const SAVE_PATH := "user://save.json"


var save_data: Dictionary = {}


func _ready() -> void:
	print(
	"================ SAVE ================"
)

	print(
		"Highest Chapter: ",
		get_highest_unlocked_chapter()
	)

	print(
		"Highest Level: ",
		get_highest_unlocked_level()
	)

	print(
		"======================================"
	)
	load_game()


# =========================================================
# LOAD
# =========================================================

func load_game() -> void:

	if not FileAccess.file_exists(SAVE_PATH):
		create_new_save()
		return


	var file := FileAccess.open(
		SAVE_PATH,
		FileAccess.READ
	)

	if file == null:
		create_new_save()
		return


	var json := JSON.new()

	var error := json.parse(
		file.get_as_text()
	)

	file.close()


	if error != OK:
		create_new_save()
		return


	if typeof(json.data) != TYPE_DICTIONARY:
		create_new_save()
		return


	save_data = json.data


	# -----------------------------------------------------
	# اطمینان از ساختار
	# -----------------------------------------------------

	if not save_data.has("unlocked_levels"):
		save_data["unlocked_levels"] = {}

	if not save_data.has("highest_unlocked_chapter"):
		save_data["highest_unlocked_chapter"] = 0

	if not save_data.has("highest_unlocked_level"):
		save_data["highest_unlocked_level"] = 0


	# -----------------------------------------------------
	# مرحله اول همیشه باز باشد
	# -----------------------------------------------------

	if not is_level_unlocked(0, 0):

		unlock_level(
			0,
			0,
			false
		)

		save_game()


# =========================================================
# NEW SAVE
# =========================================================

func create_new_save() -> void:

	save_data = {
		"unlocked_levels": {},
		"highest_unlocked_chapter": 0,
		"highest_unlocked_level": 0
	}


	unlock_level(
		0,
		0,
		false
	)

	save_game()


# =========================================================
# SAVE
# =========================================================

func save_game() -> void:

	var file := FileAccess.open(
		SAVE_PATH,
		FileAccess.WRITE
	)

	if file == null:
		push_error(
			"SaveManager: Cannot save game."
		)
		return


	file.store_string(
		JSON.stringify(
			save_data,
			"\t"
		)
	)

	file.close()


# =========================================================
# UNLOCK LEVEL
# =========================================================

func unlock_level(
	chapter: int,
	level: int,
	auto_save := true
) -> void:

	var highest_chapter := (
		get_highest_unlocked_chapter()
	)

	var highest_level := (
		get_highest_unlocked_level()
	)


	# -----------------------------------------
	# اگر جلوتر از پیشرفت فعلی است
	# -----------------------------------------

	if chapter > highest_chapter:

		save_data["highest_unlocked_chapter"] = chapter
		save_data["highest_unlocked_level"] = level

	elif chapter == highest_chapter:

		if level > highest_level:

			save_data["highest_unlocked_level"] = level


	# -----------------------------------------
	# برای سازگاری با save قدیمی
	# -----------------------------------------

	var chapter_key := str(chapter)

	if not save_data["unlocked_levels"].has(
		chapter_key
	):

		save_data["unlocked_levels"][chapter_key] = []


	var levels: Array = (
		save_data["unlocked_levels"][chapter_key]
	)


	if level not in levels:

		levels.append(level)


	save_data["unlocked_levels"][chapter_key] = levels


	# -----------------------------------------
	# Save
	# -----------------------------------------

	if auto_save:

		save_game()

# =========================================================
# CHECK UNLOCK
# =========================================================

func is_level_unlocked(
	chapter: int,
	level: int
) -> bool:

	var highest_chapter := get_highest_unlocked_chapter()
	var highest_level := get_highest_unlocked_level()

	# -----------------------------------------
	# فصل‌های قبل از آخرین فصل
	# -----------------------------------------

	if chapter < highest_chapter:
		return true


	# -----------------------------------------
	# فصل‌های بعد از آخرین فصل
	# -----------------------------------------

	if chapter > highest_chapter:
		return false


	# -----------------------------------------
	# همین فصل
	# -----------------------------------------

	return level <= highest_level
		
# =========================================================
# UNLOCK NEXT LEVEL
# =========================================================

func unlock_next_level(
	chapter: int,
	level: int
) -> void:

	unlock_level(
		chapter,
		level + 1
	)


# =========================================================
# UNLOCK FIRST LEVEL OF NEXT CHAPTER
# =========================================================

func unlock_chapter(
	chapter: int
) -> void:

	unlock_level(
		chapter,
		0
	)


# =========================================================
# HIGHEST UNLOCKED CHAPTER
# =========================================================

func get_highest_unlocked_chapter() -> int:

	return int(
		save_data.get(
			"highest_unlocked_chapter",
			0
		)
	)


# =========================================================
# HIGHEST UNLOCKED LEVEL
# =========================================================

func get_highest_unlocked_level() -> int:

	return int(
		save_data.get(
			"highest_unlocked_level",
			0
		)
	)


# =========================================================
# GET HIGHEST UNLOCKED POSITION
# =========================================================

func get_highest_unlocked_position() -> Vector2i:

	return Vector2i(
		get_highest_unlocked_chapter(),
		get_highest_unlocked_level()
	)


# =========================================================
# RESET
# =========================================================

func reset_save() -> void:

	save_data = {
		"unlocked_levels": {},
		"highest_unlocked_chapter": 0,
		"highest_unlocked_level": 0
	}


	unlock_level(
		0,
		0,
		false
	)

	save_game()
