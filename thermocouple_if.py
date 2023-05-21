
from adafruit_max31855 import MAX31855
from machine import I2C, SPI, u2if, Pin

class MAX31855K (MAX31855):
    def __init__(self, spi: SPI, cs: Pin(u2if.GP17, Pin.OUT, value=Pin.HIGH)) -> None:
        spi.init(baudrate=10000000)
        super().__init__(spi, cs)
        print("Initializde thermocouple sensor")
