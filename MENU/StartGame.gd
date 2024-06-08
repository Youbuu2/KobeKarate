extends Button

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	# Initialization code here. 
	pass

# This function is called when the button is pressed.
func _pressed():
	# Ensure the path to the scene file is correct and accessible.
	get_tree().change_scene("res://Stages/TestStage.tscn")

# Uncomment the below function if you need something to happen every frame.
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
