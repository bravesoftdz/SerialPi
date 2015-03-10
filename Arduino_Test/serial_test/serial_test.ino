// Serial_Test
//
// generate serial sample data based on a potentiometer
//
// the circuit includes an LED for visual feedback of the pot setting,
// and a digital push-button. When the button is pressed, the current
// reading is sent to the serial port. There is some logic here
// to ensure only one 'reading' is sent per instance that the button
// is pressed.
//
// v0.1, 10/3/15


#include <stdio.h>

const int analogInPin = A0;  // Analog input pin that the potentiometer is attached to
const int analogOutPin = 9; // Analog output pin that the LED is attached to
const int digitalButtonPin = 2; // Digital input pin that the switch is connected to

int sensorValue = 0;
int outputValue1 = 0;
int outputValue2 = 0;
int buttonState = 0;
int lastState = 0;
char strBuffer[20]="";


void setup() {
  // initialize serial

  // while devving on the Mac
  //Serial.begin(2400,SERIAL_8N1); 

  // for go-live, needs to be 2400 7E1 to match balances
  Serial.begin(2400,SERIAL_7E1);
  
  pinMode(digitalButtonPin, INPUT);
}

void loop() {
  
  // read the analog in value:
  sensorValue = analogRead(analogInPin);            
  // map it to the range of the analog out:
  outputValue1 = map(sensorValue, 0, 1023, 0, 255);
  // and also fake a 2-digit version for the decimal portion
  outputValue2 = map(sensorValue, 0, 1023, 0, 99);
  
  buttonState = digitalRead(digitalButtonPin);
  
  // change the analog out value:
  analogWrite(analogOutPin, outputValue1);           

  // only do this if a button is pressed
  if ((buttonState == HIGH) && (lastState != HIGH)) 
  {
    // format the 2 fake reading parts into a balance-esque string
    sprintf(strBuffer,"ST,+ %.5d.%.2d  g", outputValue1, outputValue2); 
    Serial.print(strBuffer);                       
    Serial.print(char(10));
  }
  // remember this state of the button
  lastState = buttonState;
  
  // wait 10 milliseconds before the next loop
  // for the analog-to-digital converter to settle
  // after the last reading:
  delay(10);                     
}
