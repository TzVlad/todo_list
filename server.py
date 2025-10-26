from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

todos = []
next_id = 1

@app.route('/todos', methods=['GET'])
def get_todos():
    return jsonify(todos)

@app.route('/todos', methods=['POST'])
def create_todo():
    global next_id
    todo = {'id': next_id, 'title': request.json['title'], 'completed': False}
    todos.append(todo)
    next_id += 1
    return jsonify(todo)

@app.route('/todos/<int:id>', methods=['PUT'])
def update_todo(id):
    for todo in todos:
        if todo['id'] == id:
            todo['completed'] = request.json['completed']
            return jsonify(todo)
    return jsonify({'error': 'Not found'}), 404

@app.route('/todos/<int:id>', methods=['DELETE'])
def delete_todo(id):
    global todos
    todos = [t for t in todos if t['id'] != id]
    return jsonify({'deleted': id})

if __name__ == '__main__':
    app.run(debug=True, port=5000)