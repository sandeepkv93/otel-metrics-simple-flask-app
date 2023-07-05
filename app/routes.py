from flask import Blueprint, request
from opentelemetry.metrics import get_meter_provider

from . import db
from .models import Note

bp = Blueprint('routes', __name__)

meter = get_meter_provider().get_meter("otel-metrics-simple-flask-app")

get_counter = meter.create_counter("get_counter", "counts get requests")
post_counter = meter.create_counter("post_counter", "counts post requests")
put_counter = meter.create_counter("put_counter", "counts put requests")
delete_counter = meter.create_counter("delete_counter", "counts delete requests")

@bp.route('/note', methods=['POST'])
def create_note():
    post_counter.add(1)
    content = request.json['content']
    note = Note(content=content)
    db.session.add(note)
    db.session.commit()
    return {'id': note.id}, 201

@bp.route('/note/<id>', methods=['GET', 'PUT', 'DELETE'])
def handle_note(id):
    note = Note.query.get(id)
    if request.method == 'GET':
        get_counter.add(1)
        if note is None:
            return {'id': id}, 404
        return {'content': note.content}, 200
    elif request.method == 'PUT':
        put_counter.add(1)
        if note is None:
            return {'id': id}, 404
        note.content = request.json['content']
        db.session.commit()
        return {'id': note.id}, 200
    elif request.method == 'DELETE':
        delete_counter.add(1)
        if note is None:
            return {'id': id}, 404
        db.session.delete(note)
        db.session.commit()
        return {}, 204