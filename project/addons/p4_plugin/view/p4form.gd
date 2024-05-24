@tool
class_name P4Form extends Control

@onready var text_edit: TextEdit = $VBoxContainer/HBoxContainer/TextEdit;
@onready var button: Button = $VBoxContainer/HBoxContainer/Button;
@onready var label: Label = $VBoxContainer/Label;

signal button_pressed(update_text: String);

func _ready() -> void:
	button.pressed.connect(on_button_pressed);


func on_button_pressed() -> void:
	button_pressed.emit(text_edit.text);


func set_label_text(text: String) -> void:
	label.text = text;


func set_placeholder_text(text: String) -> void:
	text_edit.placeholder_text = text;


func set_button_text(text: String) -> void:
	button.text = text;
