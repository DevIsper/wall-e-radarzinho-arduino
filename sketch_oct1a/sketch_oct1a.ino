#define TRIG_PIN 9
#define ECHO_PIN 10
#define SERVO_PIN 6

#include <Servo.h>

Servo myServo;

int grauServo = 0;
int direcao = 1; // 1 = crescente, -1 = decrescente

void setup() {
  myServo.attach(SERVO_PIN);
  delay(100);
  Serial.begin(9600);
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
}

void loop() {
  myServo.write(grauServo);
  delay(30);

  float dist = readDistance();

  if (dist > 0 && dist <= 400) {
    Serial.print(grauServo);
    Serial.print(",");
    Serial.println(dist, 1);
  }

  grauServo += direcao;
  if (grauServo >= 180) direcao = -1;
  if (grauServo <= 0)   direcao =  1;

  delay(20);
}

float readDistance() {
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);

  long duration = pulseIn(ECHO_PIN, HIGH, 30000);
  if (duration == 0) return -1.0;
  return duration * 0.0343 / 2.0;
}