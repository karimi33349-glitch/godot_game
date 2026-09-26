extends Control


@onready var touch_layer = $TouchLayer
@onready var line_drawer = $LineDrawer

@onready var level_manager = $LevelManager
@onready var word_manager = $WordManager

@onready var letter_tray = $UI/LetterTray
@onready var user_answer = $UI/UserAnswer

@onready var popup_text = $UI/PopupText

@onready var level_popup = $UI/LevelCopletePopup


func _ready() -> void:

	# =====================================================
	# LINE DRAWER
	# =====================================================

	line_drawer.word_finished.connect(
		_on_word_finished
	)


	# =====================================================
	# TOUCH
	# =====================================================

	touch_layer.drag_started.connect(
		_on_drag_started
	)

	touch_layer.drag_entered.connect(
		_on_drag_entered
	)

	touch_layer.drag_finished.connect(
		_on_drag_finished
	)


	# =====================================================
	# WORD MANAGER
	# =====================================================

	word_manager.word_correct.connect(
		_on_word_correct
	)

	word_manager.word_wrong.connect(
		_on_word_wrong
	)

	word_manager.word_already_found.connect(
		_on_word_already_found
	)

	word_manager.level_completed.connect(
		_on_level_completed
	)


	# =====================================================
	# LEVEL MANAGER
	# =====================================================

	level_manager.level_started.connect(
		_on_level_started
	)


	# =====================================================
	# LEVEL COMPLETE POPUP
	# =====================================================

	level_popup.next_level_pressed.connect(
		_on_popup_next_level
	)

	level_popup.levels_pressed.connect(
		_on_popup_levels
	)


	# =====================================================
	# START CURRENT LEVEL
	# =====================================================

	level_manager.start_level(
		GameState.current_chapter,
		GameState.current_level
	)


# =========================================================
# LEVEL STARTED
# =========================================================

func _on_level_started(level_data) -> void:

	var answers = level_data["answers"]

	line_drawer.set_answers(answers)

	letter_tray.setup(
		level_manager.generate_letters(
			answers
		)
	)


	word_manager.setup(
		answers
	)


	user_answer.setup(
		answers
	)


	touch_layer.setup(
		letter_tray.get_letter_buttons()
	)


# =========================================================
# DRAG START
# =========================================================

func _on_drag_started(button) -> void:

	line_drawer.start_drag(
		button
	)


# =========================================================
# DRAG ENTER
# =========================================================

func _on_drag_entered(button) -> void:

	line_drawer.add_button(
		button
	)


# =========================================================
# DRAG FINISH
# =========================================================

func _on_drag_finished() -> void:

	line_drawer.finish_drag()


# =========================================================
# WORD FINISHED
# =========================================================

func _on_word_finished(
	word: String,
	buttons: Array
) -> void:

	if user_answer.has_word(word):

		line_drawer.fade(
			Color.WEB_GREEN
		)

	else:

		line_drawer.fade(
			Color.RED
		)


	word_manager.submit_word(
		word
	)


# =========================================================
# WORD CORRECT
# =========================================================

func _on_word_correct(word: String) -> void:

	user_answer.fill_word(
		word
	)

	user_answer.show_user_target(
		true,
		word
	)

	popup_text.show_success()


# =========================================================
# WORD WRONG
# =========================================================

func _on_word_wrong(word: String) -> void:

	user_answer.show_user_target(
		false,
		word
	)

	print(
		"❌ اشتباه: ",
		word
	)


# =========================================================
# ALREADY FOUND
# =========================================================

func _on_word_already_found(word: String) -> void:

	print(
		"✅ قبلاً پیدا شده: ",
		word
	)


# =========================================================
# LEVEL COMPLETED
# =========================================================

func _on_level_completed():

	popup_text.visible = false

	touch_layer.process_mode = (
		Node.PROCESS_MODE_DISABLED
	)


	var chapter := GameState.current_chapter
	var level := GameState.current_level


	var levels: Array = (
		level_manager.game_data
		["chapters"]
		[chapter]
		["levels"]
	)


	# =====================================================
	# مرحله بعد در همان فصل
	# =====================================================

	if level < levels.size() - 1:

		SaveManager.unlock_level(
			chapter,
			level + 1
		)


	# =====================================================
	# آخرین مرحله فصل
	# =====================================================

	else:

		var next_chapter := (
			chapter + 1
		)

		var chapter_count = (
			level_manager.game_data
			["chapters"]
			.size()
		)

		if next_chapter < chapter_count:

			SaveManager.unlock_chapter(
				next_chapter
			)

	# -----------------------------------------
	# Popup
	# -----------------------------------------

	level_popup.show_popup(
		"احسنتم!\nاین مرحله رو تموم کردی",
		level_manager.has_next_level()
	)
	
func _on_popup_next_level() -> void:

	# ورودی دوباره فعال شود
	touch_layer.process_mode = (
		Node.PROCESS_MODE_INHERIT
	)


	level_manager.next_level()


# =========================================================
# POPUP LEVELS
# =========================================================

func _on_popup_levels() -> void:
	SceneManager.change_scene("res://Scenes/PageLevels/ShowLevels.tscn")
