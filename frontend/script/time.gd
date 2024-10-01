extends Label

var time_elapsed = 0.0  # 經過的時間 (秒)
var seconds = 0  # 秒數
var milliseconds = 0  # 毫秒數（顯示百位和十位）

func _ready():
	# 初始化 Label 的文字
	text = "00:00"

func _process(delta):
	# 增加經過的時間
	time_elapsed += delta
	seconds = int(time_elapsed) % 60  # 取餘數計算秒數
	milliseconds = int((time_elapsed - int(time_elapsed)) * 100)  # 計算毫秒數，只取百位和十位

	# 格式化時間為 00:00 格式，並更新到 Label 上
	text = format_time(seconds, milliseconds)

# 將時間格式化為 00:00 的函數
func format_time(seconds: int, milliseconds: int) -> String:
	var seconds_str = str(seconds).pad_zeros(2)  # 格式化為兩位數的秒數
	var milliseconds_str = str(milliseconds).pad_zeros(2)  # 格式化為兩位數的毫秒數
	return seconds_str + ":" + milliseconds_str
