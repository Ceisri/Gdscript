extends Node


onready var state_node = $".."


func updateAnimation(mob):
	var animation_player = mob.get_node("AnimationPlayer")
	var stats = mob.get_node("Stats")
	var is_finished = stats.is_finished
	if mob.get_meta("state"):
		var state = mob.get_meta("state")
		match state:
			"wander":
				wanderAnimations(mob,animation_player)
			"dying":
				animation_player.play("die")
			"dead":
				animation_player.play("dead")
			"chase":
				animation_player.play("run_cycle")
			"fight":
				combatAnimations(mob)




func combatAnimations(mob)->void:
	if mob.attacks:
		mob.attacks.combat()


func wanderAnimations(mob,animation_player):
	wolfAnimations(mob,animation_player)


func wolfAnimations(mob,animation_player):
	if mob.has_meta("is_stopped") and mob.get_meta("is_stopped"):
		animation_player.play("idle_cycle")
	else:
		animation_player.play("walk_cycle")
	
