void setup() {
  // initialize the serial communication:
  Serial.begin(9600);
}

void loop() {
  // send the value of analog input 0:
//  Serial.println(analogRead(A0));
  // wait a bit for the analog-to-digital converter
  // to stabilize after the last reading:
  int input = analogRead(A0);

  if(input < 980) {
    Serial.println(1024);
  }
  else {
    Serial.println(0);
  }
  delay(2);
}
