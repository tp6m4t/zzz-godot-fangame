extends PanelContainer
class_name PostCard


func _ready() -> void:
	title_label.text = post_title
	content_label.text = post_content
	user_name_label.text = post_user_name
	if post_image:
		image_rect.texture = post_image
	if post_avatar:
		avatar_image_rect.texture = post_avatar


@onready var title_label: Label = $DiscussionCard/CardContentMargin/CardContent/TextContentMargin/VBoxContainer/MarginContainer2/TitleLabel
## 貼文設定標題文字
@export var post_title: String = "":
	set(value):
		post_title = value
		if title_label:
			title_label.text = post_title


@onready var content_label: Label = $DiscussionCard/CardContentMargin/CardContent/TextContentMargin/VBoxContainer/ContentLabel
## 貼文內容文字(超出顯示省略號)
@export var post_content: String = "":
	set(value):
		post_content = value
		if content_label:
			content_label.text = post_content


@onready var image_rect: TextureRect = $DiscussionCard/ImagePanel/TextureRect
## 貼文圖片
@export var post_image: Texture2D:
	set(value):
		post_image = value
		if image_rect:
			image_rect.texture = post_image


@onready var avatar_image_rect: TextureRect = $DiscussionCard/CardContentMargin/CardContent/AuthorSectionMargin/Container/Panel/Panel2/TextureRect
## 貼文用戶頭像圖片
@export var post_avatar: Texture2D:
	set(value):
		post_avatar = value
		if avatar_image_rect:
			avatar_image_rect.texture = post_avatar


@onready var user_name_label: Label = $DiscussionCard/CardContentMargin/CardContent/AuthorSectionMargin/Container/Control/UserNameLabel
## 貼文用戶名稱文字
@export var post_user_name: String = "":
	set(value):
		post_user_name = value
		if user_name_label:
			user_name_label.text = post_user_name
