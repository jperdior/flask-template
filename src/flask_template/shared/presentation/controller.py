"""Controller interface"""

from abc import ABC, abstractmethod
from flask import Request
from src.flask_template.shared.presentation.dto import ResponseDto


class ControllerInterface(ABC):
    """Controller interface"""

    @abstractmethod
    def execute(self, request: Request) -> ResponseDto:
        """Executes the controller"""
