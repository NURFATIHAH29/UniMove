package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/NotificationCountServlet")
public class NotificationCountServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Set jenis data pulangan sebagai JSON
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession(false);
        PrintWriter out = response.getWriter();
        
        // Cek sekiranya user belum login
        if (session == null || session.getAttribute("userIC") == null) {
            out.print("{\"count\": 0}");
            return;
        }
        
        String userIC = (String) session.getAttribute("userIC");
        
        // Ambil ID tempahan terakhir yang telah dilihat oleh staf dari memori session
        Integer lastSeenId = (Integer) session.getAttribute("lastSeenBookingId");
        if (lastSeenId == null) {
            lastSeenId = 0; // Jika staf baru login dan belum pernah buka tab notification
        }
        
        int unreadCount = 0;
        String dbUrl = "jdbc:mysql://localhost:3306/uvbs_db";
        String dbUser = "root";
        String dbPass = "admin"; 
        
        // SQL: Kira tempahan milik user ini yang telah dikemas kini DAN mempunyai ID lebih besar daripada kali terakhir dilihat
        String sql = "SELECT COUNT(*) FROM bookings WHERE user_id = ? AND status != 'Pending' AND booking_id > ?";
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                
                ps.setString(1, userIC);
                ps.setInt(2, lastSeenId);
                
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        unreadCount = rs.getInt(1);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        // Pulangkan hasil kiraan dalam format JSON ke JavaScript AJAX
        out.print("{\"count\": " + unreadCount + "}");
        out.flush();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}