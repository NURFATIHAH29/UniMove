<%-- 
    Document   : adminApprovals
    Created on : 2 May 2026
    Author     : fatihah 
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    // 1. Security Check
    if (session.getAttribute("userName") == null || !"admin".equals(session.getAttribute("userRole"))) {
        response.sendRedirect("../Staff/login.jsp");
        return;
    }

    String fullName = (String) session.getAttribute("userName");
    
    // 2. Database Configuration
    String dbUrl = "jdbc:mysql://localhost:3306/uvbs_db";
    String dbUser = "root";
    String dbPass = "admin"; 

    // 3. Get sorting & month filter parameters from URL
    String sortBy = request.getParameter("sort");
    if (sortBy == null || sortBy.trim().isEmpty()) {
        sortBy = "desc"; // Default to newest
    }

    String selectedMonth = request.getParameter("month");
    if (selectedMonth == null || selectedMonth.trim().isEmpty()) {
        selectedMonth = "all"; // Default to show all months
    }

    // 4. Format Current Date
    LocalDate today = LocalDate.now();
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("d MMM yyyy", Locale.ENGLISH);
    String currentDateStr = today.format(formatter);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Booking Approvals | UVBS Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        .force-table { width: 100% !important; text-align: left !important; font-size: 0.875rem !important; border-collapse: collapse !important; }
        .force-th { font-size: 10px !important; text-transform: uppercase !important; font-weight: 700 !important; color: #9ca3af !important; background-color: #ffffff !important; padding: 16px !important; border-bottom: 1px solid #e5e7eb !important; }
        .force-td { padding: 16px !important; border-bottom: 1px solid #e5e7eb !important; vertical-align: middle !important; }
        
        .nav-active { 
            color: white !important; 
            background-color: rgba(184, 151, 77, 0.1) !important; 
            border-left: 4px solid #b8974d !important; 
        }
        .badge-confirmed { background-color: #dcfce7 !important; color: #166534 !important; padding: 4px 12px !important; border-radius: 9999px !important; font-size: 9px !important; font-weight: 900 !important; text-transform: uppercase; display: inline-block !important; }
        
        .modal-scroll-clean::-webkit-scrollbar {
            display: none;
        }
        .modal-scroll-clean {
            -ms-overflow-style: none;
            scrollbar-width: none;
        }
    </style>
</head>
<body class="flex flex-col md:flex-row min-h-screen bg-gray-100" style="display: flex !important; flex-direction: row !important; margin: 0 !important;">

    <aside class="hidden md:flex w-64 bg-[#1a2a3a] flex-col text-white shadow-xl fixed top-0 bottom-0 left-0 z-50" style="display: flex !important; flex-direction: column !important; height: 100vh !important;">
        <div class="p-8 text-center border-b border-gray-700">
            <i class="fas fa-user-shield text-5xl mb-3 text-[#b8974d]"></i>
            <h2 class="font-bold text-sm uppercase tracking-widest leading-tight"><%= fullName %></h2>
            <p class="text-[10px] text-gray-400 mt-1 uppercase tracking-tighter">System Admin</p>
        </div>
        
        <nav class="flex-grow mt-6" style="display: flex !important; flex-direction: column !important;">
            <a href="adminDashboard.jsp" class="text-gray-400 flex items-center gap-4 px-8 py-4 transition hover:bg-white/5 hover:text-white">
                <i class="fas fa-th-large w-5 text-center"></i> Dashboard
            </a>
            <a href="adminApprovals.jsp" class="nav-active flex items-center gap-4 px-8 py-4">
                <i class="fas fa-check-square w-5 text-center"></i> Booking Approvals
            </a>
            <a href="manageReports.jsp" class="text-gray-400 flex items-center gap-4 px-8 py-4 transition hover:bg-white/5 hover:text-white">
                <i class="fas fa-tools w-5 text-center"></i> Maintenance Reports
            </a>
            <a href="../Vehicle/manageVehicle.jsp" class="text-gray-400 flex items-center gap-4 px-8 py-4 transition hover:bg-white/5 hover:text-white">
                <i class="fas fa-car-side w-5 text-center"></i> Vehicle Management
            </a>
            <a href="../driver/manageDrivers.jsp" class="text-gray-400 flex items-center gap-4 px-8 py-4 transition hover:bg-white/5 hover:text-white">
                <i class="fas fa-user-tie w-5 text-center"></i> Driver Management
            </a>
            <a href="manageFeedback.jsp" class="text-gray-400 flex items-center gap-4 px-8 py-4 transition hover:bg-white/5 hover:text-white">
                <i class="fas fa-comment-alt w-5 text-center"></i> User Feedback
            </a>
        </nav>

        <div class="p-4 mb-2">
            <a href="../LogoutServlet" class="bg-[#4a1d1f] hover:bg-red-900 flex items-center justify-center gap-3 px-6 py-3 text-white text-[11px] font-bold rounded-lg shadow-lg uppercase tracking-wider transition">
                <i class="fas fa-sign-out-alt" style="transform: rotate(180deg) !important;"></i> LOGOUT
            </a>
        </div>
    </aside>

    <main class="flex-grow md:ml-64 p-4 md:p-10" style="flex-grow: 1 !important; margin-left: 16rem !important;">
        
        <header class="mb-10 flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
            <div>
                <h1 class="text-2xl font-bold text-gray-800">Confirmed Booking List</h1>
                <p class="text-sm text-gray-500 italic text-blue-600">View live assignments and deployment details.</p>
            </div>
            
            <div class="flex items-center gap-2.5 bg-white px-4 py-2.5 rounded-lg border shadow-sm font-bold text-xs text-gray-700 tracking-wide uppercase">
                <i class="far fa-clock text-[#b8974d] text-sm"></i>
                <span><%= currentDateStr %></span>
            </div>
        </header>

        <div class="bg-white rounded-xl shadow-md border border-gray-200 overflow-hidden">
            <div class="p-6 bg-gray-50 border-b flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4" style="display: flex !important; justify-content: space-between !important; align-items: center !important;">
                <h4 class="font-bold text-xs uppercase tracking-tighter text-gray-700">Live Active Bookings</h4>
                
                <div class="flex flex-wrap items-center gap-4">
                    <div class="flex items-center gap-2">
                        <label for="monthFilter" class="text-[10px] font-bold uppercase text-gray-400 tracking-wider"><i class="far fa-calendar-alt"></i> Month:</label>
                        <select id="monthFilter" onchange="updateFilters()" class="text-xs bg-white border border-gray-300 rounded-lg px-2.5 py-1.5 font-medium text-gray-700 shadow-sm focus:outline-none focus:border-blue-500 cursor-pointer">
                            <option value="all" <%= "all".equals(selectedMonth) ? "selected" : "" %>>All Months</option>
                            <option value="1" <%= "1".equals(selectedMonth) ? "selected" : "" %>>January</option>
                            <option value="2" <%= "2".equals(selectedMonth) ? "selected" : "" %>>February</option>
                            <option value="3" <%= "3".equals(selectedMonth) ? "selected" : "" %>>March</option>
                            <option value="4" <%= "4".equals(selectedMonth) ? "selected" : "" %>>April</option>
                            <option value="5" <%= "5".equals(selectedMonth) ? "selected" : "" %>>May</option>
                            <option value="6" <%= "6".equals(selectedMonth) ? "selected" : "" %>>June</option>
                            <option value="7" <%= "7".equals(selectedMonth) ? "selected" : "" %>>July</option>
                            <option value="8" <%= "8".equals(selectedMonth) ? "selected" : "" %>>August</option>
                            <option value="9" <%= "9".equals(selectedMonth) ? "selected" : "" %>>September</option>
                            <option value="10" <%= "10".equals(selectedMonth) ? "selected" : "" %>>October</option>
                            <option value="11" <%= "11".equals(selectedMonth) ? "selected" : "" %>>November</option>
                            <option value="12" <%= "12".equals(selectedMonth) ? "selected" : "" %>>December</option>
                        </select>
                    </div>

                    <div class="flex items-center gap-2">
                        <label for="sortSelector" class="text-[10px] font-bold uppercase text-gray-400 tracking-wider"><i class="fas fa-sort"></i> Order:</label>
                        <select id="sortSelector" onchange="updateFilters()" class="text-xs bg-white border border-gray-300 rounded-lg px-2.5 py-1.5 font-medium text-gray-700 shadow-sm focus:outline-none focus:border-blue-500 cursor-pointer">
                            <option value="desc" <%= "desc".equals(sortBy) ? "selected" : "" %>>Latest Confirmed (Newest)</option>
                            <option value="asc" <%= "asc".equals(sortBy) ? "selected" : "" %>>Oldest Confirmed (Ascending)</option>
                        </select>
                    </div>
                </div>
            </div>
            
            <div class="overflow-x-auto">
                <table class="force-table">
                    <thead>
                        <tr>
                            <th class="force-th" style="width: 25%;">Requester</th>
                            <th class="force-th" style="width: 35%;">Route Details</th>
                            <th class="force-th" style="width: 15%; text-align: center;">Status</th>
                            <th class="force-th" style="width: 25%; text-align: right;">Action</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y text-gray-600">
                        <%
                            Connection conn = null;
                            PreparedStatement ps = null;
                            ResultSet rs = null;
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver");
                                conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
                                
                                String sql = "SELECT b.*, "
                                           + "(SELECT GROUP_CONCAT(d.full_name SEPARATOR ' & ') FROM drivers d WHERE FIND_IN_SET(d.driver_id, b.assigned_driver_id) > 0) AS multiple_drivers, "
                                           + "(SELECT GROUP_CONCAT(CONCAT(v.model, ' (', v.plate_number, ')') SEPARATOR ' , ') FROM vehicles v WHERE FIND_IN_SET(v.vehicle_id, b.assigned_vehicle_id) > 0) AS multiple_vehicles "
                                           + "FROM bookings b "
                                           + "WHERE b.status = 'Confirmed' ";
                                
                                if (!"all".equals(selectedMonth)) {
                                    sql += "AND MONTH(b.start_date) = ? ";
                                }
                                
                                if ("asc".equals(sortBy)) {
                                    sql += "ORDER BY b.booking_id ASC";
                                } else {
                                    sql += "ORDER BY b.booking_id DESC";
                                }
                                
                                ps = conn.prepareStatement(sql);
                                
                                if (!"all".equals(selectedMonth)) {
                                    ps.setInt(1, Integer.parseInt(selectedMonth));
                                }
                                
                                rs = ps.executeQuery();
                                
                                boolean hasData = false;
                                while(rs.next()) {
                                    hasData = true;
                                    int bId = rs.getInt("booking_id");
                                    String staffIC = rs.getString("user_id") != null ? rs.getString("user_id").replace("'", "\\'") : "";
                                    
                                    String staffEmail = rs.getString("phone_number") != null ? staffIC + "@kkr.gov.my" : "staff@kkr.gov.my";
                                    String requesterName = rs.getString("staff_name") != null ? rs.getString("staff_name") : "User: " + staffIC;
                                    String requestedType = rs.getString("vehicle_type");
                                    String pickup = rs.getString("pickup_location");
                                    String destination = rs.getString("destination");
                                    String startDate = rs.getDate("start_date") != null ? rs.getDate("start_date").toString() : "-";
                                    
                                    String purpose = rs.getString("purpose") != null ? rs.getString("purpose") : "-";
                        %>
                        <tr class="hover:bg-gray-50 transition">
                            <td class="force-td">
                                <div class="flex items-center gap-2 flex-wrap">
                                    <p class="font-bold text-blue-900" style="color: #1e3a8a !important; font-weight: 700 !important;"><%= requesterName %></p>
                                </div>
                                <p class="text-[10px] text-gray-400 italic">ID: #BK-<%= bId %></p>
                                <p class="text-[10px] font-bold text-blue-600 uppercase" style="color: #2563eb !important; font-weight: 700 !important;"><%= requestedType %> (<%= rs.getInt("passengers") %> Pax)</p>
                                
                                <div class="mt-1 text-[11px] text-slate-500 border-l-2 border-amber-400 pl-1.5 line-clamp-1" title="<%= purpose %>">
                                    <span class="font-semibold text-amber-700">Purpose:</span> <%= purpose %>
                                </div>
                            </td>
                            
                            <td class="force-td">
                                <div class="flex flex-col gap-1 text-[11px]" style="display: flex !important; flex-direction: column !important; gap: 4px !important;">
                                    <span class="font-bold text-gray-700" style="font-weight: 700 !important; color: #374151 !important;"><i class="fas fa-map-marker-alt text-red-500 mr-1"></i> From: <%= pickup %></span>
                                    <span class="font-bold text-gray-700" style="font-weight: 700 !important; color: #374151 !important;"><i class="fas fa-flag-checkered text-green-500 mr-1"></i> To: <%= destination %></span>
                                    <p class="text-gray-400 font-bold" style="color: #9ca3af !important; font-weight: 700 !important;"><i class="far fa-calendar"></i> <%= startDate %></p>
                                </div>
                            </td>
                            
                            <td class="force-td text-center" style="text-align: center !important;">
                                <span class="badge-confirmed">Confirmed</span>
                            </td>
                            
                            <td class="force-td text-right" style="text-align: right !important;">
                                <div class="flex justify-end gap-2">
                                    <button type="button" 
                                            onclick="fetchAndOpenModal(<%= bId %>)"
                                            class="bg-blue-600 hover:bg-blue-700 text-white text-[11px] font-bold px-3 py-2 rounded-lg shadow transition duration-200 uppercase tracking-wider cursor-pointer"
                                            style="background-color: #2563eb !important; color: #ffffff !important;">
                                        Details
                                    </button>
                                    
                                    <button type="button"
                                            onclick="openDeleteModal(<%= bId %>, '<%= staffIC %>', '<%= staffEmail %>')"
                                            class="bg-red-600 hover:bg-red-700 text-white text-[11px] font-bold px-3 py-2 rounded-lg shadow transition duration-200 uppercase tracking-wider cursor-pointer"
                                            style="background-color: #dc2626 !important; color: #ffffff !important;">
                                        <i class="fas fa-trash-alt mr-1"></i> Cancel
                                    </button>
                                </div>
                            </td>
                        </tr>
                        <% 
                                }
                                if(!hasData) {
                        %>
                                    <tr><td colspan='4' class='p-10 text-center text-gray-400 font-bold uppercase' style='text-align: center !important; padding: 40px !important;'>No confirmed bookings found for the selected filter.</td></tr>
                        <%
                                }
                            } catch(Exception e) {
                        %>
                                <tr><td colspan='4' class='p-4 text-red-600 bg-red-50 text-xs'>Error: <%= e.getMessage() %></td></tr>
                        <%
                            } finally {
                                if(rs != null) try { rs.close(); } catch(Exception e){}
                                if(ps != null) try { ps.close(); } catch(Exception e){}
                                if(conn != null) try { conn.close(); } catch(Exception e){}
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </main>

    <div id="detailsModal" class="fixed inset-0 bg-black/50 z-[9999] flex items-center justify-center opacity-0 pointer-events-none transition-opacity duration-300">
        <div class="bg-white rounded-2xl shadow-2xl w-full max-w-lg mx-4 max-h-[85vh] overflow-y-auto modal-scroll-clean transform scale-95 transition-transform duration-300">
            <div class="bg-[#1a2a3a] text-white px-6 py-4 flex justify-between items-center sticky top-0 z-10 shadow-sm">
                <h3 class="font-bold text-sm uppercase tracking-wider"><i class="fas fa-info-circle text-[#b8974d] mr-2"></i> Trip Deployment Details</h3>
                <button onclick="closeModal('detailsModal')" class="text-gray-400 hover:text-white transition text-lg">&times;</button>
            </div>
            
            <div class="p-6 space-y-4 text-xs" id="modalDynamicBody">
                <div class="text-center py-4 text-gray-400 italic"><i class="fas fa-spinner fa-spin mr-2"></i>Loading live assignment...</div>
            </div>
            
            <div class="bg-gray-50 px-6 py-3 flex justify-end sticky bottom-0 border-t z-10 shadow-inner">
                <button onclick="closeModal('detailsModal')" class="bg-[#1a2a3a] text-white px-5 py-2 rounded-lg font-bold uppercase text-[10px] tracking-wider hover:bg-slate-800 transition">Close Details</button>
            </div>
        </div>
    </div>

    <div id="deleteModal" class="fixed inset-0 bg-black/60 z-[9999] flex items-center justify-center opacity-0 pointer-events-none transition-opacity duration-300">
        <div class="bg-white rounded-2xl shadow-2xl w-full max-w-md mx-4 transform scale-95 transition-transform duration-300 overflow-hidden">
            <div class="bg-red-700 text-white px-6 py-4 flex items-center gap-2">
                <i class="fas fa-exclamation-triangle text-[#f59e0b] text-lg animate-pulse"></i>
                <h3 class="font-bold text-xs uppercase tracking-wider">Confirm Critical Cancellation</h3>
            </div>
            
            <form action="${pageContext.request.contextPath}/AdminDeleteBookingServlet" method="POST" class="p-6 space-y-4" onsubmit="return validateDeleteForm()">
                <input type="hidden" id="deleteBookingId" name="booking_id">
                <input type="hidden" id="deleteStaffIC" name="staff_ic">
                <input type="hidden" id="deleteStaffEmail" name="staff_email">
                
                <p class="text-xs text-gray-600 leading-relaxed">
                    You are cancelling a <span class="text-green-700 font-bold">Confirmed</span> booking. This action will immediately **release the driver & vehicle** and trigger a **critical warning pop-up** on the affected staff member's dashboard.
                </p>
                
                <div>
                    <label class="block text-[10px] font-bold text-gray-400 uppercase tracking-wider mb-2">State Reason for Cancellation (Crucial):</label>
                    <textarea id="cancelReason" name="reason" rows="3" required
                              placeholder="Example: Sudden vehicle breakdown / Unexpected VIP event conflict..."
                              class="w-full text-xs border border-gray-300 rounded-xl p-3 focus:outline-none focus:ring-2 focus:ring-red-500 focus:border-transparent resize-none"></textarea>
                </div>
                
                <div class="flex justify-end gap-3 pt-2">
                    <button type="button" onclick="closeModal('deleteModal')"
                            class="bg-gray-200 text-gray-700 text-[10px] font-bold px-4 py-2 rounded-lg uppercase tracking-wider hover:bg-gray-300 transition">
                        Cancel
                    </button>
                    <button type="submit"
                            class="bg-red-600 text-white text-[10px] font-bold px-5 py-2 rounded-lg uppercase tracking-wider hover:bg-red-800 transition shadow-md shadow-red-200">
                        Submit & Cancel
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script>
        // Reads URL query parameter status to display success/error alerts
        document.addEventListener("DOMContentLoaded", function() {
            const urlParams = new URLSearchParams(window.location.search);
            const status = urlParams.get('status');
            
            if (status === 'deleted') {
                Swal.fire({ icon: 'success', title: 'Successfully Cancelled', text: 'The booking has been removed. A pop-up notification & alert email have been sent to the staff.', confirmButtonColor: '#1e2a3a' });
            } else if (status === 'not_found') {
                Swal.fire({ icon: 'error', title: 'Error', text: 'Booking record not found.', confirmButtonColor: '#1e2a3a' });
            } else if (status === 'invalid_input') {
                Swal.fire({ icon: 'warning', title: 'Reason Required', text: 'Please input a valid cancellation reason.', confirmButtonColor: '#1e2a3a' });
            } else if (status === 'error') {
                Swal.fire({ icon: 'error', title: 'Operational Error', text: 'Failed to process cancellation within the database.', confirmButtonColor: '#1e2a3a' });
            }
        });

        function updateFilters() {
            const monthValue = document.getElementById('monthFilter').value;
            const sortValue = document.getElementById('sortSelector').value;
            window.location.href = "adminApprovals.jsp?month=" + monthValue + "&sort=" + sortValue;
        }

        function fetchAndOpenModal(bookingId) {
            const bodyContainer = document.getElementById('modalDynamicBody');
            bodyContainer.innerHTML = '<div class="text-center py-8 text-gray-400 italic"><i class="fas fa-spinner fa-spin mr-2 text-blue-600"></i>Fetching live asset records...</div>';
            
            openElement('detailsModal');

            fetch('../Vehicle/getVehicleTripDetails.jsp?bid=' + bookingId)
                .then(res => res.text())
                .then(html => {
                    bodyContainer.innerHTML = html;
                })
                .catch(err => {
                    bodyContainer.innerHTML = '<p class="text-red-500 font-mono text-center p-4">❌ System Error:<br>' + err.message + '</p>';
                });
        }

        // Opens the cancellation input modal
        function openDeleteModal(bookingId, staffIC, staffEmail) {
            document.getElementById('deleteBookingId').value = bookingId;
            document.getElementById('deleteStaffIC').value = staffIC;
            document.getElementById('deleteStaffEmail').value = staffEmail;
            document.getElementById('cancelReason').value = ""; // Reset form text
            openElement('deleteModal');
        }

        function validateDeleteForm() {
            const reason = document.getElementById('cancelReason').value;
            if (!reason || reason.trim().length < 5) {
                Swal.fire({ icon: 'warning', title: 'Reason Too Short', text: 'Please provide a clear reason (minimum 5 characters) for the staff record log.' });
                return false;
            }
            return true;
        }

        function openElement(id) {
            const modal = document.getElementById(id);
            modal.classList.remove('opacity-0', 'pointer-events-none');
            modal.querySelector('.transform').classList.remove('scale-95');
            modal.querySelector('.transform').classList.add('scale-100');
        }

        function closeModal(id) {
            const modal = document.getElementById(id);
            modal.classList.add('opacity-0', 'pointer-events-none');
            modal.querySelector('.transform').classList.remove('scale-100');
            modal.querySelector('.transform').classList.add('scale-95');
        }
    </script>
</body>
</html>