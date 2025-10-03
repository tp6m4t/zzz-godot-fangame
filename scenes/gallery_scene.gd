extends Control
var gallery_data := {}

var main_scene_path := 'res://scenes/main_scene.tscn'
func _ready() -> void:
	$ButtonList/Back.pressed.connect(get_tree().change_scene_to_file.bind(main_scene_path))
	read_config()
	for tab_bar_name in gallery_data:
		var button := Button.new()
		button.text = tab_bar_name
		button.pressed.connect(change_tab.bind(tab_bar_name))
		$ButtonList.add_child(button)
	if len(gallery_data.keys()) > 0:
		change_tab(gallery_data.keys()[0])


var item_path := 'res://scenes/gallery/item_scene.tscn'

const config_path := 'res://config/gallery.json'
'''
利用gallery.json初始化圖鑑數據
'''
func read_config() -> void:
	var file := FileAccess.open(config_path, FileAccess.READ)
	if file:
		var json_string := file.get_as_text()
		file.close()
		var json := JSON.new()
		var parse_result := json.parse(json_string)
		if parse_result == OK:
			gallery_data = json.get_data()

		else:
			printerr('parse gallery config json error')

	else:
		printerr('read gallery config error')

func change_tab(tab_name: String) -> void:
	if not gallery_data.has(tab_name):
		printerr("no tab name:  ", tab_name)
		return

	var grid_container := $Tab/GridContainer
	for child in grid_container.get_children():
		child.queue_free()
	for item in gallery_data[tab_name]:
		var button := TextureButton.new()
		var image_path: String = item.get('image_path', '')
		var tex: Texture2D = load(image_path)
		if tex == null:
			printerr("無法載入圖片: ", image_path)
			continue
		button.texture_normal = tex
		button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		button.pressed.connect(show_detail.bind(item))
		grid_container.add_child(button)

	print('show tab ', tab_name)
	

func show_detail(item: Dictionary) -> void:
	var label: Label = $Tab/Detail/Label
	var image: TextureRect = $Tab/Detail/TextureRect


	label.text = item.get('detail', '')
	var tex: Texture2D = load(item.get('image_path', ''))
	if tex:
		image.texture = tex
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	else:
		printerr("無法載入圖片: ", item.get('image_path', ''))
