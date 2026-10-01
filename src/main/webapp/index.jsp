<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>UNO Q Radar</title>
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            background: #020c02;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            font-family: 'Courier New', monospace;
            color: #00ff41;
            gap: 16px;
            padding: 16px;
        }

        h1 {
            font-size: 1rem;
            letter-spacing: 0.25em;
            text-transform: uppercase;
            color: #00cc33;
            text-shadow: 0 0 8px #00ff4166;
        }

        #radar-wrap {
            position: relative;
        }

        canvas {
            display: block;
            border: 1px solid #003a00;
            border-radius: 4px;
            box-shadow: 0 0 32px #00ff4122, inset 0 0 32px #001400;
        }

        #hud {
            display: flex;
            gap: 40px;
            font-size: 0.85rem;
            color: #00aa22;
        }

        #hud span { color: #00ff41; font-weight: bold; }

        #status {
            font-size: 0.7rem;
            color: #005500;
            letter-spacing: 0.15em;
        }
    </style>
</head>
<body>

<h1>Ultrasonic Radar &mdash; UNO Q</h1>

<div id="radar-wrap">
    <canvas id="radar" width="700" height="375"></canvas>
</div>

<div id="hud">
    <div>DIST: <span id="hud-dist">---</span> cm</div>
    <div>GRAU: <span id="hud-grau">---</span> &deg;</div>
</div>

<div id="status">AGUARDANDO SINAL...</div>

<script>
    const canvas  = document.getElementById('radar');
    const ctx     = canvas.getContext('2d');
    const W       = canvas.width;
    const H       = canvas.height;
    const OX      = W / 2;
    const OY      = H - 10;         // origem na base central
    const RADIUS  = H - 30;         // raio em pixels
    const MAX_CM  = 200;            // distância máxima exibida (cm)
    const TRAIL_MS = 4000;          // tempo de fade das detecções

    let sweepGrau = 0;
    let detections = [];            // {grau, dist, time}

    // converte (grau 0-180, distância cm) → ponto no canvas
    function toXY(grau, dist) {
        const r   = (dist / MAX_CM) * RADIUS;
        const rad = (180 - grau) * Math.PI / 180;
        return {
            x: OX + r * Math.cos(rad),
            y: OY - r * Math.sin(rad)
        };
    }

    function drawGrid() {
        // arcos de distância
        const ringsCm = [50, 100, 150, 200];
        ringsCm.forEach(cm => {
            const r = (cm / MAX_CM) * RADIUS;
            ctx.beginPath();
            ctx.arc(OX, OY, r, Math.PI, 0);
            ctx.strokeStyle = '#003a00';
            ctx.lineWidth = 1;
            ctx.stroke();

            // label
            ctx.fillStyle = '#005500';
            ctx.font = '11px Courier New';
            ctx.textAlign = 'left';
            ctx.fillText(cm + 'cm', OX + 4, OY - r + 13);
        });

        // raios angulares a cada 30°
        [0, 30, 60, 90, 120, 150, 180].forEach(g => {
            const end = toXY(g, MAX_CM);
            ctx.beginPath();
            ctx.moveTo(OX, OY);
            ctx.lineTo(end.x, end.y);
            ctx.strokeStyle = '#002800';
            ctx.lineWidth = 1;
            ctx.stroke();

            // label do ângulo
            const lbl = toXY(g, MAX_CM * 1.06);
            ctx.fillStyle = '#005a00';
            ctx.font = '11px Courier New';
            ctx.textAlign = 'center';
            ctx.fillText(g + '°', lbl.x, lbl.y);
        });

        // linha de base
        ctx.beginPath();
        ctx.moveTo(OX - RADIUS - 8, OY);
        ctx.lineTo(OX + RADIUS + 8, OY);
        ctx.strokeStyle = '#003a00';
        ctx.lineWidth = 1;
        ctx.stroke();
    }

    function drawSweep(grau) {
        const end = toXY(grau, MAX_CM);

        // glow largo
        ctx.beginPath();
        ctx.moveTo(OX, OY);
        ctx.lineTo(end.x, end.y);
        ctx.strokeStyle = 'rgba(0,255,65,0.08)';
        ctx.lineWidth = 12;
        ctx.stroke();

        // linha principal com gradiente
        const grad = ctx.createLinearGradient(OX, OY, end.x, end.y);
        grad.addColorStop(0, 'rgba(0,255,65,0.9)');
        grad.addColorStop(1, 'rgba(0,255,65,0.0)');
        ctx.beginPath();
        ctx.moveTo(OX, OY);
        ctx.lineTo(end.x, end.y);
        ctx.strokeStyle = grad;
        ctx.lineWidth = 2;
        ctx.stroke();
    }

    function drawDetections() {
        const now = Date.now();
        detections = detections.filter(d => now - d.time < TRAIL_MS);

        // rastro: pontos antigos com fade
        detections.forEach(det => {
            const age = (now - det.time) / TRAIL_MS;
            const alpha = Math.pow(1 - age, 2);
            const pos = toXY(det.grau, det.dist);

            ctx.beginPath();
            ctx.arc(pos.x, pos.y, 4, 0, Math.PI * 2);
            ctx.fillStyle = `rgba(0,255,65,${alpha * 0.5})`;
            ctx.fill();
        });

        // bolinha principal: detecção mais recente, grande e brilhante
        if (detections.length > 0) {
            const latest = detections[detections.length - 1];
            const pos = toXY(latest.grau, latest.dist);

            // halo externo
            ctx.beginPath();
            ctx.arc(pos.x, pos.y, 18, 0, Math.PI * 2);
            ctx.fillStyle = 'rgba(0,255,65,0.07)';
            ctx.fill();

            // halo médio
            ctx.beginPath();
            ctx.arc(pos.x, pos.y, 11, 0, Math.PI * 2);
            ctx.fillStyle = 'rgba(0,255,65,0.18)';
            ctx.fill();

            // bolinha sólida
            ctx.beginPath();
            ctx.arc(pos.x, pos.y, 6, 0, Math.PI * 2);
            ctx.fillStyle = '#00ff41';
            ctx.shadowColor = '#00ff41';
            ctx.shadowBlur  = 14;
            ctx.fill();
            ctx.shadowBlur  = 0;
        }
    }

    function drawOrigin() {
        ctx.beginPath();
        ctx.arc(OX, OY, 4, 0, Math.PI * 2);
        ctx.fillStyle = '#00ff41';
        ctx.shadowColor = '#00ff41';
        ctx.shadowBlur = 8;
        ctx.fill();
        ctx.shadowBlur = 0;
    }

    function draw() {
        ctx.clearRect(0, 0, W, H);

        ctx.fillStyle = '#020c02';
        ctx.fillRect(0, 0, W, H);

        drawGrid();
        drawSweep(sweepGrau);
        drawDetections();   // detecções por cima da linha de varredura
        drawOrigin();
    }

    setInterval(function () {
        fetch('/femaservlet/distancia')
            .then(function (res) { return res.json(); })
            .then(function (data) {
                sweepGrau = data.grau;

                if (data.dist > 0 && data.dist <= MAX_CM) {
                    detections.push({ grau: data.grau, dist: data.dist, time: Date.now() });
                }

                document.getElementById('hud-dist').textContent = data.dist.toFixed(1);
                document.getElementById('hud-grau').textContent = data.grau;
                document.getElementById('status').textContent   = 'SINAL ATIVO';

                draw();
            })
            .catch(function () {
                document.getElementById('status').textContent = 'ERRO DE COMUNICAÇÃO';
            });
    }, 20);
</script>

</body>
</html>
