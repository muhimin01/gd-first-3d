extends CharacterBody3D

# How fast the player moves in meters per second
@export var speed = 14
# The downward acceleration when in the air, in meters per second squared
@export var fall_acceleration = 75
# Vertical impulse applied to the character upon jumping in meters per second
@export var jump_impulse = 20
# Vertical impulse applied to the character upon bouncing over a mob in meters per second.
@export var bounce_impulse = 16

# Emitted when the player is hit by an enemy
signal hit

var target_velocity = Vector3.ZERO

func _physics_process(delta):
	# Store input direction
	var direction = Vector3.ZERO
	
	# Check for each movement input update direction accordidngly
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		$Pivot.look_at(position + direction, Vector3.UP)
		$AnimationPlayer.speed_scale = 4
	else:
		$AnimationPlayer.speed_scale = 1
	
	# Ground velocity
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed
	
	# Vertical velocity
	if not is_on_floor():
		target_velocity.y -= fall_acceleration * delta
	
	# Jumping
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		target_velocity.y = jump_impulse
	
	# Itterate all collisions that occured this frame
	for index in range(get_slide_collision_count()):
		# Get one of the collisions with the player
		var collision = get_slide_collision(index)
		
		# If collision is with ground
		if collision.get_collider() == null:
			continue
		
		# If collision is with mob
		if collision.get_collider().is_in_group("mob"):
			var mob = collision.get_collider()
			# Check if collision is from above the mob
			if Vector3.UP.dot(collision.get_normal()) > 0.1:
				# Despawn the mob and bounce
				mob.squash()
				target_velocity.y = bounce_impulse
				# Prevent further duplicate calls
				break
	
	velocity = target_velocity
	move_and_slide()
	
	$Pivot.rotation.x = PI / 6 * velocity.y / jump_impulse

func die():
	hit.emit()
	queue_free()

func _on_mob_detector_body_entered(body):
	die()
