@tool
extends HBoxContainer

const Toaster = preload("res://addons/toaster/toaster.gd")

@onready var label: Label = $Label
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var toaster: Toaster = owner

@onready var initial_text := label.text

func _ready():
	if owner == get_tree().edited_scene_root:
		return
	toaster.cook_begin.connect(cook_begin)
	toaster.cook_progress.connect(cook_progress)
	toaster.cook_complete.connect(cook_complete)

func cook_begin():
	label.text = "Cook Progress"
	progress_bar.value = 0.0
	progress_bar.show()

func cook_progress(x: float):
	progress_bar.value = x * 100.0

func cook_complete():
	progress_bar.hide()
	label.text = "Cook Complete!"
	await get_tree().create_timer(2.0).timeout
	if not toaster.toasting:
		label.text = initial_text
