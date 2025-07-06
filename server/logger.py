# logger.py
import logging
from logging.handlers import RotatingFileHandler
import os
import sys


class ServerLogger:
    def __init__(self, name="pc_remote_server", log_dir="logs", log_file="server.log"):
        os.makedirs(log_dir, exist_ok=True)
        self.logger = logging.getLogger(name)
        self.logger.setLevel(logging.DEBUG)

        log_path = os.path.join(log_dir, log_file)
        file_handler = RotatingFileHandler(
            log_path, maxBytes=1_000_000, backupCount=5)
        formatter = logging.Formatter(
            '%(asctime)s [%(levelname)s] %(message)s')
        file_handler.setFormatter(formatter)

        # Console handler (optional)
        console_handler = logging.StreamHandler()
        console_handler.setFormatter(formatter)

        self.logger.addHandler(file_handler)
        self.logger.addHandler(console_handler)

        # Optional: catch unhandled exceptions
        sys.excepthook = self._handle_uncaught_exception

    def _handle_uncaught_exception(self, exc_type, exc_value, exc_traceback):
        if issubclass(exc_type, KeyboardInterrupt):
            sys.__excepthook__(exc_type, exc_value, exc_traceback)
        else:
            self.logger.error("Uncaught exception", exc_info=(
                exc_type, exc_value, exc_traceback))


# Export the logger instance
logger = ServerLogger().logger
