extends AnimatedSprite


var starting_x:float = 0
var enemyLeft = null
var enemyRight = null

signal remove_enemies

"""
Note: This effect is currently not being used in-game.
"""

func _initiate(_enemyLeft, _enemyRight, start_pos):
	
	# The starting_x variable is used in _process to ensure that
	# the effect doesn't shift around along with its parent (the enemy
	# vehicle). 
	starting_x = start_pos.x
	
	global_position = start_pos
	frame = 0
	play("default")
	
	# Track the two enemies who collided. If this explosion wasn't
	# the result of a collision but perhaps say a landmine detonation,
	# then _enemyRight would be kept null. 
	enemyLeft = _enemyLeft
	enemyRight = _enemyRight

	

func _process(delta):
	if starting_x:
		global_position.x = starting_x
		# Ground_vel is too fast for this effect so we halve it.
		global_position += (Global.ground_vel / 2) * delta
	
	# Disable collision shapes of colliding enemy vehicles as soon as
	# the effect is initiated.
	# After three frames (frame = 2) of the animation, queue_free them.
	# This node will queue_free automatically after it passes the 
	# global bounds. 
	if enemyLeft:
		#print(enemyLeft.name)
		enemyLeft.get_node("CollisionShape2D").disabled = true
		if frame == 2:
			enemyLeft.queue_free()
			enemyLeft = null
			return
		enemyLeft.global_position = global_position
	if enemyRight:
		#print(enemyRight.name)
		enemyRight.get_node("CollisionShape2D").disabled = true
		if frame == 2:
			enemyRight.queue_free()
			enemyRight = null
			return
		enemyRight.global_position = global_position

