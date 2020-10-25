void setupleds() {
  pinMode(3, OUTPUT);
  pinMode(4, OUTPUT);
  pinMode(5, OUTPUT);
  pinMode(6, OUTPUT);
  pinMode(7, OUTPUT);
}

bool setLEDstateOn(bool blledon)
{
  digitalWrite(3, blledon);
  digitalWrite(4, blledon);
  digitalWrite(5, blledon);
  digitalWrite(6, blledon);
  digitalWrite(7, blledon);
  return blledon;
}
