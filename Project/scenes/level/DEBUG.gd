extends Node2D


var cohesion_force: = global.cohesion_force
var align_force: = global.align_force
var separation_force: = global.separation_force
var view_distance: = global.view_distance
var avoid_distance: = global.avoid_distance

var enemy_container


func set_vars():
	global.cohesion_force = cohesion_force
	global.align_force = align_force
	global.separation_force = separation_force
	global.view_distance = view_distance
	global.avoid_distance = avoid_distance
	$Control/Cohesion/Label.text = "Cohesion Force " + str(cohesion_force)
	$Control/Alignment/Label.text = "Align Force " + str(align_force)
	$Control/Separation/Label.text = "Separation Force " + str(separation_force)
	$Control/ViewDistance/Label.text = "View Distance " + str(view_distance)
	$Control/AvoidDistance/Label.text = "Avoid Distance " + str(avoid_distance)
	for enemy in enemy_container.get_children():
		enemy.cohesion_force = global.cohesion_force
		enemy.align_force = global.align_force
		enemy.separation_force = global.separation_force
		enemy.view_distance = global.view_distance
		enemy.get_node("BoidArea2D/CollisionShape2D").shape.radius = enemy.view_distance
		enemy.avoid_distance = global.avoid_distance



func _on_Cohesion_value_changed(value):
	cohesion_force = value
	set_vars()
	

func _on_Alignment_value_changed(value):
	align_force = value
	set_vars()


func _on_Separation_value_changed(value):
	separation_force = value
	set_vars()


func _on_ViewDistance_value_changed(value):
	view_distance = value
	set_vars()

func _on_AvoidDistance_value_changed(value):
	avoid_distance = value
	set_vars()
		
