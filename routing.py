from flask import Flask
from flask_pymongo import PyMongo
from flask import request
app = Flask(__name__)
app.config["MONGO_URI"] = "mongodb://localhost:27017/usersdb"
mongo = PyMongo(app)

@app.route('/register', methods = ['POST'])
def register():
   return 'Hello World'
@app.route('/')
def hello():
    for x in mongo.db.users.find({"name": "Nilay"}):
        return str(x)