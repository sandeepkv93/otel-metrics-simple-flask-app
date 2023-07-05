import opentelemetry
from flask import Flask, request
from flask_sqlalchemy import SQLAlchemy
from opentelemetry.exporter.otlp.proto.grpc.metric_exporter import \
    OTLPMetricExporter
from opentelemetry.metrics import get_meter_provider, set_meter_provider
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.metrics.export import PeriodicExportingMetricReader

exporter = OTLPMetricExporter(endpoint="localhost:4317", insecure=True)
reader = PeriodicExportingMetricReader(exporter)
provider = MeterProvider(metric_readers=[reader])
set_meter_provider(provider)

meter = get_meter_provider().get_meter("sample-flask-app", "0.1.2")

get_counter = meter.create_counter("get_counter", "counts get requests")
post_counter = meter.create_counter("post_counter", "counts post requests")
put_counter = meter.create_counter("put_counter", "counts put requests")
delete_counter = meter.create_counter("delete_counter", "counts delete requests")

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:////tmp/test.db'
db = SQLAlchemy(app)

class Note(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    content = db.Column(db.String(500), unique=False, nullable=False)

with app.app_context():
    db.create_all()

@app.route('/note', methods=['POST'])
def create_note():
    post_counter.add(1)
    print('Added post_counter')
    content = request.json['content']
    note = Note(content=content)
    db.session.add(note)
    db.session.commit()
    return {'id': note.id}, 201

@app.route('/note/<id>', methods=['GET', 'PUT', 'DELETE'])
def handle_note(id):
    note = Note.query.get(id)
    if request.method == 'GET':
        get_counter.add(1)
        return {'content': note.content}, 200
    elif request.method == 'PUT':
        put_counter.add(1)
        note.content = request.json['content']
        db.session.commit()
        return {'id': note.id}, 200
    elif request.method == 'DELETE':
        delete_counter.add(1)
        db.session.delete(note)
        db.session.commit()
        return {}, 204

if __name__ == '__main__':
    app.run(debug=True)
