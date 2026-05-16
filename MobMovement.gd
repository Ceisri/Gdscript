extends Node

onready var controller = $".."
const GRAVITY = 12
const MOVE_SPEED = 2.0

func updateGravity(mob, delta):
	var verticalVelocity = mob.get_meta("verticalVelocity")
	# STICK TO GROUND/SLOPES
	if mob.is_on_floor():
		verticalVelocity = -1.0
	else:
		verticalVelocity -= GRAVITY * delta
	mob.set_meta("verticalVelocity",verticalVelocity)
	
func updateMovement(mob):
	var state = mob.get_meta("state")
	var verticalVelocity = mob.get_meta("verticalVelocity")
	var velocity = Vector3.ZERO
	var State = controller.State
	velocity.y = verticalVelocity
	# WALKING + AIR MOVEMENT
	if (state == State.WALK or state == State.AIR):
		var moveDirection = mob.get_meta("moveDirection")
		velocity.x = moveDirection.x * MOVE_SPEED
		velocity.z = moveDirection.z * MOVE_SPEED
		if moveDirection.length() > 0.1:
			mob.look_at(mob.global_transform.origin- moveDirection,Vector3.UP)
	# STRONGER SNAP FOR SLOPES
	if state == State.DEAD:
		velocity.x = 0
		velocity.z = 0
	mob.move_and_slide_with_snap(velocity,Vector3.DOWN * 2.0,Vector3.UP,true,4,deg2rad(45.0))
