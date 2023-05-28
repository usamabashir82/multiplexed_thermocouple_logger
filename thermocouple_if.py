import serial
import pyudev


class Thermocouple_IF:
    def __init__(self, device_name, baudrate=9600):
        self.device_name = device_name
        self.baudrate = baudrate
        self.serial = None
        self.context = pyudev.Context()
        self.monitor = None

    def open(self):
        self.serial = serial.Serial(self.device_name, self.baudrate)

    def close(self):
        if self.serial:
            self.serial.close()
            self.serial = None

    def start_monitoring(self):
        self.monitor = pyudev.Monitor.from_netlink(self.context)
        self.monitor.filter_by(subsystem='tty')
        self.monitor.start()

    def stop_monitoring(self):
        if self.monitor:
            self.monitor.stop()
            self.monitor = None

    def monitor_events(self):
        for device in iter(self.monitor.poll, None):
            print(device)
            if device.action == 'add' and 'ID_MODEL' in device.attributes and device.attributes['ID_MODEL'] == 'Pico':
                if device.device_node.endswith(self.device_name):
                    if self.serial:
                        self.close()
                    self.open()
    def read_data(self):
        try:
            if self.serial:
                serial_data = []
                read_line = self.serial.read_until(expected=b'\r').decode().strip()
                print(read_line)
                values = read_line.split(',')  # Split the line into individual values
                for value in values:
                    serial_data.append(float(value))  # Convert each value to float and append to the list
            
                return serial_data
            return None
        except:
            pass
