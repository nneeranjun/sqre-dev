from flask import Flask
from flask_pymongo import PyMongo
from flask import request
app = Flask(__name__)

@app.route('/register', methods = ['POST'])
def register():
   return 'Hello World'
@app.route('/')
def hello():
    return 'Hello'