from flask import Flask
app = Flask(__name__)

@app.route('/test')
def test():
    return {'status': 'ok', 'message': 'Test API is working!'}

if __name__ == '__main__':
    app.run(port=5001, debug=True)
