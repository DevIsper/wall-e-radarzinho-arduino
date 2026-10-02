#define TRIG_PIN 9
#define ECHO_PIN 10
#define SERVO_PIN 6
#define BUZZER 2

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
  pinMode(BUZZER,OUTPUT);
}

void loop() {
  myServo.write(grauServo);
  delay(30);

  float dist = readDistance();

  if(dist <= 15 && dist > 10) {
    // curioso
    rasp(300, 520, 140);
    delay(70);
    rasp(380, 850, 220);
  } else if (dist <= 10 && dist > 5) {
    // animado
    rasp(380, 760, 90);
    delay(35);
    rasp(500, 880, 90);
    delay(35);
    rasp(620, 1000, 90);
  } else if (dist <= 5) {
    // "EEEVAAH!"
    rasp(500, 1000, 260);
    rasp(1000, 620, 220);
  } else noTone(BUZZER);

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

void rasp(int f1, int f2, int ms) {
  for (int t = 0; t < ms; t += 8) {
    int f = f1 + (long)(f2 - f1) * t / ms + random(-25, 26);
    tone(BUZZER, f);
    delay(8);
  }
  noTone(BUZZER);
}