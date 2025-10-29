extends CharacterBody2D

@export var max_move_speed = 190
@export var gravity = 1200
@export var jump_power = 400
@export var max_jumps = 2
@export var acceleration = 10
@export var ground_friction = 18
@export var air_deceleration = 3
@export var coyote_time = 0.1  # sec
@export var push_force = 5

var jump_count = 0
var coyote_timer = 0
var was_on_floor = false

var color_idx = 1

const COLORS = [
	Color(1, 0, 0),
	Color(0, 0.8, 0.023),
	Color(0, 0.69, 1),
]

func _ready() -> void:
	# Step back to red to start
	next_color(true)

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
		#$AnimatedSprite2D.play("jumping")
		pass
		
	# Update color
	if Input.is_action_just_pressed("cycle_left"):
		next_color(true)
	if Input.is_action_just_pressed("cycle_right"):
		next_color()

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
		$"Sound Effect Player".stream = preload("res://assets/sound_effects/ground_hit.wav")
		$"Sound Effect Player".play()
		
	# If the player is in the air, but didn't jump, spend a jump after coyote time passes
	if not on_floor_now and jump_count == 0 and coyote_timer == 0:
		jump_count = 1
	
	# Update floor flag
	was_on_floor = on_floor_now
	
	# Handle pushing
	for i in range(get_slide_collision_count()):
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force)
			

	# Choose the right animation
	if $AnimatedSprite2D.animation != "landing":
		if on_floor_now:
			if (velocity.x) > 10:
				$AnimatedSprite2D.play("moving")
			else:
				$AnimatedSprite2D.play("idle")
		else:
			if velocity.y < 0:
				$AnimatedSprite2D.play("jumping")
			else:
				$AnimatedSprite2D.play("falling")



func color_sprite(color: Color):
	# Modulate the sprite texture to the target color
	$AnimatedSprite2D.modulate = color

func next_color(back=false):
	var di = -1 if back else 1	
	# Step the index by one (wrap around at the ends)
	var new_color_idx = ((color_idx + di) % len(COLORS) + len(COLORS)) % len(COLORS)
	# Update the color
	set_color(new_color_idx)
	
func set_color(new_color_idx: int):
	# Remove collision for the previous color
	set_collision_mask_value(color_idx + 2, false)
	
	color_idx = new_color_idx
	
	# Add collision for the new color
	set_collision_mask_value(color_idx + 2, true)
	color_sprite(COLORS[color_idx])
	
	$"Sound Effect Player".stream = preload("res://assets/sound_effects/phase_sound.wav")
	$"Sound Effect Player".play()


func _on_animated_sprite_2d_animation_finished() -> void:
	var anim_name = $AnimatedSprite2D.animation
	if anim_name == "landing":
		if abs(velocity.x) > 10:
			$AnimatedSprite2D.play("moving")
		else:
			$AnimatedSprite2D.play("idle")
