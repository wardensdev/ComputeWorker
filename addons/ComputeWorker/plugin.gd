@tool
extends EditorPlugin


# Initialization of the plugin goes here.
func _enter_tree():
	add_custom_type("ComputeWorker",'Node',preload("ComputeWorker.gd"),preload("ComputeWorkerIcon.png"))

# Clean-up of the plugin goes here.
func _exit_tree():
	remove_custom_type("ComputeWorker")
