<%-- 
    Document   : login
    Created on : 1 May 2026, 11:40:31 pm
    Author     : fatih
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>UVBS | University Portal</title>
    <link rel="stylesheet" href="Style.css"> 
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    
    <style>
        /* Menggunakan getContextPath() supaya Tomcat boleh baca dari root webapp */
        body {
            background-image: linear-gradient(rgba(26, 42, 58, 0.75), rgba(26, 42, 58, 0.85)), 
                              url('<%= request.getContextPath() %>/images/kampus-umt.jpg') !important;
            background-size: cover !important;
            background-position: center !important;
            background-repeat: no-repeat !important;
            background-attachment: fixed !important;
        }
    </style>
</head>
<body>

    <div class="main-wrapper">
        <div class="login-card">
            
            <div class="sidebar">
                <h2>University Vehicle Booking System</h2>
                <div class="gold-line"></div>   
                <p style="font-size: 0.8rem; opacity: 0.8; line-height: 1.6;">
                    Centralized vehicle management for faculty, staff, and authorized personnel.
                </p>
            </div>

            <div class="form-section">
                
                <div style="text-align: center; margin-bottom: 15px;">
                    <img src="<%= request.getContextPath() %>/images/logo-umt.png" alt="UMT Logo" style="height: 60px; width: auto; display: inline-block;">
                </div>

                <h3>Secure Access</h3>
                <p class="subtitle">UVBS Authentication</p>

                <% 
                    String error = (String) request.getAttribute("errorMessage");
                    if(error != null) { 
                %>
                    <div style="color: #d9534f; background-color: #f2dede; border: 1px solid #ebccd1; padding: 10px; border-radius: 4px; font-size: 0.8rem; margin-bottom: 15px; text-align: center;">
                        <i class="fas fa-exclamation-circle"></i> <%= error %>
                    </div>
                <% } %>

                <form action="../LoginServlet" method="POST">
                    <div class="input-group">
                        <label>Login Type</label>
                        <select name="loginRole" required>
                            <option value="staff">University Staff</option>
                            <option value="driver">Driver</option>
                            <option value="admin">Administrator (PPH)</option>
                        </select>
                    </div>

                    <div class="input-group">
                        <label>User ID (IC Number)</label>
                       <input type="text" name="uIC" minlength="5" maxlength="12" required>
                    </div>

                    <div class="input-group">
                        <label>Password</label>
                        <input type="password" name="uPass" placeholder="••••••••" required>
                    </div>

                    <button type="submit" class="btn-signin">Sign In</button>
                    
                    <div class="form-footer" style="margin-top: 15px; text-align: center; font-size: 0.85rem;">
                        <p>New staff member? <a href="signup.html" style="color: #004a99; text-decoration: none; font-weight: bold;">Request Access</a></p>
                    </div>
                </form>
            </div>
        </div>
    </div>
</body>
</html>