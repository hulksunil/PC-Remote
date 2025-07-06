import subprocess
from logger import logger


class PowerControls:
    @staticmethod
    def sleep():
        try:
            subprocess.run(
                "rundll32.exe powrprof.dll,SetSuspendState 0,1,0", shell=True, check=True)
            logger.info("Sleep command executed.")
        except subprocess.CalledProcessError as e:
            logger.error(f"Failed to put PC to sleep: {e}")

    @staticmethod
    def shutdown():
        """Shutdown the PC."""
        # TODO(sunil): Test later when prepared
        return
        try:
            subprocess.run("shutdown /s /t 0", shell=True, check=True)
            logger.info("Shutdown command executed.")
        except subprocess.CalledProcessError as e:
            logger.error(f"Failed to shutdown PC: {e}")

    @staticmethod
    def lock():
        try:
            subprocess.run(
                "rundll32.exe user32.dll,LockWorkStation", shell=True, check=True)
            logger.info("Lock command executed.")
        except subprocess.CalledProcessError as e:
            logger.error(f"Failed to lock PC: {e}")
