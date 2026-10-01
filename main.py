import os
import time
import threading
import webbrowser
from http.server import HTTPServer, SimpleHTTPRequestHandler

import serial
import serial.tools.list_ports

# ---------------- Configuração ----------------
SERIAL_PORT = None      # ex: "COM3" ou "/dev/ttyACM0". None = autodetectar
BAUD_RATE = 115200
HTTP_PORT = 8765
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
# ----------------------------------------------

latest_distance = -1.0
lock = threading.Lock()


def find_arduino_port():
    for p in serial.tools.list_ports.comports():
        desc = f"{p.description} {p.manufacturer}".lower()
        if "arduino" in desc or "usb serial" in desc or "ch340" in desc:
            return p.device
    ports = list(serial.tools.list_ports.comports())
    return ports[0].device if ports else None


class Handler(SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/events":
            self.send_response(200)
            self.send_header("Content-Type", "text/event-stream")
            self.send_header("Cache-Control", "no-cache")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            try:
                while True:
                    with lock:
                        d = latest_distance
                    self.wfile.write(f"data: {d}\n\n".encode())
                    self.wfile.flush()
                    time.sleep(0.1)
            except (BrokenPipeError, ConnectionResetError):
                pass
        else:
            super().do_GET()

    def log_message(self, *args):
        pass  # silencia logs HTTP


def radar_loop():
    global latest_distance
    while True:
        port = SERIAL_PORT or find_arduino_port()
        if not port:
            print("Nenhuma porta serial encontrada, tentando de novo...")
            time.sleep(2)
            continue

        try:
            with serial.Serial(port, BAUD_RATE, timeout=1) as ser:
                print(f"Conectado em {port}")
                time.sleep(2)
                ser.reset_input_buffer()
                while True:
                    line = ser.readline().decode("utf-8", errors="ignore").strip()
                    if not line:
                        continue
                    try:
                        val = float(line)
                        with lock:
                            latest_distance = val
                        print(f"Distância: {val} cm")
                    except ValueError:
                        pass
        except serial.SerialException as e:
            print(f"Erro serial: {e}. Reconectando...")
            time.sleep(2)


os.chdir(BASE_DIR)

threading.Thread(target=radar_loop, daemon=True).start()

server = HTTPServer(("localhost", HTTP_PORT), Handler)
threading.Timer(1.0, lambda: webbrowser.open(f"http://localhost:{HTTP_PORT}")).start()
print(f"Servidor rodando em http://localhost:{HTTP_PORT}")
server.serve_forever()
