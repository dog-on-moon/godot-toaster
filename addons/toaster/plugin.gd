@tool
extends EditorPlugin

var toaster: Control
var toaster_button: Button

func _enter_tree() -> void:
	reload()

func _exit_tree() -> void:
	cleanup()

func reload(reopen := false):
	cleanup()
	toaster = load("res://addons/toaster/toaster.tscn").instantiate()
	toaster.plugin = self
	toaster_button = add_control_to_bottom_panel(toaster, "Toaster")
	if reopen:
		toaster_button.button_pressed = true

func cleanup():
	if not toaster:
		return
	remove_control_from_bottom_panel(toaster)
	toaster.queue_free()
	toaster = null
