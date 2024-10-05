extends Button

# Preload your specific font resource
var noto_sans_font = preload("res://Fonts/noto_sans_48.tres") # Adjust the path to the correct one


func adjust_text_size():
	if noto_sans_font == null:
		return
	
	# Create a new instance of the font to prevent modifying the original one
	var unique_font = noto_sans_font.duplicate()

	var target_width = rect_size.x - 10 # Padding (adjust if needed)
	var target_height = rect_size.y - 10
	var text = get_text()

	var font_size = unique_font.get_height()
	while unique_font.get_string_size(text).x > target_width or unique_font.get_height() > target_height:
		font_size -= 1
		unique_font.set_size(font_size)

	# Set the unique font to the button (using the custom_fonts path)
	set("custom_fonts/font", unique_font)
