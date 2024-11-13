@tool
extends RichTextLabel

func _ready() -> void:
	%OptionMoondog.pressed.connect(add_line.bind('[img=64x64]res://addons/toaster/moondog.png[/img]\nHi! Im Moondog!'))

func add_line(txt: String):
	append_text('\n' + txt)
