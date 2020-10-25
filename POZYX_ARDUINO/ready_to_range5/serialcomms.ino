bool blStringComplete = false;
String inputString = "";

void serialEvent()
{
  while (Serial.available())
  {
    char inChar = (char)Serial.read();
    inputString += inChar;
    if (inChar == '\n')
    {
      blStringComplete = true;
      processString();
      break;
    }
  }
}

void processString()
{
  if (blStringComplete)
  {
    while (inputString.length() > 0)
    {
      char St = inputString.charAt(0);
      if (isAlpha(St))
      {
        inputString.remove(0, 1);
      }
      float val = inputString.toFloat();

      switch (St)
      {
        case 's':
        case 'S': //start/stop execution
          blMEASURE = !blMEASURE;
          break;
        default:
          break;
      }

      // Remove spaces, for processing of next parameter
      St = inputString.charAt(0);
      while ((St != ' ') && (inputString.length() > 0))
      {
        inputString.remove(0, 1);
        St = inputString.charAt(0);
      }
      inputString.remove(0, 1);
    }
    inputString = "";
    blStringComplete = false;
  }
}
