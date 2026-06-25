<%-- 
    Document   : markAsRead
    Created on : 24 Jun 2026, 10:42:41 pm
    Author     : fatihah
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // 1. Menghalang browser daripada menyimpan cache respon
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setHeader("Expires", "0");

    // 2. Mengambil parameter 'id' yang dihantar oleh fungsi fetch() JavaScript
    String notifIdStr = request.getParameter("id");
    
    // Semak jika ID sah dan tidak kosong
    if (notifIdStr != null && !notifIdStr.trim().isEmpty()) {
        
        // 3. Konfigurasi Sambungan Pangkalan Data (uvbs_db)
        String dbUrl = "jdbc:mysql://localhost:3306/uvbs_db";
        String dbUser = "root";
        String dbPass = "admin";
        
        Connection conn = null;
        PreparedStatement ps = null;
        
        try {
            // 4. Load Driver JDBC & Buka Sambungan Database
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
            
            // 5. Query SQL untuk mengemas kini status 'is_read' kepada 1 berdasarkan 'notification_id'
            String sql = "UPDATE notifications SET is_read = 1 WHERE notification_id = ?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, Integer.parseInt(notifIdStr));
            
            // Jalankan arahan SQL
            int rowsUpdated = ps.executeUpdate();
            
            // 6. Hantar respon status kembali kepada JavaScript fetch()
            if (rowsUpdated > 0) {
                response.setStatus(HttpServletResponse.SC_OK); // Status 200: Berjaya
                out.print("SUCCESS: Notification status updated.");
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND); // Status 404: Rekod tiada
                out.print("ERROR: Notification ID not found in database.");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR); // Status 500: Ralat Sistem
            out.print("DATABASE ERROR: " + e.getMessage());
        } finally {
            // 7. Tutup semula semua resource database dengan selamat
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
    } else {
        // Jika request dihantar tanpa sebarang parameter '?id='
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST); // Status 400: Bad Request
        out.print("BAD REQUEST: Missing 'id' parameter.");
    }
%>