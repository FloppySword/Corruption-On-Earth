extends Node2D

var target_force = Global.target_force
var cohesion_force = Global.cohesion_force
var align_force = Global.align_force
var separation_force = Global.separation_force
var view_distance = Global.view_distance
var avoid_distance = Global.avoid_distance

var enemy_container

var DEBUG = false

func _ready():
	yield(get_tree().create_timer(.05), "timeout")
	$Control/Target.value = target_force
	$Control/Cohesion.value = cohesion_force
	$Control/Alignment.value = align_force
	$Control/Separation.value = separation_force
	$Control/ViewDistance.value = view_distance
	$Control/AvoidDistance.value = avoid_distance
	


func set_vars():
	if !DEBUG:
		return
		
	
	Global.target_force = target_force
	Global.cohesion_force = cohesion_force
	Global.align_force = align_force
	Global.separation_force = separation_force
	Global.view_distance = view_distance
	Global.avoid_distance = avoid_distance
	$Control/Target/Label.text = "Target Force " + str(target_force)
	$Control/Cohesion/Label.text = "Cohesion Force " + str(cohesion_force)
	$Control/Alignment/Label.text = "Align Force " + str(align_force)
	$Control/Separation/Label.text = "Separation Force " + str(separation_force)
	$Control/ViewDistance/Label.text = "View Distance " + str(view_distance)
	$Control/AvoidDistance/Label.text = "Avoid Distance " + str(avoid_distance)
	for enemy in enemy_container.get_children():
		enemy.target_force = Global.target_force
		enemy.cohesion_force = Global.cohesion_force
		enemy.align_force = Global.align_force
		enemy.separation_force = Global.separation_force
		enemy.view_distance = Global.view_distance
		enemy.get_node("BoidArea2D/CollisionShape2D").shape.radius = enemy.view_distance
		enemy.avoid_distance = Global.avoid_distance


func _on_Target_value_changed(value):
	target_force = value
	set_vars()

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
		

