## JSON-RPC 2.0 client that communicates with the Star Freight Python engine.
##
## Spawns `starfreight rpc` as a subprocess and sends/receives JSON-RPC
## messages over stdio. The engine is the source of truth — this client
## only renders what the engine tells it.
##
## Usage:
##   var bridge = EngineBridge.new()
##   add_child(bridge)
##   bridge.connect_to_engine()
##   var roster = await bridge.call_method("get_roster")
class_name EngineBridge
extends Node

signal connected
signal disconnected
signal response_received(id: int, result: Variant)
signal error_received(id: int, error: Dictionary)

## Path to the Python executable.
@export var python_path: String = "python"
## Save slot to use when launching the engine.
@export var save_slot: String = "default"

var _process_id: int = -1
var _pipe: FileAccess = null
var _thread: Thread = null
var _next_id: int = 1
var _pending: Dictionary = {}  # id -> { callback: Callable, method: String }
var _running: bool = false

# Stdio pipe handles
var _stdin: FileAccess = null
var _stdout: FileAccess = null
var _child_pid: int = -1

# OS.execute approach: we use OS.create_process for async subprocess
var _output_buffer: String = ""


func _ready() -> void:
	pass


## Launch the Python RPC server subprocess.
func connect_to_engine() -> bool:
	var args: PackedStringArray = ["-m", "portlight.app.cli", "rpc"]
	if save_slot != "default":
		args = PackedStringArray(["--save", save_slot, "-m", "portlight.app.cli", "rpc"])

	# Use OS.create_process for non-blocking subprocess
	_child_pid = OS.create_process(python_path, args)
	if _child_pid <= 0:
		push_error("EngineBridge: Failed to spawn Python RPC server")
		return false

	_running = true
	connected.emit()
	return true


## Send a JSON-RPC request and return the result via signal.
## For synchronous-style usage, use call_method_sync() with pipes.
func send_request(method: String, params: Dictionary = {}) -> int:
	var id := _next_id
	_next_id += 1

	var request := {
		"jsonrpc": "2.0",
		"method": method,
		"id": id,
		"params": params,
	}

	_pending[id] = {"method": method}
	var json_str := JSON.stringify(request) + "\n"

	# Write to stdin pipe
	if _stdin != null:
		_stdin.store_string(json_str)
		_stdin.flush()

	return id


## Synchronous call via OS.execute (blocking — use for init only).
## Returns the parsed result dict, or null on error.
func call_blocking(method: String, params: Dictionary = {}) -> Variant:
	var id := _next_id
	_next_id += 1

	var request := {
		"jsonrpc": "2.0",
		"method": method,
		"id": id,
		"params": params,
	}
	var json_str := JSON.stringify(request)

	# Use OS.execute with pipe to get response
	var output: Array = []
	var args := PackedStringArray([
		"-c",
		"import sys, json; "
		+ "from portlight.rpc.server import RpcServer; "
		+ "from portlight.app.session import GameSession; "
		+ "s = GameSession(slot='%s'); s.load(); " % save_slot
		+ "server = RpcServer(session=s); "
		+ "print(server.dispatch('%s'))" % json_str.replace("'", "\\'"),
	])

	var exit_code := OS.execute(python_path, args, output, true)
	if exit_code != 0 or output.is_empty():
		push_error("EngineBridge: call_blocking failed for %s" % method)
		return null

	var json := JSON.new()
	var parse_err := json.parse(output[0].strip_edges())
	if parse_err != OK:
		push_error("EngineBridge: JSON parse error: %s" % output[0])
		return null

	var resp: Dictionary = json.data
	if resp.has("error"):
		error_received.emit(id, resp.error)
		return null

	return resp.get("result")


## Shut down the engine subprocess.
func shutdown() -> void:
	if _running:
		# Try graceful shutdown
		call_blocking("shutdown")
		_running = false
		disconnected.emit()

	if _child_pid > 0:
		OS.kill(_child_pid)
		_child_pid = -1


func _exit_tree() -> void:
	shutdown()
