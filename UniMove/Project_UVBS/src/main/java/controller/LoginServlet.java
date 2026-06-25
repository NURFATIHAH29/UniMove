package controller;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Ambil data dari form
        String ic = request.getParameter("uIC");
        String pass = request.getParameter("uPass");
        String roleFromForm = request.getParameter("loginRole");

        // DEBUG: Monitor kat console
        System.out.println("=== LOGIN ATTEMPT ===");
        System.out.println("ID Input: " + ic);
        System.out.println("Role Input: " + roleFromForm);

        // Database Configuration
        String dbUrl = "jdbc:mysql://localhost:3306/uvbs_db";
        String dbUser = "root";
        String dbPass = "admin"; 

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

            // 2. Query SQL untuk sahkan user
            String sql = "SELECT * FROM users WHERE user_id=? AND password=? AND role=?";
            ps = conn.prepareStatement(sql);
            ps.setString(1, ic);
            ps.setString(2, pass);
            ps.setString(3, roleFromForm);

            rs = ps.executeQuery();

            if (rs.next()) {
                
                String accountStatus = rs.getString("status");
                String dbRole = rs.getString("role").toLowerCase();
                String userId = rs.getString("user_id");

                System.out.println("Login Berjaya! Role dlm DB: " + dbRole);

                // 3. Check status akaun
                if ("PENDING".equalsIgnoreCase(accountStatus)) {
                    request.setAttribute("errorMessage", "Akaun anda masih dalam proses kelulusan Admin.");
                    request.getRequestDispatcher("/Staff/login.jsp").forward(request, response);
                } else {
                    // 4. Create Session
                    HttpSession session = request.getSession();
                    session.setAttribute("userName", rs.getString("full_name"));
                    session.setAttribute("userRole", dbRole); 
                    session.setAttribute("userIC", userId);

                    // --- LOGIC TAMBAHAN: Tarik driver_id jika role adalah driver ---
                    if ("driver".equals(dbRole)) {
                        String sqlDrv = "SELECT driver_id FROM drivers WHERE staff_id = ?";
                        try (PreparedStatement psDrv = conn.prepareStatement(sqlDrv)) {
                            psDrv.setString(1, userId);
                            try (ResultSet rsDrv = psDrv.executeQuery()) {
                                if (rsDrv.next()) {
                                    int dID = rsDrv.getInt("driver_id");
                                    session.setAttribute("driverId", dID);
                                    System.out.println("Driver ID djumpai & disimpan dlm session: " + dID);
                                } else {
                                    System.out.println("AMARAN: User role driver tapi tiada record dlm table drivers!");
                                }
                            }
                        }
                    }
                   

                    // 5. Redirect ikut Role 
                    String contextPath = request.getContextPath();
                    
                    if (dbRole.equals("admin")) {
                        response.sendRedirect(contextPath + "/Admin/adminDashboard.jsp");
                    } else if (dbRole.equals("staff")) {
                        response.sendRedirect(contextPath + "/Staff/staffDashboard.jsp");
                    } else if (dbRole.equals("driver")) {
                       
                        response.sendRedirect(contextPath + "/driver/driverDashboard.jsp");
                    } else {
                        request.setAttribute("errorMessage", "Role tidak sah dalam sistem.");
                        request.getRequestDispatcher("/Staff/login.jsp").forward(request, response);
                    }
                }
            } else {
              
                request.setAttribute("errorMessage", "ID Pengguna, Kata Laluan, atau Peranan salah.");
                request.getRequestDispatcher("/Staff/login.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("System Error: " + e.getMessage());
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
    }
}