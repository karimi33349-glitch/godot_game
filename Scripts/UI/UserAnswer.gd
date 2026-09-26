extends Control

const WordBoxScene = preload(
    "res://Scenes/Components/WordBox.tscn"
)

var words: Array = []

@onready var user_target_label = $"../LabelUserTarget"
const TARGET_CENTER := Vector2(540, 1047)

var boxes = {}

const H_PADDING := 0.05
const V_PADDING := 0.05
const H_SPACE := 0.015
const V_SPACE := 0.02

var box_size = 80

var normal_style := StyleBoxFlat.new()
var correct_style := StyleBoxFlat.new()
var wrong_style := StyleBoxFlat.new()

var showing_result := false

func setup(level_words: Array):
	words = level_words.duplicate()
	words.sort_custom(func(a, b): return a.length() < b.length())
	create_grid()

func reset_user_target():
	showing_result = false
	user_target_label.visible = false
	user_target_label.text = ""
	user_target_label.remove_theme_stylebox_override("normal")
	
	# ✅ بازنشانی موقعیت به حالت اولیه
	user_target_label.position = TARGET_CENTER - user_target_label.size * 0.5

func create_grid():
	for child in get_children():
		if child != user_target_label:
			child.queue_free()

	boxes.clear()

	if words.is_empty():
		return

	var row_count := words.size()
	var max_letters := 0

	for word in words:
		max_letters = max(max_letters, word.length())

	var usable_width = size.x * (1.0 - H_PADDING * 2.0)
	var usable_height = size.y * (1.0 - V_PADDING * 2.0)

	var h_spacing = size.x * H_SPACE
	var v_spacing = size.y * V_SPACE

	var box_width = (usable_width - (max_letters - 1) * h_spacing) / max_letters
	var box_height = (usable_height - (row_count - 1) * v_spacing) / row_count
	box_size = min(box_width, box_height)

	var total_height = row_count * box_size + (row_count - 1) * v_spacing
	var current_y = (size.y - total_height) / 2.0

	for word in words:
		create_word(word, current_y, box_size, h_spacing)
		current_y += box_size + v_spacing

func create_word(word: String, y: float, box_size: float, h_spacing: float):
	var count := word.length()
	var total_width = count * box_size + (count - 1) * h_spacing
	var start_x = (size.x - total_width) / 2.0
	var word_boxes: Array = []

	for i in range(count):
		var box = WordBoxScene.instantiate()
		add_child(box)
		box.custom_minimum_size = Vector2(box_size, box_size)
		box.size = Vector2(box_size, box_size)
		box.position = Vector2(start_x + i * (box_size + h_spacing), y)
		word_boxes.append(box)

	boxes[word] = word_boxes

func fill_word(word: String):
	if !boxes.has(word):
		return

	var word_boxes = boxes[word]

	for i in range(word.length()):
		var box_index = word.length() - 1 - i
		word_boxes[box_index].fill(word[i], box_size)

	await get_tree().create_timer(0.15).timeout

	for box in word_boxes:
		if is_instance_valid(box):
			box.complete()

func _ready():
	normal_style.bg_color = Color(0.338, 0.227, 0.067, 1.0)
	correct_style.bg_color = Color.WEB_GREEN
	wrong_style.bg_color = Color.DARK_RED

	for style in [normal_style, correct_style, wrong_style]:
		style.content_margin_left = 30
		style.content_margin_right = 30
		style.content_margin_top = 20
		style.content_margin_bottom = 20

		style.corner_radius_top_left = 50
		style.corner_radius_top_right = 50
		style.corner_radius_bottom_left = 50
		style.corner_radius_bottom_right = 50

	user_target_label.remove_theme_stylebox_override("normal")
	reset_user_target()

func clear():
	for child in get_children():
		if child != user_target_label:
			child.queue_free()

	boxes.clear()
	
	if is_instance_valid(user_target_label):
		user_target_label.text = ""

func get_word_boxes(word: String):
	if boxes.has(word):
		return boxes[word]
	return []

func has_word(word: String):
	return boxes.has(word)

func _center_user_target():
	await get_tree().process_frame
	user_target_label.size = user_target_label.get_combined_minimum_size()
	user_target_label.position = TARGET_CENTER - user_target_label.size * 0.5

func set_usertarget_label(word: String):
	if showing_result:
		return

	user_target_label.visible = true
	user_target_label.text = word
	_center_user_target()
	user_target_label.add_theme_stylebox_override("normal", normal_style)

func set_text(word: String):
	set_usertarget_label(word)

# ============================================
# ✅ تابع لرزش جداگانه
# ============================================
func shake_label():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	var original_pos = user_target_label.position
	var shake_distance = 15
	
	# ✅ لرزش به چپ و راست
	tween.tween_property(user_target_label, "position:x", original_pos.x - shake_distance, 0.1)
	tween.tween_property(user_target_label, "position:x", original_pos.x + shake_distance, 0.1)
	tween.tween_property(user_target_label, "position:x", original_pos.x - shake_distance, 0.1)
	tween.tween_property(user_target_label, "position:x", original_pos.x + shake_distance, 0.1)
	tween.tween_property(user_target_label, "position:x", original_pos.x - shake_distance, 0.1)
	tween.tween_property(user_target_label, "position:x", original_pos.x + shake_distance, 0.1)
	
	# ✅ بازگشت به موقعیت اصلی
	tween.tween_property(user_target_label, "position:x", original_pos.x, 0.05)
	
	# ✅ منتظر بمان تا لرزش تمام شود
	await tween.finished

# ============================================
# ✅ نمایش UserTarget با رنگ (اصلاح‌شده)
# ============================================
func show_user_target(correct: bool, word: String):
	showing_result = true

	user_target_label.visible = true
	user_target_label.text = word
	_center_user_target()
	
	if correct:
		user_target_label.add_theme_stylebox_override("normal", correct_style)
		await get_tree().create_timer(1.0).timeout
	else:
		user_target_label.add_theme_stylebox_override("normal", wrong_style)
		
		# ✅ لرزش و منتظر ماندن برای اتمام
		await shake_label()
		
		# ✅ کمی مکث بعد از لرزش
		await get_tree().create_timer(0.3).timeout
	
	# ✅ پاک کردن لیبل
	reset_user_target()
	showing_result = false
