## Loads sprite packs from assets/characters/ using manifest.json.
##
## Each pack contains 8-direction albedo + normal + depth textures.
## The loader validates the manifest schema and builds CanvasTextures
## with diffuse + normal layers for each direction.
##
## Usage:
##   var pack = PackLoader.load_pack("res://assets/characters/sera_vale")
##   var tex = pack.get_canvas_texture("front")
class_name PackLoader

const SCHEMA_VERSION := "1.0.0"
const DIRECTIONS := [
	"front", "front_left", "left", "back_left",
	"back", "back_right", "right", "front_right"
]


## Loaded pack data — holds textures and identity for one character.
class CharacterPack:
	var slug: String
	var display_name: String
	var body_family: String
	var width: int
	var height: int
	var direction_order: PackedStringArray

	# direction_name -> { albedo: Texture2D, normal: Texture2D, depth: Texture2D }
	var textures: Dictionary = {}

	# direction_name -> CanvasTexture (albedo + normal combined)
	var canvas_textures: Dictionary = {}

	var valid: bool = false
	var error: String = ""

	func get_canvas_texture(direction: String) -> CanvasTexture:
		if canvas_textures.has(direction):
			return canvas_textures[direction]
		return null

	func get_albedo(direction: String) -> Texture2D:
		if textures.has(direction):
			return textures[direction].albedo
		return null


## Discover all packs under a root directory.
static func discover_packs(root_path: String) -> PackedStringArray:
	var packs: PackedStringArray = []
	var dir := DirAccess.open(root_path)
	if dir == null:
		push_warning("PackLoader: Cannot open %s" % root_path)
		return packs

	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		if dir.current_is_dir() and entry != "." and entry != "..":
			var pack_path := root_path.path_join(entry)
			var manifest_path := pack_path.path_join("manifest.json")
			if FileAccess.file_exists(manifest_path):
				packs.append(pack_path)
		entry = dir.get_next()
	dir.list_dir_end()
	return packs


## Load a single pack from its directory (must contain manifest.json).
static func load_pack(pack_path: String) -> CharacterPack:
	var pack := CharacterPack.new()
	var manifest_path := pack_path.path_join("manifest.json")

	# Read manifest
	var file := FileAccess.open(manifest_path, FileAccess.READ)
	if file == null:
		pack.error = "Cannot open manifest: %s" % manifest_path
		return pack

	var json := JSON.new()
	var parse_err := json.parse(file.get_as_text())
	file.close()
	if parse_err != OK:
		pack.error = "JSON parse error in %s" % manifest_path
		return pack

	var data: Dictionary = json.data

	# Validate schema version
	if data.get("schema_version", "") != SCHEMA_VERSION:
		pack.error = "Unsupported schema: %s" % data.get("schema_version", "missing")
		return pack

	# Identity
	var identity: Dictionary = data.get("identity", {})
	pack.slug = identity.get("subject_slug", "unknown")
	pack.display_name = identity.get("display_name", "Unknown")
	pack.body_family = identity.get("body_family", "bipedal")

	# Render contract
	var contract: Dictionary = data.get("render_contract", {})
	pack.width = contract.get("width", 48)
	pack.height = contract.get("height", 48)
	var dir_array: Array = contract.get("direction_order", DIRECTIONS)
	pack.direction_order = PackedStringArray(dir_array)

	# Load textures for each direction
	for direction in pack.direction_order:
		var albedo_path := pack_path.path_join("albedo/%s.png" % direction)
		var normal_path := pack_path.path_join("normal/%s.png" % direction)
		var depth_path := pack_path.path_join("depth/%s.png" % direction)

		var albedo := _load_texture(albedo_path)
		var normal := _load_texture(normal_path)
		var depth := _load_texture(depth_path)

		if albedo == null:
			pack.error = "Missing albedo for direction: %s" % direction
			return pack

		pack.textures[direction] = {
			"albedo": albedo,
			"normal": normal,
			"depth": depth,
		}

		# Build CanvasTexture with albedo + normal
		var canvas_tex := CanvasTexture.new()
		canvas_tex.diffuse_texture = albedo
		if normal != null:
			canvas_tex.normal_texture = normal
		canvas_tex.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		pack.canvas_textures[direction] = canvas_tex

	pack.valid = true
	return pack


## Load an image file as an ImageTexture (runtime, not import system).
static func _load_texture(path: String) -> ImageTexture:
	if not FileAccess.file_exists(path):
		return null

	var image := Image.new()
	var err := image.load(path)
	if err != OK:
		push_warning("PackLoader: Failed to load %s (error %d)" % [path, err])
		return null

	return ImageTexture.create_from_image(image)
