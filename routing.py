from flask import Flask
from flask_pymongo import PyMongo
from flask import request
from bson.objectid import ObjectId
from flask import jsonify
from user import User

app = Flask(__name__)
app.config["MONGO_URI"] = "mongodb://localhost:27017/usersdb"
mongo = PyMongo(app)

@app.route('/register', methods = ['POST'])
def register():
        json_data = request.get_json(force=True) 
        id = mongo.db.users.insert(json_data)
        print(str(id))
        return str(id)
        
@app.route('/')
def index():
        return "index"

@app.route('/users/<user_id>', methods = ['POST', 'GET', 'DELETE'])
def getUser(user_id):
        if request.method == 'GET':
                for x in mongo.db.users.find({"_id": ObjectId(user_id)}):
                        user = User(x.get("name"), x.get("email"), x.get("phone_number"), user_id)
                        return jsonify(user.serialize())
        if request.method == 'DELETE':
                mongo.db.users.delete_one({"_id": ObjectId(user_id)})
                return "all good"
        if request.method == 'POST':
                json_data = request.get_json(force=True)
                json_data["_id"] = ObjectId(user_id)
                mongo.db.users.replace_one({"_id": ObjectId(user_id)}, json_data)
                return "all good"