from flask import Flask, request, json,Response,jsonify
from flask_restful import Resource, Api
import random2 as random

app = Flask(__name__)
api = Api(app)

class service1(Resource): 
    def get(self):
        value = random.randint(1,500)
        return_data = []
        if value >= 1 and value <= 200:
            response = 200
        elif value > 200 and value <= 500:
            response = 500
        return_data = response
        return Response(json.dumps({"results": return_data},indent=4),response)
    
api.add_resource(service1, '/service1/response') # Route 1

if __name__ == '__main__':
     app.run(port='5000')
