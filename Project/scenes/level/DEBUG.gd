extends Node2D


var cohesion_force: = 0.05
var align_force: = 0.05
var separation_force: = 0.025
var view_distance: = 20.0
var avoid_distance: = 50.0

var enemy_container


func set_vars():
	$Control/Cohesion/Label.text = "Cohesion Force " + str(cohesion_force)
	$Control/Alignment/Label.text = "Align Force " + str(align_force)
	$Control/Separation/Label.text = "Separation Force " + str(separation_force)
	$Control/ViewDistance/Label.text = "View Distance " + str(view_distance)
	$Control/AvoidDistance/Label.text = "Avoid Distance " + str(avoid_distance)






func _on_Cohesion_value_changed(value):
	for enemy in enemy_container.get_children():
		$Control/Cohesion/Label.text = "Cohesion Force " + str(value)
		enemy.cohesion_force = value


func _on_Alignment_value_changed(value):
	for enemy in enemy_container.get_children():
		$Control/Alignment/Label.text = "Align Force " + str(value)
		enemy.align_force = value


func _on_Separation_value_changed(value):
	for enemy in enemy_container.get_children():
		$Control/Separation/Label.text = "Separation Force " + str(value)
		enemy.separation_force = value


func _on_ViewDistance_value_changed(value):
	for enemy in enemy_container.get_children():
		$Control/ViewDistance/Label.text = "View Distance " + str(value)
		enemy.view_distance = value
		enemy.get_node("BoidArea2D/CollisionShape2D").shape.radius = enemy.view_distance


func _on_AvoidDistance_value_changed(value):
	for enemy in enemy_container.get_children():
		$Control/AvoidDistance/Label.text = "Avoid Distance " + str(value)
		enemy.avoid_distance = value
		
