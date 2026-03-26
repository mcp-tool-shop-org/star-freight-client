## Roster scene — displays crew characters with their sprite packs.
##
## This is the Phase 7A proof: load packs, show characters, rotate directions.
## The bridge connection is optional — works standalone for visual testing,
## and with bridge for engine-driven roster data.
extends Node2D

const ASSETS_ROOT := "res://assets/characters"

var characters: Array[CharacterNode] = []
var selected_index: int = 0

var _title_label: Label = null
var _direction_label: Label = null
var _hint_label: Label = null
var _bridge: EngineBridge = null
var _bridge_status: String = "disconnected"


func _ready() -> void:
	# Background
	var bg := ColorRect.new()
	bg.color = Color(0.06, 0.06, 0.09)
	bg.size = Vector2(960, 640)
	bg.z_index = -10
	add_child(bg)

	# Title
	_title_label = Label.new()
	_title_label.text = "STAR FREIGHT — CREW ROSTER"
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.position = Vector2(0, 20)
	_title_label.size = Vector2(960, 40)
	_title_label.add_theme_font_size_override("font_size", 20)
	_title_label.add_theme_color_override("font_color", Color(0.9, 0.75, 0.3))
	add_child(_title_label)

	# Direction indicator
	_direction_label = Label.new()
	_direction_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_direction_label.position = Vector2(0, 520)
	_direction_label.size = Vector2(960, 30)
	_direction_label.add_theme_font_size_override("font_size", 14)
	_direction_label.add_theme_color_override("font_color", Color(0.6, 0.65, 0.7))
	add_child(_direction_label)

	# Controls hint
	_hint_label = Label.new()
	_hint_label.text = "A/D: rotate  |  Tab: select  |  Space: all rotate  |  B: bridge  |  Esc: quit"
	_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint_label.position = Vector2(0, 590)
	_hint_label.size = Vector2(960, 30)
	_hint_label.add_theme_font_size_override("font_size", 11)
	_hint_label.add_theme_color_override("font_color", Color(0.4, 0.42, 0.45))
	add_child(_hint_label)

	# Ground plane
	var ground := ColorRect.new()
	ground.color = Color(0.08, 0.09, 0.12)
	ground.position = Vector2(0, 440)
	ground.size = Vector2(960, 80)
	add_child(ground)

	# Normal map light
	var light := PointLight2D.new()
	light.position = Vector2(480, 100)
	light.energy = 1.2
	light.texture = _make_light_texture()
	light.texture_scale = 3.0
	add_child(light)

	# Load packs
	_load_all_packs()
	_update_direction_label()


func _load_all_packs() -> void:
	var pack_dirs := PackLoader.discover_packs(ASSETS_ROOT)
	var spacing := 960.0 / (pack_dirs.size() + 1)

	for i in range(pack_dirs.size()):
		var pack := PackLoader.load_pack(pack_dirs[i])
		if not pack.valid:
			push_warning("Roster: Failed to load pack: %s — %s" % [pack_dirs[i], pack.error])
			continue

		var node := CharacterNode.new()
		node.position = Vector2(spacing * (i + 1), 350)
		add_child(node)
		node.load_character(pack)
		characters.append(node)

	if characters.size() > 0:
		_highlight_selected()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_D, KEY_RIGHT:
				# Rotate selected character clockwise
				if characters.size() > 0:
					characters[selected_index].rotate_direction(1)
					_update_direction_label()
			KEY_A, KEY_LEFT:
				# Rotate selected character counter-clockwise
				if characters.size() > 0:
					characters[selected_index].rotate_direction(-1)
					_update_direction_label()
			KEY_TAB:
				# Cycle selected character
				if characters.size() > 0:
					selected_index = (selected_index + 1) % characters.size()
					_highlight_selected()
					_update_direction_label()
			KEY_SPACE:
				# Rotate ALL characters
				for ch in characters:
					ch.rotate_direction(1)
				_update_direction_label()
			KEY_B:
				# Try bridge connection
				_try_bridge()
			KEY_ESCAPE:
				get_tree().quit()


func _highlight_selected() -> void:
	for i in range(characters.size()):
		var ch := characters[i]
		ch.modulate = Color.WHITE if i == selected_index else Color(0.6, 0.6, 0.6)


func _update_direction_label() -> void:
	if characters.size() == 0:
		_direction_label.text = "No characters loaded"
		return
	var ch := characters[selected_index]
	_direction_label.text = "%s — facing %s  [%s]" % [
		ch.pack.display_name,
		ch.get_direction_name(),
		_bridge_status,
	]


func _try_bridge() -> void:
	if _bridge != null:
		return  # Already connected

	_bridge = EngineBridge.new()
	add_child(_bridge)

	_bridge_status = "connecting..."
	_update_direction_label()

	var result = _bridge.call_blocking("ping")
	if result != null:
		_bridge_status = "engine v%s" % result.get("version", "?")
		# Try loading roster from engine
		var roster = _bridge.call_blocking("get_roster")
		if roster != null:
			_title_label.text = "STAR FREIGHT — CREW ROSTER (%d crew)" % roster.get("count", 0)
	else:
		_bridge_status = "offline (visual only)"

	_update_direction_label()


func _make_light_texture() -> GradientTexture2D:
	var tex := GradientTexture2D.new()
	tex.width = 256
	tex.height = 256
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(0.5, 1.0)
	var gradient := Gradient.new()
	gradient.set_offset(0, 0.0)
	gradient.set_color(0, Color.WHITE)
	gradient.set_offset(1, 1.0)
	gradient.set_color(1, Color.TRANSPARENT)
	tex.gradient = gradient
	return tex
