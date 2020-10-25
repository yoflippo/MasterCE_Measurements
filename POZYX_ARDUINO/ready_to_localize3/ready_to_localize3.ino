#include <Pozyx.h>
#include <Pozyx_definitions.h>
#include <Wire.h>

uint16_t remote_id = NULL;
const uint8_t num_anchors = 4;
uint16_t anchors[num_anchors] = {0x6e49, 0x695f, 0x696c, 0x6e02};
int32_t anchors_x[num_anchors] = {1604, 539, 2054, 3182};
int32_t anchors_y[num_anchors] = {963, 4778, -1132, 1316};
int32_t heights[num_anchors] = {1900, 650, 1900, 1400};

uint8_t algorithm = POZYX_POS_ALG_UWB_ONLY;             // positioning algorithm to use. try POZYX_POS_ALG_TRACKING for fast moving objects.
uint8_t dimension = POZYX_3D;                           // positioning dimension
int32_t height = 1000;                                  // height of device, required in 2.5D positioning


void setup() {
  Serial.begin(230400);

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
  Serial.println(F("Starting positioning: "));
}

void loop() {
  coordinates_t position;
  int status = Pozyx.doPositioning(&position, dimension, height, algorithm);
  Serial.print(micros()/1000);
  Serial.print(",");

  if (status == POZYX_SUCCESS) {
    printCoordinates(position);    // prints out the result
    Serial.print("0");
  }
  else {
    printErrorCode("");    // prints out the error code
  }
  Serial.println("");
}

void printCoordinates(coordinates_t coor) {
  Serial.print(coor.x);
  Serial.print(",");
  Serial.print(coor.y);
  Serial.print(",");
  Serial.print(coor.z);
  Serial.print(",");
}

void printErrorCode(String operation) {
  uint8_t error_code;
  Pozyx.getErrorCode(&error_code);
  Serial.print("ERROR");
  Serial.print(operation);
  Serial.print(",0x");
  Serial.print(error_code, HEX);
  Serial.print(",,1");
}

void printCalibrationResult() {
  uint8_t list_size;
  int status;

  status = Pozyx.getDeviceListSize(&list_size, remote_id);
  Serial.print("list size: ");
  Serial.println(status * list_size);

  if (list_size == 0) {
    printErrorCode("configuration");
    return;
  }

  uint16_t device_ids[list_size];
  status &= Pozyx.getDeviceIds(device_ids, list_size, remote_id);

  Serial.println(F("Calibration result:"));
  Serial.print(F("Anchors found: "));
  Serial.println(list_size);

  coordinates_t anchor_coor;
  for (int i = 0; i < list_size; i++)
  {
    Serial.print("ANCHOR,");
    Serial.print("0x");
    Serial.print(device_ids[i], HEX);
    Serial.print(",");
    Pozyx.getDeviceCoordinates(device_ids[i], &anchor_coor, remote_id);
    Serial.print(anchor_coor.x);
    Serial.print(",");
    Serial.print(anchor_coor.y);
    Serial.print(",");
    Serial.println(anchor_coor.z);
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
