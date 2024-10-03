"""Entry point for the application."""
from src.flask_template.api.bootstrap import create_app
app = create_app()

if __name__ == "__main__":
    app.run()
    