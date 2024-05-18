@tool
class_name ViewPort extends Control

func _ready() -> void:
	var editor_interface: FileSystemDock = EditorInterface.get_file_system_dock();	
	editor_interface.file_removed.connect(self._on_file_removed, CONNECT_PERSIST);
	#editor_interface.file_moved.connect(self._on_file_moved);
	#editor_interface.folder_removed.connect(self._on_folder_removed);
	#editor_interface.folder_moved.connect(self._on_folder_removed);
	#editor_interface.resource_removed.connect(self._on_resource_removed);


func _on_file_removed(file: String) -> void:
	pass


func _on_button_pressed() -> void:
	pass


func _on_button_2_pressed() -> void:
	pass

