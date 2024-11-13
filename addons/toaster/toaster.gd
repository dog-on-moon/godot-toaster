@tool
extends Control

signal cook_begin
signal cook_progress(x: float)
signal cook_complete

@onready var reload_button: Button = %ReloadButton
@onready var toaster_terminal: RichTextLabel = %ToasterTerminal
@onready var music: AudioStreamPlayer = %Music
@onready var complete: AudioStreamPlayer = %Complete
@onready var toaster_slider: VSlider = %ToasterSlider
@onready var option_burn: CheckBox = %OptionBurn
@onready var option_instant: CheckBox = %OptionInstant
@onready var option_boss: CheckBox = %OptionBoss
@onready var option_moondog: CheckBox = %OptionMoondog
@onready var temperature_select: OptionButton = %TemperatureSelect
@onready var option_clear_terminal: CheckBox = %OptionClearTerminal

var plugin: EditorPlugin

func _ready():
	if self == get_tree().edited_scene_root:
		return
	reload_button.pressed.connect(plugin.reload.bind(true))
	toaster_terminal.meta_clicked.connect(OS.shell_open)
	toaster_slider.request_start.connect(start)
	
	toaster_terminal.add_line("Pull the lever to begin Cooking.")
	temperature_select.item_selected.connect(
		func (idx: int):
			toaster_terminal.add_line("[color=888888]Set Temperature[/color]")
	)
	option_burn.pressed.connect(toaster_terminal.add_line.bind("[color=888888]Set burn toast[/color]"))
	option_instant.pressed.connect(toaster_terminal.add_line.bind("[color=888888]Set instant bake[/color]"))
	option_boss.pressed.connect(toaster_terminal.add_line.bind("[color=888888]Set boss music[/color]"))
	option_clear_terminal.pressed.connect(
		func ():
			toaster_terminal.text = "[color=888888]Terminal cleared[/color]"
	)

var toast_progress := 0.0
var toasting := false

func start():
	toasting = true
	set_button_disabled(true)
	cook_begin.emit()
	toaster_terminal.add_line("Cook Begin")
	if option_boss.button_pressed:
		music.play()

var last_print := 0.0

func _process(delta: float) -> void:
	if not toasting:
		return
	var speed := 0.08 if not option_instant.button_pressed else 5.0
	toast_progress += delta * speed
	if toast_progress < 1.0:
		cook_progress.emit(toast_progress)
		if floori(toast_progress * 10.0) != last_print:
			toaster_terminal.add_line("Cook percentage: %s%%" % roundi(toast_progress * 100.0))
			last_print = floori(toast_progress * 10.0)
	else:
		cook_complete.emit()
		toast_progress = 0.0
		last_print = 0.0
		toasting = false
		set_button_disabled(false)
		toaster_terminal.add_line("Yay! Your toast is ready!")
		music.stop()
		if not option_burn.button_pressed:
			for i in 2:
				EditorInterface.get_editor_toaster().push_toast("Ding!\nDelicious, fresh slices of Gotoast.", EditorToaster.SEVERITY_WARNING)
		else:
			for i in 2:
				EditorInterface.get_editor_toaster().push_toast("The burnt remains of what could have been Gotoast.\nYou monster.", EditorToaster.SEVERITY_ERROR)
		complete.pitch_scale = 0.15 if option_burn.button_pressed else 1.35
		complete.play()

func set_button_disabled(d: bool):
	temperature_select.disabled = d
	option_burn.disabled = d
	option_instant.disabled = d
	option_boss.disabled = d
	option_moondog.disabled = d
