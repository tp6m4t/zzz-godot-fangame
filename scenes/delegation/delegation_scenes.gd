extends Control

@onready var post_cards_flow_container: HFlowContainer = $PanelContainer/PanelContainer3/ScrollContainer/HFlowContainer


func _ready() -> void:
	_post_cards_init()
	read_inter_knot_config()


var inter_knot_data := {}
func _post_cards_init():
	read_inter_knot_config()
	for child in post_cards_flow_container.get_children():
		child.queue_free()
	for inter_knot in inter_knot_data.posts:
		var post_card_scene = preload("res://scenes/delegation/post_card.tscn")
		var post_card := post_card_scene.instantiate()
		if (inter_knot.get('title')):
			post_card.post_title = inter_knot.title
		if (inter_knot.get('content')):
			post_card.post_content = inter_knot.content
		if (inter_knot.get('user_name')):
			post_card.post_user_name = inter_knot.user_name
		if (inter_knot.get('post_image_path')):
			var loaded_resource = load(inter_knot.post_image_path)
			if loaded_resource is Texture2D:
				post_card.post_image = loaded_resource
		if (inter_knot.get('user_avatar_path')):
			var loaded_resource = load(inter_knot.user_avatar_path)
			if loaded_resource is Texture2D:
				post_card.avatar_path = loaded_resource
		post_cards_flow_container.add_child(post_card)


func read_inter_knot_config() -> void:
	var config_path := 'res://config/inter_knot.json'

	var file := FileAccess.open(config_path, FileAccess.READ)
	if file:
		var json_string := file.get_as_text()
		file.close()
		var json := JSON.new()
		var parse_result := json.parse(json_string)
		if parse_result == OK:
			inter_knot_data = json.get_data()
		else:
			printerr('parse inter_knot config json error')

	else:
		printerr('read inter_knot config error')
