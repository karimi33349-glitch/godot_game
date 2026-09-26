extends Control

@onready var label:Label = $Label
@onready var animation:AnimationPlayer = $AnimationPlayer

@export var messages:Array[String]=[
	"آفرین!",
	"احسنت!",
	"بی‌نظیر!",
	"عالی!",
	"دمت گرم!",
	"فوق‌العاده!"
]

func _ready():

	hide()


func show_success(text:String=""):

	if label==null:
		push_error("PopupText : Label not found.")
		return

	if animation==null:
		push_error("PopupText : AnimationPlayer not found.")
		return

	if text.is_empty():
		label.text=messages.pick_random()
	else:
		label.text=text

	show()

	animation.stop()

	animation.play("Show")

	await animation.animation_finished

	hide()
