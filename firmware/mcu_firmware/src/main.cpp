#include <Arduino.h>
#include <Servo.h>

// Define hardware pins for the Tamiya chassis actuators
const int THROTTLE_PIN = 9; // Connects to the ESC signal wire
const int STEERING_PIN = 10; // Connects to the Steering Servo signal wire

Servo escServo;
Servo steeringServo;

// String buffer to accumulate incoming serial bytes
String inputString = "";
bool stringComplete = false;

// Safety timeout tracking variables
unsigned long lastPacketTime = 0;
const unsigned long SAFETY_TIMEOUT_MS = 500; // Stop the rover if no packe is received for 0.5 seconds

void setup() 
{
  // Initialize USB serial communications at 115200 baud matching Jetson Nano
  Serial.begin(115200);
  inputString.reserve(50); // Allocate memory for the incoming string
  
  // Attach servo objects to their respective microcontroller pins
  escServo.attach(THROTTLE_PIN);
  steeringServo.attach(STEERING_PIN);

  // Initialize both to neutral on boot
  escServo.writeMicroseconds(1500);
  steeringServo.writeMicroseconds(1500);
}

void loop() 
{
  // Non-Blocking Serial Ingestion 
  while (Serial.available() > 0) 
  {
    char inChar = (char)Serial.read();

    if (inChar == '\n')
    {
      stringComplete = true; // Flag that a full packet arrived
      break;
    }
    else if (inChar != '\r')
    {
      inputString += inChar; // Accumulate characters in the buffer
    }
  }

  // Process Packed When Complete
  if (stringComplete)
  {
    // Find the position of the comma separator
    int commaIndex = inputString.indexOf(',');

    if (commaIndex > 0)
    {
      // Extract throttle and steering substrings and convert to integers
      String throttleStr = inputString.substring(0, commaIndex);
      String steeringStr = inputString.substring(commaIndex + 1);

      int throttleVal = throttleStr.toInt();
      int steeringVal = steeringStr.toInt();

      // Enforce safety limits
      throttleVal = constrain(throttleVal, 1000, 2000);
      steeringVal = constrain(steeringVal, 1000, 2000);

      // Write values out to the hardware
      escServo.writeMicroseconds(throttleVal);
      steeringServo.writeMicroseconds(steeringVal);

      // Reset safety timer 
      lastPacketTime = millis();
    }

    // Reset string buffeer for the next loop
    inputString = "";
    stringComplete = false;

  }

  // Safety Timout Check
    if (millis() - lastPacketTime > SAFETY_TIMEOUT_MS) 
    {
      escServo.writeMicroseconds(1500);
      steeringServo.writeMicroseconds(1500);
    }
}
