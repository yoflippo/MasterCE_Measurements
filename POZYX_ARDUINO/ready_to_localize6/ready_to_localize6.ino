#include <Pozyx.h>
#include <Pozyx_definitions.h>
#include <Wire.h>

bool blMEASURE = false;
uint16_t remote_id = 0x6965; //0x691b;
const uint8_t num_anchors = 4;
uint16_t anchors[num_anchors] = {0x696c, 0x6e49, 0x6e02, 0x695f };
int32_t anchors_x[num_anchors] = {-2313,2086,2511,-3069};
int32_t anchors_y[num_anchors] = {6930,5815,-3279,-4343};
int32_t heights[num_anchors] = {1908,585,1881,411};

uint8_t algorithm = POZYX_POS_ALG_UWB_ONLY;             // positioning algorithm to use. try POZYX_POS_ALG_TRACKING for fast moving objects.
uint8_t dimension = POZYX_3D;                           // positioning dimension
int32_t height = 1000;                                  // height of device, required in 2.5D positioning


void setup() {
  Serial.begin(230400);
  setupleds();
  if (Pozyx.begin() == POZYX_FAILURE) {
    Serial.println(F("ERROR: Unable to connect to POZYX shield"));
    Serial.println(F("Reset required"));
    delay(100);
    abort();
  }

  Pozyx.clearDevices(remote_id);  // clear all previous devices in the device list
  setAnchorsManual();  // sets the anchor manually
  Pozyx.setPositionAlgorithm(algorithm, dimension, remote_id);  // sets the positioning algorithm
  printCalibrationResult();
  delay(2000);
  Serial.println("Start/Stop: by Entering 'S' ");
}

void loop() {
  static bool ledstate = false;
  serialEvent();
  if (blMEASURE) {
    if (blMEASURE != ledstate) {
      ledstate = setLEDstateOn(true);
      resetMicros();
    }
    coordinates_t position;
    int status = Pozyx.doRemotePositioning(remote_id, &position, dimension, height, algorithm);
    Serial.print(getMicros() / 1000);
    Serial.print(",");

    if (status == POZYX_SUCCESS) {
      printCoordinates(position);    // prints out the result
    }
    else {
      printErrorCode("");    // prints out the error code
    }
    Serial.println("");
  }
  else {
    ledstate = setLEDstateOn(false);
  }
}


void setAnchorsManual() {
  for (int i = 0; i < num_anchors; i++) {
    device_coordinates_t anchor;
    anchor.network_id = anchors[i];
    anchor.flag = 0x1;
    anchor.pos.x = anchors_x[i];
    anchor.pos.y = anchors_y[i];
    anchor.pos.z = heights[i];
    Pozyx.addDevice(anchor, remote_id);
  }
  if (num_anchors > 4) {
    Pozyx.setSelectionOfAnchors(POZYX_ANCHOR_SEL_AUTO, num_anchors, remote_id);
  }
}
