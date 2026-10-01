// HC-SR04 — Trig: pino 9, Echo: pino 10
// Envia distância em cm pela serial a cada ~100ms

#define TRIG_PIN 9
#define ECHO_PIN 10

void setup() {
  Serial.begin(115200);
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
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

void loop() {
  float dist = readDistance();
  if (dist > 0 && dist <= 400) {
    Serial.println(dist, 1);
  }
  delay(100);
}
