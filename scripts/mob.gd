extends CharacterBody3D

# Minimum speed of the mob in meters per second.
@export var min_speed = 10
# Maximum speed of the mob in meters per second.
@export var max_speed = 18

signal squashed

func _physics_process(_delta):
	move_and_slide()

# Called from the Main scene.
func initialize(start_position, player_position):
	# Position the mob by placing it at start_position
	# and rotate it towards player_position
	look_at_from_position(start_position, player_position, Vector3.UP)
	# Rotate this mob randomly within range of -90 and +90 degrees,
	rotate_y(randf_range(-PI / 4, PI / 4))

	# Calculate a random speed
	var random_speed = randi_range(min_speed, max_speed)
	# Calculate a forward velocity that represents the speed.
	velocity = Vector3.FORWARD * random_speed
	# Rotate the velocity vector based on the mob's Y rotation
	velocity = velocity.rotated(Vector3.UP, rotation.y)
	
	$AnimationPlayer.speed_scale = random_speed / min_speed

func _on_visible_on_screen_notifier_3d_screen_exited():
	queue_free()

func squash():
	squashed.emit()
	queue_free()
