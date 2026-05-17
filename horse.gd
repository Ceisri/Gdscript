extends KinematicBody
var save_id = "mob"
onready var stats = $Stats
onready var ray_forward = $RayForward

var target: Node = null
var targets = []

class AggroTarget:
	var target_entity : Node
	var aggro : int

func _ready():
	find_highest_aggro_target()

func get_hit(attacker: Node, damage: float) -> void:
	var instigatorAggro = get_or_create_aggro_target(attacker)
	instigatorAggro.aggro += damage
	stats.health -= damage


func get_or_create_aggro_target(target_entity: Node) -> AggroTarget:
	for existing_target in targets:
		if existing_target.target_entity == target_entity:
			return existing_target
	var aggro_target = AggroTarget.new()
	aggro_target.target_entity = target_entity
	targets.append(aggro_target)
	return aggro_target


func find_highest_aggro_target() -> AggroTarget:
	var highest_aggro = -1
	var target : AggroTarget = null
	for aggro_target in targets:
		if aggro_target.aggro > highest_aggro:
			target = aggro_target
			highest_aggro = aggro_target.aggro
	return target


onready var tridi_label = $Name2
func display_aggro_info(aggro_info: Array):

	tridi_label.text = "\n".join(aggro_info)


func team_aggro():

	var sorted_targets = targets.duplicate()

	sorted_targets.sort_custom(self,"sort_aggro_desc")

	return sorted_targets.slice(0,min(5,sorted_targets.size()))


func sort_aggro_desc(a,b):

	return a.aggro > b.aggro


func display_aggro_player(label):

	var threat_info = []

	for aggro_target in team_aggro():

		if is_instance_valid(aggro_target.target_entity):

			threat_info.append(str(aggro_target.target_entity.name) + " : " + str(round(aggro_target.aggro)))

	label.text = "\n".join(threat_info)
