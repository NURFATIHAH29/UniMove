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

/**
 * Servlet untuk kemaskini status driver secara real-time
 */
@WebServlet("/UpdateDriverStatus")
public class UpdateDriverStatusServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Ambil session untuk dapatkan driverId
        HttpSession session = request.getSession();
        Integer driverId = (Integer) session.getAttribute("driverId");
        
        // 2. Ambil parameter status dari AJAX request
        String newStatus = request.getParameter("status");
        
        // Set response type
        response.setContentType("text/plain");
        
        // Validasi asas
        if (driverId == null || newStatus == null) {
            response.getWriter().write("Error: Session expired or invalid data");
            return;
        }

        Connection conn = null;
        try {
            // 3. Database Connection
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/uvbs_db", "root", "admin");
            
            // 4. Query Update Status dalam table 'drivers'
            String sql = "UPDATE drivers SET status = ? WHERE driver_id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, newStatus);
            ps.setInt(2, driverId);
            
            int rowsUpdated = ps.executeUpdate();
            
            if (rowsUpdated > 0) {
                // Berjaya update
                response.getWriter().write("Success");
                System.out.println("Driver ID " + driverId + " updated to status: " + newStatus);
            } else {
                response.getWriter().write("Error: Driver record not found");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("Database Error: " + e.getMessage());
        } finally {
            // 5. Tutup connection
            try {
                if (conn != null) conn.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}