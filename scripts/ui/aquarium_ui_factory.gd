extends RefCounted


static func apply_control_font(control: Control, font: Font, font_size: int) -> void:
	control.add_theme_font_override("font", font)
	control.add_theme_font_size_override("font_size", font_size)
	if control is Button:
		control.focus_mode = Control.FOCUS_NONE


static func panel(position: Vector2, size: Vector2, visible := true) -> Panel:
	var control := Panel.new()
	control.position = position
	control.size = size
	control.visible = visible
	return control


static func label(font: Font, font_size: int, text := "", position := Vector2.ZERO, size := Vector2.ZERO, alignment := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var control := Label.new()
	apply_control_font(control, font, font_size)
	control.text = text
	control.position = position
	control.size = size
	control.horizontal_alignment = alignment
	return control


static func button(font: Font, font_size: int, text := "", position := Vector2.ZERO, size := Vector2.ZERO) -> Button:
	var control := Button.new()
	apply_control_font(control, font, font_size)
	control.text = text
	control.position = position
	control.size = size
	return control


static func line_edit(font: Font, font_size: int, placeholder := "", position := Vector2.ZERO, size := Vector2.ZERO) -> LineEdit:
	var control := LineEdit.new()
	apply_control_font(control, font, font_size)
	control.placeholder_text = placeholder
	control.position = position
	control.size = size
	return control
