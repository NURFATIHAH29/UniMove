package controller; 

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/FeedbackServlet")
public class FeedbackServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Ambil session dan check sekuriti
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userName") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // 2. Ambil data dari borang aduan
        String category = request.getParameter("category");
        String message = request.getParameter("message");
        String userIC = (String) session.getAttribute("userIC"); // Ambil IC dari session

        // Validasi input kosong
        if (category == null || message == null || message.trim().isEmpty()) {
            response.sendRedirect("Staff/feedback.jsp?status=invalid");
            return;
        }

        // 3. Konfigurasi Database
        String dbUrl = "jdbc:mysql://localhost:3306/uvbs_db";
        String dbUser = "root";
        String dbPass = "admin";

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            // Load Driver MySQL
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

            // 'Confirmed' status untuk feedback
            String sql = "INSERT INTO feedback (user_id, category, message, status) VALUES (?, ?, ?, 'Confirmed')";
            ps = conn.prepareStatement(sql);
            ps.setString(1, userIC);
            ps.setString(2, category);
            ps.setString(3, message);

            int result = ps.executeUpdate();

            // 4. Hantar respons semula ke halaman feedback.jsp
            if (result > 0) {
                response.sendRedirect("Staff/feedback.jsp?status=success");
            } else {
                response.sendRedirect("Staff/feedback.jsp?status=failed");
            }

        } catch (Exception e) {
            e.printStackTrace();
            // Jika error, hantar status error supaya senang debug
            response.sendRedirect("Staff/feedback.jsp?status=error&msg=" + e.getMessage());
        } finally {
            try {
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Jika ada request GET sesat, hantar pergi page feedback terus
        response.sendRedirect("Staff/feedback.jsp");
    }
}