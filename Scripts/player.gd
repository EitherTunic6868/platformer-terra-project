extends CharacterBody2D


const SPEED = 100.0

const JUMP_VELOCITY = -300
const MAX_JUMPS = 1
var jump_count = 0

const MAX_DASH = 1
const DASH_SPEED = 900.0
@onready var dash_time: Timer = $"Dash time"
var dashing = false
var dash_count = 0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var coyote_timer: Timer = $"Coyote timer"
var was_on_floor =  is_on_floor()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction: -1, 0, 1
	var direction := Input.get_axis("Move left", "Move right")
	
	# Flips sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	# Play animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("Idle")
		else:
			animated_sprite.play("Run")
	else:
		animated_sprite.play("Jump")
	
	# Starts a dash
	if Input.is_action_just_pressed("Dash") and dash_count < MAX_DASH:
		dashing = true
		dash_count += 1
		dash_time.start()
	
	# Apply movement
	if direction:
		if dashing:
			velocity.x = direction * DASH_SPEED
		else:
			velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	
	# Checks if Coyote time should be applied
	if was_on_floor != is_on_floor():
		coyote_timer.start()

	# Handle jump/double jump.
	if Input.is_action_just_pressed("Jump") and ((is_on_floor() or !coyote_timer.is_stopped()) or jump_count < MAX_JUMPS):
		velocity.y = JUMP_VELOCITY
		jump_count += 1
	
	# Resets double jump and dash
	if is_on_floor():
		jump_count = 0
		dash_count = 0
	elif !is_on_floor() and !coyote_timer.is_stopped():
		jump_count = 0
		dash_count = 0
	

# Stops a dash
func _on_dash_time_timeout() -> void:
	dashing = false
