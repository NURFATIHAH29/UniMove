<%@ page import="java.sql.*" %>
<%
    String id = request.getParameter("id");
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/uvbs_db", "root", "admin");
        PreparedStatement ps = conn.prepareStatement("DELETE FROM vehicles WHERE vehicle_id = ?");
        ps.setInt(1, Integer.parseInt(id));
        ps.executeUpdate();
        conn.close();
        response.sendRedirect("manageVehicle.jsp");
    } catch(Exception e) { out.println(e.getMessage()); }
%>