extends Node


onready var controller = $".."

func updateAnimation(mob):

	var animationPlayer = mob.get_node("AnimationPlayer")
	var state = mob.get_meta("state")
	var stats = mob.get_node("Stats")
	var is_finished = stats.is_finished
	var State = controller.State
	
	
	if state == State.IDLE:
		if animationPlayer.current_animation != "idle_cycle":
			animationPlayer.play("idle_cycle")
	elif state == State.WALK:
		if animationPlayer.current_animation != "walk_cycle":
			animationPlayer.play("walk_cycle")
	elif state == State.EAT:
		if animationPlayer.current_animation != "eat_cycle":
			animationPlayer.play("eat_cycle")
	elif state == State.AIR:
		if animationPlayer.current_animation != "air_cycle":
			animationPlayer.play("air_cycle")
	elif state == State.DEAD:
		if !is_finished:
			animationPlayer.play("die")
		else:
			animationPlayer.play("dead")
