#include <SPI.h>
#include "Adafruit_MAX31855.h"
#include "HC4067.h"

#define MAXDO   16
#define MAXCS   17
#define MAXCLK  18

HC4067 mp(6,5,3,2);
Adafruit_MAX31855 thermocouple(MAXCLK, MAXCS, MAXDO);

void setup() {
  pinMode(4,INPUT);
  digitalWrite(4,0);
  Serial.begin(9600);
  

  while (!Serial) delay(1); // wait for Serial on Leonardo/Zero, etc
  // Serial.print("Initializing sensor...");
  if (!thermocouple.begin()) {
    Serial.println("ERROR.");
    while (1) delay(10);
  }
}
int channel = 16;
double c = 0.0;
double temperature_buffer[16];
String receivedData;  // Variable to store the received sentence
const byte TERMINATION_BYTE = '\r';
void loop() {
  // basic readout test, just print the current temp
  for (channel = 0; channel < 16; channel++ )
  {
    mp.setChannel(channel+1);
    delay(150);
    c = thermocouple.readCelsius();
    if (isnan(c)) {
      //Sometime in the future use the errors in log
      // Serial.println("Thermocouple fault(s) detected!");
      // uint8_t e = thermocouple.readError();
      // if (e & MAX31855_FAULT_OPEN) Serial.println("FAULT: Thermocouple is open - no connections.");
      // if (e & MAX31855_FAULT_SHORT_GND) Serial.println("FAULT: Thermocouple is short-circuited to GND.");
      // if (e & MAX31855_FAULT_SHORT_VCC) Serial.println("FAULT: Thermocouple is short-circuited to VCC.");
      temperature_buffer[channel] = 0.0;
    } else {
      // Serial.print("C = ");
      // Serial.println(c);
      temperature_buffer[channel] = c;
    }
  }
  double * t  = temperature_buffer; 
  Serial.printf("%4.2f,%4.2f,%4.2f,%4.2f,%4.2f,%4.2f,%4.2f,%4.2f,%4.2f,%4.2f,%4.2f,%4.2f,%4.2f,%4.2f,%4.2f,%4.2f", t[0], t[1], t[2], t[3], t[4], t[5], t[6], t[7], t[8], t[9], t[10], t[11], t[12], t[13], t[14], t[15]);
  Serial.println("");
}