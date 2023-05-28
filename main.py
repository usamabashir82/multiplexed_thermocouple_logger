from flask import Flask, render_template, jsonify, send_from_directory
import random
import time
from thermocouple_if import Thermocouple_IF
from rethink_db import RethinkDBConnection
from threading import Thread

RETHINK_CONFIGS = {
	"host":'rethinkdb',
	"port":28015,
	"db_name":'test',
	"username":'admin',
	"password":''
}
app = Flask(__name__)

@app.route('/')
def index():
	return render_template('line_chart.html')

@app.route('/data')
def data():
	value = random.randint(0, 100)
	timestamp = int(time.time() * 1000)
	return jsonify({'value': value, 'timestamp': timestamp})

@app.route('/data_line')
def data_line():
	data = get_data_line()
	# print(data)
	return jsonify(data)

@app.route('/data_bar')
def data_bar():
	data = get_data_bar()
	# print(data)
	return jsonify(data)

@app.route('/update')
def update():
	data = {'value': random.randint(0, 100), 'timestamp': int(time.time() * 1000)}
	return render_template('index.html', data=data)

@app.route('/js/line_chart.js')
def send_line_chart_js():
	return send_from_directory('static/js', 'line_chart.js')

@app.route('/buttons.css')
def send_button_css():
	return send_from_directory('static/css', 'button.css')

def get_data_line():
	out_data_dict = {
		'labels': [],
		'data0': [],
		'data1': [],
		'data2': [],
		'data3': [],
		'data4': [],
		'data5': [],
		'data6': [],
		'data7': [],
	}
	with RethinkDBConnection(RETHINK_CONFIGS) as conn:
		data = conn.get_data_last_ts(300)
		sorted_data = sorted(data, key=lambda k: k['ts'], reverse=False)
		for items in sorted_data:
			out_data_dict['labels'].append(time.strftime('%H:%M:%S', time.localtime(items['ts'])))
			out_data_dict['data0'].append(items['data']['th1'])
			out_data_dict['data1'].append(items['data']['th2'])
			out_data_dict['data2'].append(items['data']['th3'])
			out_data_dict['data3'].append(items['data']['th4'])
			out_data_dict['data4'].append(items['data']['th5'])
			out_data_dict['data5'].append(items['data']['th6'])
			out_data_dict['data6'].append(items['data']['th7'])
			out_data_dict['data7'].append(items['data']['th8'])
	return out_data_dict

def get_data_bar():
	with RethinkDBConnection(RETHINK_CONFIGS) as conn:
		return conn.get_latest_data()

def data_gather_loop():
	#implement funcitonality for getting data from sensors
	

	#dummy data loop

	sensor = Thermocouple_IF("/dev/picocafe", 9600)
	sensor.start_monitoring()
	sensor.open()
	with RethinkDBConnection(RETHINK_CONFIGS) as conn:
		conn.create_table_if_not_exists("data")
	while True:
		tempC = sensor.read_data()
		if type(tempC) == list:
			data = {
				'th1': tempC[7],
				'th2': tempC[8],
				'th3': tempC[9],
				'th8': tempC[10],
				'th4': tempC[11],
				'th5': tempC[12],
				'th6': tempC[13],
				'th7': tempC[14]
			}
			
			print(f"Temperature Data: {data}")
			with RethinkDBConnection(RETHINK_CONFIGS) as conn:
				conn.insert_data(data)
		time.sleep(1)
if __name__ == '__main__':
	print("Starting Application")
	data_thread = Thread(target=data_gather_loop)
	data_thread.start()
	app.run(host='0.0.0.0', port=5000, debug=True)
