package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/SignupServlet")
public class SignupServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Ambil data dari form
        String role = "staff"; 
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("uEmail");
        String icNo = request.getParameter("icNo"); // Ini akan masuk ke user_id
        String staffID = request.getParameter("staffID");
        String dept = request.getParameter("dept");
        String pass = request.getParameter("pass");

        response.setContentType("text/html");
        PrintWriter out = response.getWriter();

        // 2. LOGIK: Check domain @ocean.umt.edu.my
        if (email == null || !email.toLowerCase().trim().endsWith("@ocean.umt.edu.my")) {
            out.println("<script>");
            out.println("alert('Pendaftaran Gagal! Sila gunakan email rasmi @ocean.umt.edu.my sahaja.');");
            out.println("window.history.back();");
            out.println("</script>");
            return;
        }

        // 3. Database Connection
        String dbUrl = "jdbc:mysql://localhost:3306/uvbs_db";
        String dbUser = "root";
        String dbPass = "admin"; 

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

            // sql insert data into users
            String sql = "INSERT INTO users (user_id, full_name, email, password, role, department, staff_id, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, icNo); // icNo simpan ke user_id
            ps.setString(2, fullName);
            ps.setString(3, email);
            ps.setString(4, pass);
            ps.setString(5, role);
            ps.setString(6, dept);
            ps.setString(7, staffID);
            ps.setString(8, "APPROVED"); 

            ps.executeUpdate();
            conn.close();
            
           
            out.println("<script>");
            out.println("alert('Pendaftaran Berjaya! Sila log masuk.');");
            // GUNA PATH RELATIF
            out.println("window.location='Staff/login.jsp';"); 
            out.println("</script>");

        } catch (SQLIntegrityConstraintViolationException e) {
            out.println("<script>alert('Ralat: User ID (IC) atau Email sudah didaftarkan.'); window.history.back();</script>");
        } catch (Exception e) {
            out.println("Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}