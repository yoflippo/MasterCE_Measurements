volatile  unsigned long timerMicros129347192347 = 0;
unsigned long getMicros() {
  return micros() - timerMicros129347192347;
}

void resetMicros() {
  timerMicros129347192347 = micros();
}
