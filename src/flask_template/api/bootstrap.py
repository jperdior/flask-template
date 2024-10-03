"""Bootstrap file file for the API"""
import os

from flask import Flask
from flasgger import Swagger
from flask_migrate import Migrate
from celery import Celery, Task
from src.flask_template.api.routes.status import status_bp
from src.flask_template.shared.infrastructure.persistence.postgresql import DB, SQLALCHEMY_DATABASE_URI

from src.flask_template.shared.infrastructure.bus.inmemory.query import QueryBusImpl
from src.flask_template.shared.infrastructure.bus.rabittmq.command import CommandBusImpl

CELERY_BROKER_URL = os.getenv("CELERY_BROKER_URL")
if not CELERY_BROKER_URL:
    raise ValueError("CELERY_BROKER_URL is not set")


def celery_init_command(app: Flask) -> Celery:
    """Initialize the Celery app"""

    class FlaskTask(Task):
        def __call__(self, *args: object, **kwargs: object) -> object:
            with app.app_context():
                return self.run(*args, **kwargs)

    celery_app = Celery("command_bus", task_cls=FlaskTask)
    celery_app.config_from_object(app.config["CELERY"])
    celery_app.set_default()
    app.extensions["CELERY"] = celery_app
    return celery_app


def create_app():
    """Run the API"""
    app = Flask(__name__)

    app.config["SQLALCHEMY_DATABASE_URI"] = SQLALCHEMY_DATABASE_URI
    DB.init_app(app)
    Migrate(app, DB)

    app.config["CELERY"] = {"broker_url": CELERY_BROKER_URL, "task_ignore_result": True}
    app.config.from_prefixed_env()
    command_celery_app = celery_init_command(app)

    query_bus = QueryBusImpl()
    command_bus = CommandBusImpl(celery_app=command_celery_app)


    Swagger(app)

    app.register_blueprint(status_bp)

    return app
