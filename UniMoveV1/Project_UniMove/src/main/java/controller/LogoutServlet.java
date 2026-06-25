package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/LogoutServlet")
public class LogoutServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Dapatkan session sedia ada
        HttpSession session = request.getSession(false);
        
        if (session != null) {
            // 2. Padamkan semua data dalam session
            session.invalidate();
        }
        
        // 3. Hantar user balik ke page login
        
        response.sendRedirect("Staff/login.jsp");
    }
}