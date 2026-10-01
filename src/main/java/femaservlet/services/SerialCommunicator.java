package femaservlet.services;
import com.fazecast.jSerialComm.SerialPort;
import com.fazecast.jSerialComm.SerialPortTimeoutException;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;

// SerialUtils, SerialHelper
public class SerialCommunicator {
	
	private static SerialCommunicator serialCommunicator;
	
	private SerialCommunicator() {}
	
	public static SerialCommunicator getInstance() {
		if (serialCommunicator != null) {
			return serialCommunicator;
		}
		else serialCommunicator = new SerialCommunicator();
		
		return serialCommunicator;
	}
	
	private SerialPort serialPort;
	private BufferedReader reader;
	private boolean isConnected = false;
	private float lastDistancia = 0.0f;
	private int lastGrau = 0;

	// lê uma linha "grau,distancia" e atualiza os campos internos
	public void lerLeitura() {
		if (!isConnected || serialPort == null) return;
		try {
			String line = reader.readLine();
			if (line == null || line.isBlank()) return;
			String[] parts = line.trim().split(",");
			if (parts.length == 2) {
				lastGrau      = Integer.parseInt(parts[0].trim());
				lastDistancia = Float.parseFloat(parts[1].trim());
			}
		} catch (SerialPortTimeoutException e) {
			// sem dado novo — mantém último valor
		} catch (IOException | NumberFormatException e) {
			System.err.println("Erro na leitura serial: " + e.getMessage());
		}
	}

	public float getLastDistancia() { return lastDistancia; }
	public int   getLastGrau()      { return lastGrau; }
	
	// "COM3", 9600
	public boolean connect(String portName, int baudRate) {
		try {
			serialPort = SerialPort.getCommPort(portName);
			serialPort.setBaudRate(baudRate);
			// 8N1
			serialPort.setNumDataBits(8);
			serialPort.setParity(SerialPort.NO_PARITY);
			serialPort.setNumStopBits(1);
			
			if (serialPort.openPort()) {
				// semi-blocking: retorna quando tem pelo menos 1 byte, ou após 500ms
				serialPort.setComPortTimeouts(SerialPort.TIMEOUT_READ_SEMI_BLOCKING, 500, 0);
				reader = new BufferedReader(
						new InputStreamReader(
								serialPort.getInputStream(), StandardCharsets.UTF_8
						)
				);
				isConnected = true;
				// cout
				System.out.println("Conectado à porta: " + portName);
				
				return true;
			}
		} catch (Exception e) {
			System.err.println("Erro ao conectar: " + e.getMessage());
		}
		
		return false;
	}
	
	public void disconnect() {
		isConnected = false;
		if (serialPort != null) {
			serialPort.closePort();
		}
		System.out.println("Desconectado do Arduino");
	}
	
	public boolean isConnected() {
		return isConnected;
	}
	
//	/**
//	 * Método responsável por decodificar a String de dados e enviá-la para o Arduino.
//	 *
//	 * a. na classe SerialCommunicator, implementar método "public void sendData(String data) {" que, fazendo uso de um objeto
//	 * "OutputStream outputStream = serialPort.getOutputStream()", envie dados do Java para Arduino, com métodos "write" e "flush";
//	 * @param data data A string de dados a ser enviada (ex: um comando).
//	 */
//	public void sendData(String data) {
//		try {
//			OutputStream outputStream = serialPort.getOutputStream();
//			outputStream.write(data.getBytes(StandardCharsets.UTF_8));
//			outputStream.flush();
//			System.out.println("Dados enviados com sucesso: \"" + data + "\"");
//		} catch (IOException e) {
//			System.err.println("Erro ao enviar dados pela porta serial: " + e.getMessage());
//			e.printStackTrace();
//		}
//	}
}