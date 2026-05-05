extends Button

@onready var Manager = $"../GameManager"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var button = Button.new()
	button.pressed.connect(self._button_pressed)

func _button_pressed():
	Manager.testHand()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
