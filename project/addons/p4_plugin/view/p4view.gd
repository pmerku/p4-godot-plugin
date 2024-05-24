@tool
class_name P4View extends Control

var root_path: String;
var p4_port: String;
var p4_client: String;
var p4_ignore_path: String;

@onready var form_root_path: P4Form = $MarginContainer/VBoxContainer/VBoxContainer/Form_RootPath;
@onready var form_port: P4Form = $MarginContainer/VBoxContainer/VBoxContainer/Form_Port;
@onready var form_client: P4Form = $MarginContainer/VBoxContainer/VBoxContainer/Form_Client;
@onready var form_ignore: P4Form = $MarginContainer/VBoxContainer/VBoxContainer/Form_Ignore;

@onready var btn_vcs_metadata: Button = $MarginContainer/VBoxContainer/HBoxContainer/Btn_VCSMetadata;
@onready var btn_vcs_config: Button = $MarginContainer/VBoxContainer/HBoxContainer/Btn_VCSConfig;
@onready var btn_save: Button = $MarginContainer/VBoxContainer/HBoxContainer/Btn_Save;
@onready var btn_reload: Button = $MarginContainer/VBoxContainer/HBoxContainer/Btn_ReloadSave;
@onready var btn_reconcile: Button = $MarginContainer/VBoxContainer/HBoxContainer2/Btn_Reconcile;

func _ready() -> void:
	btn_vcs_metadata.pressed.connect(on_btn_vcs_metadata_pressed);
	btn_vcs_config.pressed.connect(on_btn_vcs_config_pressed);
	btn_save.pressed.connect(on_btn_save_pressed);
	btn_reload.pressed.connect(on_btn_reload_pressed);
	btn_reconcile.pressed.connect(on_btn_reconcile_pressed);
	
	setup_form(form_root_path, "Root path", OS.get_executable_path().get_base_dir(), on_root_path_updated);
	setup_form(form_port, "P4PORT", "Enter your p4 server url (example ssl:127.0.0.1:1666)", on_port_updated);
	setup_form(form_client, "P4CLIENT", "Enter your p4 worspace name", on_client_updated);
	setup_form(form_ignore, "P4IGNORE", OS.get_executable_path().get_base_dir() + "/.p4ignore", on_ignore_updated);
	
	load_plugin_config();
	
	# TODO:
	# instead of listening to _apply_changes, to improve performance
	# we could do specific p4 actions
	# ex:
	# - file created -> p4 add
	# - file removed -> p4 delete
	# - file edited -> p4 edit
	# - file rename / move -> p4 move
	#var editor_interface: FileSystemDock = EditorInterface.get_file_system_dock();
	#editor_interface.file_removed.connect(self._on_file_removed, CONNECT_PERSIST);
	#editor_interface.file_moved.connect(self._on_file_moved);
	#editor_interface.folder_removed.connect(self._on_folder_removed);
	#editor_interface.folder_moved.connect(self._on_folder_removed);
	#editor_interface.resource_removed.connect(self._on_resource_removed);


func setup_form(form: P4Form, label_text:String, placeholder_text: String, callback: Callable) -> void:
	form.set_label_text(label_text);
	form.set_placeholder_text(placeholder_text);
	form.set_button_text("Update");
	form.button_pressed.connect(callback);


func is_path_valid(path: String) -> bool:
	var dir: DirAccess = DirAccess.open(path);
	
	if dir == null:
		printerr("An error occurred when trying to access the path: [%s]" % [path]);
		return false;
	else:
		return true;


func file_exists(file_path: String) -> bool:
	return FileAccess.file_exists(file_path);


func on_btn_vcs_metadata_pressed() -> void:
	if is_path_valid(root_path):
		generate_vcs_metadata();


func on_btn_vcs_config_pressed() -> void:
	if is_path_valid(root_path):
		generate_vcs_config_file();


func on_btn_save_pressed() -> void:
	save_plugin_config();
	print("Saved configuration to [user://p4plugin.cfg]");


func on_btn_reload_pressed() -> void:
	load_plugin_config();
	print("Configuration [user://p4plugin.cfg] loaded");


func on_btn_reconcile_pressed() -> void:
	if root_path.is_empty():
		printerr("Perforce is not setup yet, please update all the info first!");
		return;
	
	var output = [];
	var exit_code: int;
	
	match OS.get_name():
		"Windows":
			OS.execute("cmd.exe", ["/c", "cd /d %s & p4 reconcile -m" % root_path], output);
		_:
			OS.execute("/bin/bash", ["cd %s; p4 reconcile -m" % root_path], output);
	
	if exit_code != 0:
		print("Failed to run command!\n");
		print(output);


func on_root_path_updated(new_root_path: String) -> void:
	if is_path_valid(new_root_path) && new_root_path != root_path:
		root_path = new_root_path;
		print("Root path updated to [%s]" % root_path);


