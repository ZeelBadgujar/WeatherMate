package com.weathermate.model;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.*;

public class LogoutServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session != null) {
            Object userObj = session.getAttribute("user");
            if (userObj != null) {
                System.out.println("Logging out user: " + ((User) userObj).getUsername());
            } else {
                System.out.println("Logging out anonymous session: " + session.getId());
            }

            session.invalidate();
        } else {
            System.out.println("No active session found for logout.");
        }

        response.sendRedirect("index.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}