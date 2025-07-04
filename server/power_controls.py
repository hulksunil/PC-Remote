import subprocess


class PowerControls:
    @staticmethod
    def sleep():
        try:
            subprocess.run(
                "rundll32.exe powrprof.dll,SetSuspendState 0,1,0", shell=True, check=True)
            print("Sleep command executed.")
        except subprocess.CalledProcessError as e:
            print(f"Failed to put PC to sleep: {e}")

    @staticmethod
    def shutdown():
        """Shutdown the PC."""
        # TODO(sunil): Test later when prepared
        return
        try:
            subprocess.run("shutdown /s /t 0", shell=True, check=True)
            print("Shutdown command executed.")
        except subprocess.CalledProcessError as e:
            print(f"Failed to shutdown PC: {e}")

    @staticmethod
    def lock():
        try:
            subprocess.run(
                "rundll32.exe user32.dll,LockWorkStation", shell=True, check=True)
            print("Lock command executed.")
        except subprocess.CalledProcessError as e:
            print(f"Failed to lock PC: {e}")
