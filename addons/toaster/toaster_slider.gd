@tool
extends VSlider

signal request_start

const Toaster = preload("res://addons/toaster/toaster.gd")

@onready var toaster: Toaster = owner

var drag_tween: Tween:
	set(x):
		if drag_tween:
			drag_tween.kill()
		drag_tween = x

func _ready():
	if owner == get_tree().edited_scene_root:
		return
	
	toaster.cook_complete.connect(cook_complete)
	drag_started.connect(_drag_started)
	drag_ended.connect(_drag_ended.unbind(1))

func _drag_started():
	drag_tween = null

func _drag_ended():
	if value > 1.0:
		bounce_to_initial()
	else:
		request_start.emit()
		value = 0.0
		editable = false

func cook_complete():
	editable = true
	bounce_to_initial()

func bounce_to_initial():
	drag_tween = create_tween()
	drag_tween.set_ease(Tween.EASE_OUT)
	drag_tween.set_trans(Tween.TRANS_BOUNCE)
	drag_tween.tween_property(self, ^"value", 100.0, 0.35)
