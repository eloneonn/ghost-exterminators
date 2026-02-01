extends CanvasLayer

const MIN_DISPLAY_TIME := 0.5  # Minimum time to show loading screen

@onready var progress_bar: ProgressBar = %ProgressBar
@onready var loading_label: Label = %LoadingLabel

var _target_scene_path: String = ""
var _loading_started: bool = false
var _elapsed_time: float = 0.0
var _progress: Array = []

func _ready() -> void:
	_target_scene_path = GameManager.pending_scene_path
	if _target_scene_path.is_empty():
		push_error("LoadingScreen: No target scene specified!")
		return
	
	# Start threaded loading
	ResourceLoader.load_threaded_request(_target_scene_path)
	_loading_started = true

func _process(delta: float) -> void:
	if not _loading_started:
		return
	
	_elapsed_time += delta
	
	# Check loading status
	var status := ResourceLoader.load_threaded_get_status(_target_scene_path, _progress)
	
	# Update progress bar (progress[0] is 0.0 to 1.0)
	if _progress.size() > 0:
		progress_bar.value = _progress[0] * 100.0
	
	# Update loading text with animated dots
	var dots := ".".repeat(int(_elapsed_time * 3) % 4)
	loading_label.text = "Loading" + dots
	
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			pass  # Still loading
		ResourceLoader.THREAD_LOAD_LOADED:
			# Ensure minimum display time for visual feedback
			if _elapsed_time >= MIN_DISPLAY_TIME:
				_finish_loading()
		ResourceLoader.THREAD_LOAD_FAILED:
			push_error("LoadingScreen: Failed to load scene: " + _target_scene_path)
			# Fallback to direct load
			get_tree().change_scene_to_file(_target_scene_path)
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			push_error("LoadingScreen: Invalid resource: " + _target_scene_path)

func _finish_loading() -> void:
	_loading_started = false
	var packed_scene: PackedScene = ResourceLoader.load_threaded_get(_target_scene_path)
	GameManager.pending_scene_path = ""
	get_tree().change_scene_to_packed(packed_scene)
