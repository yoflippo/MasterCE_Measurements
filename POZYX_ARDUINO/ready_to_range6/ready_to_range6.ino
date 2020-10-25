/**
  The Pozyx ready to range tutorial (c) Pozyx Labs
  Please read the tutorial that accompanies this sketch: https://www.pozyx.io/Documentation/Tutorials/ready_to_range/Arduino

  This demo requires two Pozyx devices and one Arduino. It demonstrates the ranging capabilities and the functionality to
  to remotely control a Pozyx device. Place one of the Pozyx shields on the Arduino and upload this sketch. Move around
  with the other Pozyx device.

  This demo measures the range between the two devices. The closer the devices are to each other, the more LEDs will
  light up on both devices.
*/

#include <Pozyx.h>
#include <Pozyx_definitions.h>
#include <Wire.h>

bool blMEASURE = false;
uint16_t anchors[] = {0x6e49, 0x695f, 0x696c, 0x6e02};
volatile uint8_t numElementAnchors = (sizeof(anchors) / sizeof(anchors[0]));
signed int range_step_mm = 1000; // every 1000mm in range, one LED less will be giving light.
uint8_t ranging_protocol = POZYX_RANGE_PROTOCOL_FAST; // ranging protocol of the Pozyx.
uint16_t local_id = NULL, remote_tags[] = {0x6965}; //{0x6965, 0x6918, 0x690e}; // the network ID of the remote device
uint8_t numElementTags = (sizeof(remote_tags) / sizeof(remote_tags[0]));


void setup() {
  Serial.begin(230400);

  if (Pozyx.begin() == POZYX_FAILURE) {
    Serial.println("ERROR: Unable to connect to POZYX shield");
    Serial.println("Reset required");
    delay(100);
    abort();
  }
  setupleds();
  // make sure the pozyx system has no control over the LEDs, we're the boss
  uint8_t led_config = 0x0;
  Pozyx.setLedConfig(led_config, local_id);
  for (uint8_t i = 0; i < numElementAnchors; i++) {
    Pozyx.setLedConfig(led_config, anchors[i]);
    Pozyx.setLed(1, true, anchors[i]);
    Pozyx.setLed(2, true, anchors[i]);
    Pozyx.setLed(3, true, anchors[i]);
    Pozyx.setLed(4, true, anchors[i]);
  }
  for (uint8_t i = 0; i < numElementTags; i++) {
    Pozyx.setRangingProtocol(ranging_protocol, remote_tags[i]);   // set the ranging protocol
  }
  Serial.println("Start/Stop RANGING 6: by Entering 'S' ");
}

void loop() {
  static uint8_t cnt = 0;
  static bool ledstate = false;
  serialEvent();
  if (blMEASURE) {
    if (blMEASURE != ledstate) {
      ledstate = setLEDstateOn(true);
      resetMicros();
    }
    rangeAndSerialPrint(anchors[cnt++ % numElementAnchors]);
  }
  else {
    ledstate = setLEDstateOn(false);
  }
}



void rangeAndSerialPrint(uint16_t destination_id) {
  device_range_t range;
  for (uint8_t i = 0; i < numElementTags; i++) {
    int status = Pozyx.doRemoteRanging(remote_tags[i], destination_id, &range);
    Serial.print(i);
    Serial.print(",");
    Serial.print(destination_id, HEX);
    Serial.print(",");
    Serial.print(getMicros() / 1000);
    Serial.print(",");
    Serial.print(range.timestamp);
    Serial.print(",");
    Serial.print(range.RSS);
    Serial.print(",");

    if (status == POZYX_SUCCESS) {
      Serial.print(range.distance);
      Serial.print(",");
      Serial.print("0");
      //    if (ledControl(range.distance, destination) == POZYX_FAILURE) {
      //      Serial.println("ERROR: setting (remote) leds");
      //    }
    }
    else {
      Serial.print("ERR");
      Serial.print(",1");
    }
    Serial.println("");
  }
}


int ledControl(uint32_t range, uint16_t des_id) {
  int status = POZYX_SUCCESS;
  // set the LEDs of the pozyx device
  status &= Pozyx.setLed(4, (range < range_step_mm), local_id);
  status &= Pozyx.setLed(3, (range < 2 * range_step_mm), local_id);
  status &= Pozyx.setLed(2, (range < 3 * range_step_mm), local_id);
  status &= Pozyx.setLed(1, (range < 4 * range_step_mm), local_id);

  // set the LEDs of the destination pozyx device
  status &= Pozyx.setLed(4, (range < range_step_mm), des_id);
  status &= Pozyx.setLed(3, (range < 2 * range_step_mm), des_id);
  status &= Pozyx.setLed(2, (range < 3 * range_step_mm), des_id);
  status &= Pozyx.setLed(1, (range < 4 * range_step_mm), des_id);

  // status will be zero if setting the LEDs failed somewhere along the way
  return status;
}
