extends Button


func adjust_text_size():
	# Create a unique DynamicFont instance for this button
	var unique_font = DynamicFont.new()
	unique_font.font_data = load("res://Fonts/NotoSansTC-VariableFont_wght.ttf")
	
	# Set initial font size and target dimensions
	var font_size = 48  # Start with a default font size
	var target_width = rect_size.x - 10  # Padding (adjust if needed)
	var target_height = rect_size.y - 10
	var text = get_text()

	# Adjust font size until it fits
	unique_font.size = font_size
	unique_font.outline_size = 1
	unique_font.outline_color = Color(0, 0, 0)
	while unique_font.get_string_size(text).x > target_width or unique_font.get_height() > target_height:
		font_size -= 1
		unique_font.size = font_size  # Update font size

	# Set the unique font to the button
	add_font_override("font", unique_font)
