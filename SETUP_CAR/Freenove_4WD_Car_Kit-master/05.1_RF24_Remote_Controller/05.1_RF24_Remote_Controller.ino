/**********************************************************************
  Filename    : RF24_Remote_Controller.ino
  Product     : Freenove 4WD Car for UNO
  Description : Code for RF24 Remote Controller.
  Auther      : www.freenove.com
  Modification: 2019/08/06
**********************************************************************/
// NRF24L01
#include <SPI.h>
#include "RF24.h"

//#include <AverageValue.h>

RF24 radio(9, 10);                // define the object to control NRF24L01
const byte addresses[6] = "Free1";// define communication address which should correspond to remote control
// wireless communication
volatile float reductionFactor = 1;
int dataWrite[8];                 // define array used to save the write data
int volatile calJoyStickValX = 0, calJoyStickValY = 0;
//AverageValue<int> averageValueJoyStickX(2);
//AverageValue<int> averageValueJoyStickY(2);

// pin
const int pot1Pin = A0,           // define POT1 Potentiometer
          pot2Pin = A1,           // define POT2 Potentiometer
          joystickXPin = A2,      // define pin for direction X of joystick
          joystickYPin = A3,      // define pin for direction Y of joystick
          joystickZPin = 7,       // define pin for direction Z of joystick
          s1Pin = 4,              // define pin for S1
          s2Pin = 3,              // define pin for S2
          s3Pin = 2,              // define pin for S3
          led1Pin = 6,            // define pin for LED1 which is close to POT1 and used to indicate the state of POT1
          led2Pin = 5,            // define pin for LED2 which is close to POT2 and used to indicate the state of POT2
          led3Pin = 8;            // define pin for LED3 which is close to NRF24L01 and used to indicate the state of NRF24L01

void setup() {
  Serial.begin(230400);
  // NRF24L01
  radio.begin();                      // initialize RF24
  radio.setPALevel(RF24_PA_MAX);      // set power amplifier (PA) level
  radio.setDataRate(RF24_1MBPS);      // set data rate through the air
  radio.setRetries(0, 15);            // set the number and delay of retries
  radio.openWritingPipe(addresses);   // open a pipe for writing
  radio.openReadingPipe(1, addresses);// open a pipe for reading
  radio.stopListening();              // stop listening for incoming messages

  // pin
  pinMode(joystickZPin, INPUT);       // set led1Pin to input mode
  pinMode(s1Pin, INPUT);              // set s1Pin to input mode
  pinMode(s2Pin, INPUT);              // set s2Pin to input mode
  pinMode(s2Pin, INPUT);              // set s3Pin to input mode
  pinMode(led1Pin, OUTPUT);           // set led1Pin to output mode
  pinMode(led2Pin, OUTPUT);           // set led2Pin to output mode
  pinMode(led3Pin, OUTPUT);           // set led3Pin to output mode

  // calibrate by assuming no user input at startup
  calibrateJoystick();
}

void loop()
{
  static uint16_t cntCalibrate = 0;

  // put the values of rocker, switch and potentiometer into the array
  dataWrite[0] = analogRead(pot1Pin); // save data of Potentiometer 1
  dataWrite[1] = analogRead(pot2Pin); // save data of Potentiometer 2

  //  averageValueJoyStickX.push(analogRead(joystickXPin));
  //  averageValueJoyStickY.push(analogRead(joystickYPin));
  //  dataWrite[2] = averageValueJoyStickX.average() - calJoyStickValX; // save data of direction X of joystick
  //  dataWrite[3] = averageValueJoyStickY.average() - calJoyStickValY; // save data of direction Y of joystick

  dataWrite[2] = analogRead(joystickXPin) - calJoyStickValX; // save data of direction X of joystick
  dataWrite[3] = analogRead(joystickYPin) - calJoyStickValY; // save data of direction Y of joystick

  Serial.println(dataWrite[2]);
  Serial.println(dataWrite[3]);
  dataWrite[4] = digitalRead(joystickZPin); // save data of direction Z of joystick
  if (!dataWrite[4]) {
    calibrateJoystick();
  }
  dataWrite[5] = true; //digitalRead(s1Pin);        // save data of switch 1
  dataWrite[6] = true; //digitalRead(s2Pin);        // save data of switch 2
  dataWrite[7] = true; //digitalRead(s3Pin);        // save data of switch 3

  if (!digitalRead(s1Pin) || !digitalRead(s2Pin) || !digitalRead(s3Pin)) {
    reductionFactor = 1;
    if (!digitalRead(s1Pin)) {
      reductionFactor *= 0.8;
    }
    if (!digitalRead(s2Pin)) {
      reductionFactor *= 0.6;
    }
    if (!digitalRead(s3Pin)) {
      reductionFactor *= 0.4;
    }
    dataWrite[2] = (int)dataWrite[2] * reductionFactor;
    dataWrite[3] = (int)dataWrite[3] * reductionFactor;
    Serial.println("Reduction factor present: ");
    Serial.println(reductionFactor);
  }

  // write radio data
  if (radio.writeFast(&dataWrite, sizeof(dataWrite)))
  {
    digitalWrite(led3Pin, HIGH);
  }
  else {
    digitalWrite(led3Pin, LOW);
  }
  delay(20);

  // make LED emit different brightness of light according to analog of potentiometer
  analogWrite(led1Pin, map(dataWrite[0], 0, 1023, 0, 255));
  analogWrite(led2Pin, map(dataWrite[1], 0, 1023, 0, 255));

  //  // after certain time of no user input recalibrate
  //  if (dataWrite[2] < 5 && dataWrite[3] < 5) {
  //    cntCalibrate++;
  //    if (cntCalibrate > 400) {
  //      calibrateJoystick();
  //      cntCalibrate = 0;
  //    }
  //  }
  //  else {
  //    cntCalibrate = 0;
  //  }
}

void calibrateJoystick() {
  Serial.println("execution of: calibrateJoystick() ");
  const int calcnt = 200;
  long calsumx = 0, calsumy = 0;
  for (unsigned int i = 0; i < calcnt; i++) {
    calsumx += analogRead(joystickXPin);
    calsumy += analogRead(joystickYPin);
  }
  calJoyStickValX = calsumx / calcnt;
  calJoyStickValY = calsumy / calcnt;
}
