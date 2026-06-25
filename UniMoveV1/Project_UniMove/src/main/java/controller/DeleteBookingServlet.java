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

@WebServlet("/DeleteBookingServlet")
public class DeleteBookingServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Authentication users
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userName") == null) {
            response.sendRedirect("Staff/login.jsp");
            return;
        }

        // 2. Ambil parameter booking_id dari form
        String bookingIdStr = request.getParameter("booking_id");
        
        if (bookingIdStr != null && !bookingIdStr.trim().isEmpty()) {
            // Maklumat sambungan database 
            String dbUrl = "jdbc:mysql://localhost:3306/uvbs_db";
            String dbUser = "root";
            String dbPass = "admin";

            Connection conn = null;
            PreparedStatement ps = null;

            try {
                // 3. Load Driver & Buka Sambungan
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

                // 4. SQL Query untuk padam terus dari table bookings
                String sql = "DELETE FROM bookings WHERE booking_id = ?";
                ps = conn.prepareStatement(sql);
                ps.setInt(1, Integer.parseInt(bookingIdStr));

                // 5. Jalankan arahan padam
                int rowsDeleted = ps.executeUpdate();

                // 6. Redirect semula ke dashboard dengan membawa status
                if (rowsDeleted > 0) {
                    // Berjaya dipadam dari database
                    response.sendRedirect("Staff/staffDashboard.jsp?deleteStatus=success");
                } else {
                    // Gagal sebab ID tak jumpa atau masalah lain
                    response.sendRedirect("Staff/staffDashboard.jsp?deleteStatus=not_found");
                }

            } catch (Exception e) {
                e.printStackTrace();
                // Jika ada ralat SQL (cth: Constraint/Foreign Key error)
                response.sendRedirect("Staff/staffDashboard.jsp?deleteStatus=error&msg=" + e.getMessage());
            } finally {
                // 7. Tutup resource database dengan selamat
                try {
                    if (ps != null) ps.close();
                    if (conn != null) conn.close();
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }
        } else {
            // Jika tiada booking_id dihantar
            response.sendRedirect("Staff/staffDashboard.jsp?deleteStatus=invalid_id");
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Menyekat akses secara GET demi keselamatan data
        response.sendRedirect("Staff/staffDashboard.jsp");
    }
}