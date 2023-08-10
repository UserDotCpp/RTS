extends Node

var list_of_unit_clustered = []
var amount_of_unit_clusters = 0
var global_cluster_number = 0

var unit_clustered_log

func create_unit_cluster(selected_units,goal_position,amount_of_units) -> void:
	global_cluster_number += 1
	for unit in selected_units:
		unit.cluster_id = global_cluster_number
	list_of_unit_clustered.append([selected_units,goal_position,amount_of_units])

func find_all_units_in_the_stoped_clustered(refence_cluster_id) -> void:
	for units in list_of_unit_clustered[refence_cluster_id-1][0]:
		if units.cluster_id == refence_cluster_id and !units.cluster_resolved:
			units.resolve_cluster()


func cluster_of_units_in_destination(selected_units) -> void:
	for unit in selected_units:
		unit.resolve_cluster()

