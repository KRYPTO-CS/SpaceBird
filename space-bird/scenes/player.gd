extends Node2D

@export var speed := 300.0
@export var x_limit := 300.0
@export var y_limit := 880.0

@onready var animated_sprite = $ship


enum PlayerState { NORMAL, DEAD }
var state: PlayerState = PlayerState.NORMAL
var starttoggle = false

# touch
var finger_active := false
var active_finger_index := -1
var last_finger_pos := Vector2.ZERO

# physics
var acceleration_y := 1.0
var velocity_y := 5.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animated_sprite.play("default")
	
	
func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed and active_finger_index == -1:
			active_finger_index = event.index
			acceleration_y = 1
			finger_active = true
			last_finger_pos = event.position
			starttoggle = true
			print("touch")
		elif not event.pressed and event.index == active_finger_index:
			finger_active = false
			acceleration_y = -1
			active_finger_index = -1
			print("let go")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	position.y = clamp(position.y, -y_limit, y_limit)
	
	if finger_active:
		if  self.rotation > -0.75:
			self.rotation -= 0.01
		print(finger_active)
		velocity_y -= 0.04*acceleration_y
		velocity_y = max(velocity_y, -5)
	else:
		if  self.rotation < 0.75:
			self.rotation += 0.01

		velocity_y -= 0.04*acceleration_y
		velocity_y = min(velocity_y, 5)

	if starttoggle:
		self.position += Vector2(0, velocity_y)
