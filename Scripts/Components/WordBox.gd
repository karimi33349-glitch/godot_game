extends Panel

const WORD_BOX_TEXTURE = preload("res://asset/word_box_img.png")

@onready var background: TextureRect = $Background
@onready var glow: TextureRect = $Glow
@onready var label: Label = $Label
@onready var star: TextureRect = $Star

var letter:String = ""

var completed := false


func _ready() -> void:
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.2, 0.2, 0.537)
	
	# ✅ Corner Radius
	style.corner_radius_top_left = 15
	style.corner_radius_top_right = 15
	style.corner_radius_bottom_left = 15
	style.corner_radius_bottom_right = 15
	add_theme_stylebox_override("panel", style)
	
	clear()


#--------------------------------------------------
# Public API
#--------------------------------------------------

func clear() -> void:

	completed = false

	letter = ""

	label.text = ""

	glow.visible = false

	star.visible = false

	scale = Vector2.ONE

	modulate = Color.WHITE


func fill(letter_text:String,size:float) -> void:

	letter = letter_text

	label.text = letter
	label.add_theme_color_override("font_color", Color(0.231, 0.165, 0.102, 1.0))
	label.add_theme_color_override("font_outline_color", Color(0.965, 0.906, 0.757, 1.0))
	label.add_theme_constant_override("outline_size", 3)               # افست عمودی
	
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	var font_size = int(size * 0.75)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_constant_override("line_spacing", -2)
	
	# ✅ تنظیم اندازه TextureRect
	background.texture = WORD_BOX_TEXTURE
	var img_size = background.texture.get_size()
	background.scale = Vector2(size/img_size.x,size/img_size.y) 
	
	play_fill_animation()


func complete():
	completed = true
	play_complete_animation()

func get_letter() -> String:

	return letter


func is_completed() -> bool:

	return completed


#--------------------------------------------------
# Animations
#--------------------------------------------------

func play_fill_animation() -> void:

	scale = Vector2(0.65,0.65)

	var tween = create_tween()

	tween.set_trans(Tween.TRANS_BACK)

	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		self,
		"scale",
		Vector2.ONE,
		0.20
	)


func play_complete_animation() -> void:

	glow.visible = true

	star.visible = true

	glow.modulate.a = 0

	star.scale = Vector2.ZERO

	var tween = create_tween()

	tween.set_parallel(true)

	tween.tween_property(
		glow,
		"modulate:a",
		1.0,
		0.25
	)

	tween.tween_property(
		star,
		"scale",
		Vector2.ONE,
		0.25
	)

	tween.tween_property(
		self,
		"scale",
		Vector2(1.08,1.08),
		0.12
	)

	await tween.finished

	var tween2 = create_tween()

	tween2.tween_property(
		self,
		"scale",
		Vector2.ONE,
		0.12
	)
