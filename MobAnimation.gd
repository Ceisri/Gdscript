extends Node


onready var state_node = $".."


func updateAnimation(mob):
	var animation_player = mob.get_node("AnimationPlayer")
	var state = mob.get_meta("state")
	var stats = mob.get_node("Stats")
	var is_finished = stats.is_finished
	match state:
		"wander":
				wanderAnimations(mob,animation_player)
		"dying":
			animation_player.play("die")
		"dead":
			animation_player.play("dead")




func wanderAnimations(mob,animation_player):
	if mob.is_in_group("Entity"):
			if mob.is_in_group("Wolf"):
				wolfAnimations(mob,animation_player)

				

func wolfAnimations(mob,animation_player):
	if mob.has_meta("is_stopped") and mob.get_meta("is_stopped"):
		animation_player.play("idle_cycle")
	else:
		animation_player.play("walk_cycle")
	
