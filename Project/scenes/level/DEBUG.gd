extends Node2D

"""
To use this feature, set the boolean "DEBUG" export variable to true in Level1.tscn.
"""

var target_force:float = Global.target_force
var cohesion_force:float = Global.cohesion_force
var alignment_force:float = Global.alignment_force
var separation_force:float = Global.separation_force
var view_distance:float = Global.view_distance
var avoid_distance:float = Global.avoid_distance

var enemy_container

var DEBUG = false

func _ready():
	yield(get_tree().create_timer(.05), "timeout")
	$Control/Target.value = target_force
	$Control/Cohesion.value = cohesion_force
	$Control/Alignment.value = alignment_force
	$Control/Separation.value = separation_force
	$Control/ViewDistance.value = view_distance
	$Control/AvoidDistance.value = avoid_distance


func set_vars():
	if !DEBUG:
		return
		
	# Sets the global enemy boid variables so that future instances of enemies
	# spawn with these settings.
	Global.target_force = target_force
	Global.cohesion_force = cohesion_force
	Global.alignment_force = alignment_force
	Global.separation_force = separation_force
	Global.view_distance = view_distance
	Global.avoid_distance = avoid_distance
	
	# Updates the label values on the debug GUI
	$Control/Target/Label.text = "Target Force " + str(target_force)
	$Control/Cohesion/Label.text = "Cohesion Force " + str(cohesion_force)
	$Control/Alignment/Label.text = "Align Force " + str(alignment_force)
	$Control/Separation/Label.text = "Separation Force " + str(separation_force)
	$Control/ViewDistance/Label.text = "View Distance " + str(view_distance)
	$Control/AvoidDistance/Label.text = "Avoid Distance " + str(avoid_distance)
	
	# Sets existing enemies' boid variables so that their behavior changes in real-time.
	for enemy in enemy_container.get_children():
		enemy.target_force = Global.target_force
		enemy.cohesion_force = Global.cohesion_force
		enemy.alignment_force = Global.alignment_force
		enemy.separation_force = Global.separation_force
		enemy.view_distance = Global.view_distance
		enemy.get_node("BoidArea2D/CollisionShape2D").shape.radius = enemy.view_distance
		enemy.avoid_distance = Global.avoid_distance
		

# These are signal functions that fire when the slider is dragged by the user
func _on_Target_value_changed(value):
	target_force = value
	set_vars()

func _on_Cohesion_value_changed(value):
	cohesion_force = value
	set_vars()
	
func _on_Alignment_value_changed(value):
	alignment_force = value
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
		

