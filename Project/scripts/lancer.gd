extends KinematicBody2D

onready var sprite = get_node("sprite")
onready var dying = get_node("dying")


var health = global.lancer_health
var pos
var is_dying = false
var stab1 = false
var stab2 = false
var player_pos 
var player_body

func _ready():
	sprite.show()
	dying.hide()
	set_fixed_process(true)
	
	
func _fixed_process(delta):
	player_pos = global.playerhorse_pos
	pos = get_global_pos()
	#print(player_pos)
	if is_dying == false:
		if pos.x <= player_pos.x:
			sprite.set_frame(0)
		if pos.x > player_pos.x:
			sprite.set_frame(1)
	else:
		sprite.hide()
		dying.show()
		dying.play()
			
	if stab1 == true:
		if sprite.get_frame() == 0:
			global.player_health -= 2
	if stab2 == true:
		if sprite.get_frame() == 1:
			global.player_health -= 2
		
	

func _on_lance_hit_body_enter( body ):
	if body.get_name() == "player":
		player_body = body
		stab1 = true
		set_z(0)

func _on_lance_hit_body_exit( body ):
	if body.get_name() == "player":
		stab1 = false
		set_z(2)





func _on_lance_hitleft_body_enter( body ):
	if body.get_name() == "player":
		player_body = body
		stab2 = true
		set_z(0)

func _on_lance_hitleft_body_exit( body ):
	if body.get_name() == "player":
		stab2 = false
		set_z(2)




func _on_hit_rect_body_enter( body ):
	if body.get_groups().has("wounds"):
		body.queue_free()
		randomize()
		health -= rand_range(global.gun_dmg_min, global.gun_dmg_max)
		if health <= 0:
			is_dying = true
