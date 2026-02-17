extends Node2D

@export var speed := 300.0
@export var x_limit := 300.0
@export var y_limit := 880.0

@onready var animated_sprite = $ship

# player state
enum PlayerState { NORMAL, INVINCIBLE, DEAD }
var state: PlayerState = PlayerState.NORMAL
var starttoggle = false

# invincibility
var flash_timer := 0.0
var flash_interval := 0.1 

# touch
var finger_active := false
var active_finger_index := -1
var last_finger_pos := Vector2.ZERO

# physics
var acceleration_y := 5.0
var velocity_y := 0.0


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
	
	# this block determines player speed.
	# acceleration stays constant (we can change with game state variables)
	if finger_active:
		if  self.rotation > -0.6 and starttoggle:
			self.rotation -= 0.01
		print(finger_active)
		velocity_y -= 0.1*acceleration_y
		velocity_y = max(velocity_y, -12)
	else:
		if  self.rotation < 0.6 and starttoggle:
			self.rotation += 0.01

		velocity_y -= 0.1*acceleration_y
		velocity_y = min(velocity_y, 12)

	if starttoggle:
		if self.position.y == y_limit:
			velocity_y = -1.0
			self.rotation = 0.0
		if self.position.y == -y_limit:
			velocity_y = 1.0
			self.rotation = 0.0
		self.position += Vector2(0, velocity_y)
	else:
		self.velocity_y = 5.0
		
	if state == PlayerState.INVINCIBLE:
		flash_timer += delta
		if flash_timer >= flash_interval:
			visible = not visible
			flash_timer = 0.0

func take_damage(time):
	state = PlayerState.INVINCIBLE
	velocity_y = 10.0
	invincibility_timer(time)
	self.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.1).timeout
	self.modulate = Color(1, 1, 1)

func invincibility_timer(time):
	await get_tree().create_timer(time).timeout
	state = PlayerState.NORMAL
	visible = true
