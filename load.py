from psutil import getloadavg
from flask import Flask, jsonify

app = Flask(__name__)

@app.route("/load", methods=['GET'])

def get_load():
	one, five, fifteen = getloadavg()
	print('{0}, {1}, {2}'.format(one, five, fifteen))
	return jsonify(oneMin=one, fiveMin=five, fifteenMin=fifteen)

if __name__ == '__main__':
	app.run(debug=True)