func on_port_updated(new_port: String) -> void:
	if new_port != p4_port:
		p4_port = new_port;
		save_plugin_config();
		print("P4PORT updated to [%s]" % p4_port);


func on_client_updated(new_client: String) -> void:
	if new_client != p4_client:
		p4_client = new_client;
		save_plugin_config();
		print("P4CLIENT updated to [%s]" % p4_client);


func on_ignore_updated(new_ignore_path: String) -> void:
	if is_path_valid(new_ignore_path.get_base_dir()) && new_ignore_path != p4_ignore_path:
		p4_ignore_path = new_ignore_path;
		save_plugin_config();
		print("P4IGNORE file set to [%s]" % p4_ignore_path);


func generate_vcs_metadata() -> void:
	print("Generating VCS metadata...");
	
	var file_path: String = "%s/.p4ignore" % root_path;
	if FileAccess.file_exists(file_path):
		print("The file .p4ignore already exists... overwriting...");
	
	var ignore_file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE);
	if ignore_file == null:
		printerr("Failed to create .p4ignore file!");
		return;
	
	ignore_file.store_line("# P4");
	ignore_file.store_line(".p4config");
	ignore_file.store_line("");
	ignore_file.store_line("# Git");
	ignore_file.store_line(".git/");
	ignore_file.store_line("# Godot 4+");
	ignore_file.store_line(".godot/");
	ignore_file.store_line(".import/");
	ignore_file.store_line("export.cfg");
	ignore_file.store_line("export_presets.cfg");
	ignore_file.store_line("*.tmp");
	ignore_file.store_line("");
	ignore_file.store_line("# Imported translations (automatically generated from CSV files)");
	ignore_file.store_line("*.translations");
	ignore_file.store_line("");
	ignore_file.store_line("# Mono");
	ignore_file.store_line(".mono/");
	ignore_file.store_line("data_*/");
	ignore_file.store_line("mono_crash.*.json");
	
	print("Generating VCS metadata completed");


func generate_vcs_config_file() -> void:
	if p4_port.is_empty() || p4_client.is_empty() || p4_ignore_path.is_empty():
		printerr("Perforce is not setup yet, please update all the info first!");
		return;
	
	print("Generating VCS config...");
	
	var file_path: String = "%s/.p4config" % root_path;
	if FileAccess.file_exists(file_path):
		print("The file .p4config already exists... overwriting...");
	
	var config_file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE);
	if config_file == null:
		printerr("Failed to create .p4config file!");
		return;
	
	config_file.store_line("P4PORT=%s" % p4_port);
	config_file.store_line("P4CLIENT=%s" % p4_client);
	config_file.store_line("P4IGNORE=%s" % p4_ignore_path);
	
	var output = [];
	var exit_code: int;
	
	match OS.get_name():
		"Windows":
			OS.execute("cmd.exe", ["/c", "p4 set P4CONFIG=%s" % file_path], output);
		_:
			OS.execute("/bin/bash", ["export P4CONFIG=%s" % file_path], output);
	
	if exit_code != 0:
		print("Failed to run command!\n");
		print(output);
	
	print("Generating VCS config completed");


func load_plugin_config() -> void:
	var config: ConfigFile = ConfigFile.new();
	var err = config.load("user://p4plugin.cfg");
	if err != OK:
		return;
	
	for setting in config.get_sections():
		var cfg_root_path: String = config.get_value("p4plugin", "root_path");
		if !cfg_root_path.is_empty():
			root_path = cfg_root_path;
			form_root_path.text_edit.text = root_path;
		
		var cfg_port: String = config.get_value("p4plugin", "p4_port");
		if !cfg_port.is_empty():
			p4_port = cfg_port;
			form_port.text_edit.text = p4_port;
		
		var cfg_client: String = config.get_value("p4plugin", "p4_client");
		if !cfg_client.is_empty():
			p4_client = cfg_client;
			form_client.text_edit.text = p4_client;
		
		var cfg_ignore: String = config.get_value("p4plugin", "p4_ignore_path");
		if !cfg_ignore.is_empty():
			p4_ignore_path = cfg_ignore;
			form_ignore.text_edit.text = p4_ignore_path;


func save_plugin_config() -> void:
	var plugin_config: ConfigFile = ConfigFile.new();
	
	if !root_path.is_empty():
		plugin_config.set_value("p4plugin", "root_path", root_path);
	
	if !p4_port.is_empty():
		plugin_config.set_value("p4plugin", "p4_port", p4_port);
	
	if !p4_client.is_empty():
		plugin_config.set_value("p4plugin", "p4_client", p4_client);
	
	if !p4_ignore_path.is_empty():
		plugin_config.set_value("p4plugin", "p4_ignore_path", p4_ignore_path);
	
	plugin_config.save("user://p4plugin.cfg");
	
