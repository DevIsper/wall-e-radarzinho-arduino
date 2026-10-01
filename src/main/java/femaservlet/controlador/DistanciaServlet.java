package femaservlet.controlador;

import femaservlet.services.SerialCommunicator;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/distancia")
public class DistanciaServlet extends HttpServlet {

    private final SerialCommunicator serial = SerialCommunicator.getInstance();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("text/plain");
        resp.setCharacterEncoding("UTF-8");
        resp.getWriter().write(String.valueOf(serial.lerDistancia()));
    }
}
