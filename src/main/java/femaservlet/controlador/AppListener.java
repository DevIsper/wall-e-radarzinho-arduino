package femaservlet.controlador;

import femaservlet.services.SerialCommunicator;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

@WebListener
public class AppListener implements ServletContextListener {

    private final SerialCommunicator serial = SerialCommunicator.getInstance();

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        serial.connect("/dev/ttyUSB0", 9600);
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        serial.disconnect();
    }
}
