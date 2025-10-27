extends CharacterBody2D

@export var max_move_speed = 250
@export var gravity = 1200
@export var jump_power = 450
@export var max_jumps = 2
@export var acceleration = 10
@export var ground_friction = 18
@export var air_deceleration = 3
@export var coyote_time = 0.1  # sec

var jump_count = 0
var coyote_timer = 0
var was_on_floor = false

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	randomize_color()

func handle_inputs(delta):
	# Get left/right direction from inputs
	var input_direction = Input.get_axis("left", "right")
	var target_velocity_x = input_direction * max_move_speed
	
	# Flip sprite based on direction
	if input_direction != 0:
		$AnimatedSprite2D.flip_h = input_direction < 0
	
	if input_direction != 0:
		# If player is moving, accelerate in that direction
		velocity.x = lerp(velocity.x, target_velocity_x, acceleration * delta)
	else:
		# If player is not moving, decelerate to a stop
		if is_on_floor():
			velocity.x = lerp(velocity.x, 0.0, ground_friction * delta)
		else:
			velocity.x = lerp(velocity.x, 0.0, air_deceleration * delta)
	
	# Handle jumping
	if Input.is_action_just_pressed("jump") and jump_count < max_jumps:
		velocity.y = -(jump_power * (1 - (0.1 * jump_count)))
		jump_count += 1
		
	# Update color
	if Input.is_action_just_pressed("change_color"):
		randomize_color()

func _physics_process(delta: float) -> void:
	# Gravity
	velocity.y += gravity * delta
	
	# Apply user input
	handle_inputs(delta)

	# Apply movement
	move_and_slide()

	var on_floor_now = is_on_floor()

	# Coyote time
	if on_floor_now:
		coyote_timer = coyote_time  # Reset timer
		jump_count = 0
	else:
		coyote_timer = max(coyote_timer - delta, 0)  # Add delta (time passed) to the timer
	
	# Landing on the ground
	if on_floor_now and not was_on_floor:
		$AnimatedSprite2D.play("landing")
		
	# If the player is in the air, but didn't jump, spend a jump after coyote time passes
	if not on_floor_now and jump_count == 0 and coyote_timer == 0:
		jump_count = 1
	
	# Update floor flag
	was_on_floor = on_floor_now

func color_sprite(color: Color):
	# Modulate the sprite texture to the target color
	$AnimatedSprite2D.modulate = color

func randomize_color():
	# Set the sprite to a random hue
	var current_color = $AnimatedSprite2D.modulate
	# Get a random hue of the original color
	var h = rng.randf_range(0.0, 1.0)
	color_sprite(Color.from_hsv(h, 1.0, current_color.v))
