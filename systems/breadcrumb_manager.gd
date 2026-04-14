extends Node

class Breadcrumb:
	var position: Vector2
	var timestamp: float
	
	func _init(pos: Vector2, time: float):
		position = pos
		timestamp = time

var breadcrumbs: Array[Breadcrumb] = []
const MAX_BREADCRUMBS = 50
const BREADCRUMB_LIFESPAN = 10.0 # seconds

func add_breadcrumb(pos: Vector2) -> void:
	var now = Time.get_ticks_msec() / 1000.0
	breadcrumbs.append(Breadcrumb.new(pos, now))
	if breadcrumbs.size() > MAX_BREADCRUMBS:
		breadcrumbs.remove_at(0)

func _process(delta: float) -> void:
	var now = Time.get_ticks_msec() / 1000.0
	var i = 0
	while i < breadcrumbs.size():
		if now - breadcrumbs[i].timestamp > BREADCRUMB_LIFESPAN:
			breadcrumbs.remove_at(i)
		else:
			i += 1

func get_next_target(from_pos: Vector2, player_pos: Vector2, space_state: PhysicsDirectSpaceState2D, mask: int) -> Vector2:
	# 1. Check if player is visible
	var query = PhysicsRayQueryParameters2D.create(from_pos, player_pos, mask)
	var result = space_state.intersect_ray(query)
	if not result:
		return player_pos
	
	# 2. Check breadcrumbs from NEWEST to OLDEST
	# We want the "latest" one we can still see, which will lead us around the corner
	var latest_visible: Vector2 = Vector2.ZERO
	for i in range(breadcrumbs.size() - 1, -1, -1):
		var b = breadcrumbs[i]
		
		# Skip breadcrumbs that are too far to be relevant for local navigation?
		# No, we want to find the corner we can see.
		var b_query = PhysicsRayQueryParameters2D.create(from_pos, b.position, mask)
		var b_result = space_state.intersect_ray(b_query)
		
		if not b_result:
			return b.position
			
	# 3. Fallback: if no breadcrumbs are visible, find the CLOSEST one even if not visible
	# This helps them head towards the trail even if they are behind a thick wall.
	var min_dist = 999999.0
	var closest_pos = player_pos
	for b in breadcrumbs:
		var d = from_pos.distance_to(b.position)
		if d < min_dist:
			min_dist = d
			closest_pos = b.position
			
	return closest_pos
