const canvas = document.getElementById("radar");
const ctx = canvas.getContext("2d");

let distance = -1;

const maxDistance = 100;
const radius = canvas.width / 2;
const beamAngle = -Math.PI / 2; // feixe fixo apontando para cima

async function pollDistance() {
  try {
    const result = await webui.call("getDistance");
    distance = parseFloat(result);
  } catch (_) {}
  setTimeout(pollDistance, 100);
}
pollDistance();

function drawRadarGrid() {
  ctx.strokeStyle = "rgba(0,255,0,.3)";
  ctx.fillStyle = "rgba(0,255,0,.5)";
  ctx.lineWidth = 1;
  ctx.font = "12px monospace";

  for (let r = 100; r <= radius; r += 100) {
    ctx.beginPath();
    ctx.arc(0, 0, r, 0, Math.PI * 2);
    ctx.stroke();
    ctx.fillText(Math.round(r / radius * maxDistance) + " cm", 4, -r + 14);
  }

  for (let i = 0; i < 360; i += 45) {
    let x = Math.cos(i * Math.PI / 180) * radius;
    let y = Math.sin(i * Math.PI / 180) * radius;
    ctx.beginPath();
    ctx.moveTo(0, 0);
    ctx.lineTo(x, y);
    ctx.stroke();
  }
}

function draw() {
  ctx.fillStyle = "rgba(0,0,0,.25)";
  ctx.fillRect(0, 0, canvas.width, canvas.height);

  ctx.save();
  ctx.translate(radius, radius);

  drawRadarGrid();

  // Feixe fixo
  ctx.strokeStyle = "#00ff00";
  ctx.lineWidth = 2;
  ctx.beginPath();
  ctx.moveTo(0, 0);
  ctx.lineTo(Math.cos(beamAngle) * radius, Math.sin(beamAngle) * radius);
  ctx.stroke();

  // Objeto detectado
  if (distance > 0) {
    let d = Math.min(distance, maxDistance) / maxDistance * radius;
    let x = Math.cos(beamAngle) * d;
    let y = Math.sin(beamAngle) * d;

    ctx.fillStyle = "rgba(0,255,0,.9)";
    ctx.beginPath();
    ctx.arc(x, y, 8, 0, Math.PI * 2);
    ctx.fill();
  }

  ctx.restore();

  document.getElementById("dist").innerHTML =
    distance > 0 ? `Distance: ${distance.toFixed(1)} cm` : "No object";

  requestAnimationFrame(draw);
}

draw();