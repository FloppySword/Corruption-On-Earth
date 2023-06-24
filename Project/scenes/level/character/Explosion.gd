extends AnimatedSprite

signal remove_enemies

var starting_x = null
var enemyLeft = null
var enemyRight = null

func init(_enemyLeft, _enemyRight, start_pos):
	global_position = start_pos
	starting_x = start_pos.x
	frame = 0
	play("default")
	enemyLeft = _enemyLeft
	enemyRight = _enemyRight

	

func _process(delta):
	if starting_x:
		global_position.x = starting_x
		global_position += (Global.ground_vel / 2) * delta

	

		#emit_signal("remove_enemies", enemyLeft, enemyRight)
	
	if enemyLeft:
		print(enemyLeft.name)
		enemyLeft.get_node("CollisionShape2D").disabled = true
		if frame == 2:
			enemyLeft.queue_free()
			enemyLeft = null
			return
		enemyLeft.global_position = global_position
	if enemyRight:
		print(enemyRight.name)
		enemyRight.get_node("CollisionShape2D").disabled = true
		if frame == 2:
			enemyRight.queue_free()
			enemyRight = null
			return
		enemyRight.global_position = global_position

