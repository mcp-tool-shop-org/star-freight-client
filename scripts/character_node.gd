## Visual representation of a character using a loaded sprite pack.
##
## Wraps a Sprite2D with CanvasTexture (albedo + normal). Supports
## direction switching from game state. Renders at scaled pixel art size.
class_name CharacterNode
extends Node2D

## The loaded character pack.
var pack: PackLoader.CharacterPack = null

## Current facing direction index (0-7).
var direction_index: int = 0

## Display scale for 48px sprites.
@export var sprite_scale: float = 4.0

var _sprite: Sprite2D = null
var _label: Label = null
var _light: PointLight2D = null


func _ready() -> void:
	_sprite = Sprite2D.new()
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.scale = Vector2(sprite_scale, sprite_scale)
	add_child(_sprite)

	_label = Label.new()
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.position = Vector2(-60, sprite_scale * 24 + 4)
	_label.size = Vector2(120, 20)
	_label.add_theme_font_size_override("font_size", 12)
	_label.add_theme_color_override("font_color", Color(0.8, 0.85, 0.9))
	add_child(_label)


## Load a character pack and display the front-facing sprite.
func load_character(character_pack: PackLoader.CharacterPack) -> void:
	pack = character_pack
	if pack == null or not pack.valid:
		push_warning("CharacterNode: Invalid pack")
		return

	_label.text = pack.display_name
	direction_index = 0
	_apply_direction()


## Set direction by name (e.g. "front", "back_left").
func set_direction(direction_name: String) -> void:
	if pack == null:
		return
	var idx := pack.direction_order.find(direction_name)
	if idx >= 0:
		direction_index = idx
		_apply_direction()


## Rotate direction by offset (+1 = clockwise, -1 = counter-clockwise).
func rotate_direction(offset: int) -> void:
	if pack == null:
		return
	var count := pack.direction_order.size()
	direction_index = (direction_index + offset) % count
	if direction_index < 0:
		direction_index += count
	_apply_direction()


## Get current direction name.
func get_direction_name() -> String:
	if pack == null or pack.direction_order.is_empty():
		return "front"
	return pack.direction_order[direction_index]


func _apply_direction() -> void:
	if pack == null or _sprite == null:
		return
	var dir_name := pack.direction_order[direction_index]
	var tex := pack.get_canvas_texture(dir_name)
	if tex != null:
		_sprite.texture = tex
