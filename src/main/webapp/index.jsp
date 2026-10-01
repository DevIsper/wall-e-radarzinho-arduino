<!DOCTYPE html>
<html>
<head>
    <title>UNO Q Radar</title>
</head>
<body>

<h2>UNO Q Ultrasonic Radar</h2>

<h1 id="distancia">--</h1>

<script>
    setInterval(function () {
        fetch('/femaservlet/distancia')
            .then(function (res) { return res.text(); })
            .then(function (val) {
                document.getElementById('distancia').textContent = val + ' cm';
            });
    }, 20);
</script>

</body>
</html>