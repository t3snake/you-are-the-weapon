extends NinePatchRect

@export var label_text: String
@onready var label: Label = $Label


func _ready():
	label.text = label_text
