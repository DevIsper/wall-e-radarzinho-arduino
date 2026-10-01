#define TRIG_PIN 9
#define ECHO_PIN 10
#define SERVO_PIN 6

#include <Servo.h>

Servo myServo;

void setup() {

  myServo.attach(SERVO_PIN);
  delay(100);

  Serial.begin(9600);
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
  
}

void loop() {


  float dist = readDistance();
  if (dist > 0 && dist <= 400) {
    Serial.println(dist, 1);
  }
  delay(100);


  // myServo.write(30);

  // delay(1000);

  // myServo.write(150);

  // delay(1000);

}


float readDistance() {
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);

  long duration = pulseIn(ECHO_PIN, HIGH, 30000); // timeout 30ms (~5m)
  if (duration == 0) return -1.0;
  return duration * 0.0343 / 2.0;
}