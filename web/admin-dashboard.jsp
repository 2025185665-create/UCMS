<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ucms2.model.Admin, java.util.*, java.sql.*, com.ucms2.db.DBConnection, java.text.SimpleDateFormat" %>
<%
    // 1. Controller Guard: Check Session Data
    if (session.getAttribute("totalClubs") == null) {
        request.getRequestDispatcher("/AdminDashboardController").forward(request, response);
        return;
    }

    Admin admin = (Admin) session.getAttribute("admin");
    if (admin == null || !"admin".equals(session.getAttribute("userRole"))) {
        response.sendRedirect("login.jsp?error=Unauthorized Access");
        return;
    }

    // 2. Fetch from Session
    Integer totalClubs = (Integer) session.getAttribute("totalClubs");
    Integer totalEvents = (Integer) session.getAttribute("totalEvents");
    Integer pendingBuzzCount = (Integer) session.getAttribute("pendingBuzzCount");
    Integer pendingLeaves = (Integer) session.getAttribute("pendingLeaves");
    List leaveRequests = (List) session.getAttribute("leaveRequests");
    List topList = (List) session.getAttribute("topContributors");

    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy, HH:mm");
    String lastLogin = sdf.format(new java.util.Date());

    String successMsg = request.getParameter("success");
    String errorMsg = request.getParameter("error");

    // 3. Chart Data Preparation (Traditional try-finally for GlassFish compatibility)
    StringBuilder labels = new StringBuilder();
    StringBuilder dataValues = new StringBuilder();
    Connection connChart = null;
    Statement stmtChart = null;
    ResultSet rsChart = null;
    try {
        connChart = DBConnection.getConnection();
        String sql = "SELECT c.ClubName, COUNT(m.StudentID) as cnt FROM CLUB c " +
                     "LEFT JOIN CLUB_MEMBERSHIP m ON c.ClubID = m.ClubID AND m.Status = 'active' GROUP BY c.ClubName";
        stmtChart = connChart.createStatement();
        rsChart = stmtChart.executeQuery(sql);
        while(rsChart.next()) {
            labels.append("'").append(rsChart.getString("ClubName")).append("',");
            dataValues.append(rsChart.getInt("cnt")).append(",");
        }
    } catch(Exception e) { 
        e.printStackTrace(); 
    } finally { 
        if(rsChart != null) try { rsChart.close(); } catch(Exception e) {} 
        if(stmtChart != null) try { stmtChart.close(); } catch(Exception e) {} 
        if(connChart != null) try { connChart.close(); } catch(Exception e) {} 
    }
%> <%-- THIS WAS THE MISSING TAG --%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>UCMS Admin - Overview</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <link rel="stylesheet" href="css/styles.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;800&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; }
        .nav-link.active { background: rgba(59, 130, 246, 0.15); border-right: 4px solid #3b82f6; color: #fff !important; }
        .interactive-card { transition: all 0.3s ease; }
        .interactive-card:hover { transform: translateY(-5px); border-color: #3b82f6; }
        @keyframes slideIn { from { transform: translateY(-20px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
        .toast-notification { animation: slideIn 0.4s ease-out forwards; }
    </style>
</head>
<body class="bg-gray-50">

    <%-- TOAST NOTIFICATION --%>
    <% if (successMsg != null || errorMsg != null) { %>
    <div id="adminToast" class="fixed top-8 left-1/2 -translate-x-1/2 z-[100] toast-notification">
        <div class="<%= successMsg != null ? "bg-slate-900" : "bg-red-900" %> text-white px-8 py-4 rounded-2xl shadow-2xl flex items-center gap-4 border border-white/10">
            <div class="<%= successMsg != null ? "bg-emerald-500" : "bg-red-500" %> p-2 rounded-full">
                <svg class="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7"></path></svg>
            </div>
            <p class="text-sm font-bold"><%= successMsg != null ? successMsg : errorMsg %></p>
        </div>
    </div>
    <script>setTimeout(() => { document.getElementById('adminToast').style.opacity='0'; setTimeout(()=>document.getElementById('adminToast').remove(), 500); }, 3000);</script>
    <% } %>

    <div class="dashboard-container">
        <nav class="sidebar">
            <a href="index.jsp" class="sidebar-brand text-2xl font-black tracking-tighter italic">UCMS Admin</a>
            <a href="admin-dashboard.jsp" class="nav-link active">📊 Overview</a>
            <a href="clubs.jsp" class="nav-link">🏛️ Manage Clubs</a>
            <a href="events.jsp" class="nav-link">📅 Event Control</a>
            <a href="members.jsp" class="nav-link">👥 User Records</a>            
            <a href="campus-buzz.jsp" class="nav-link relative flex items-center justify-between">
                <span>📢 Moderation</span>
                <% if (pendingBuzzCount > 0) { %>
                    <span class="relative inline-flex rounded-full h-5 w-5 bg-red-500 text-white text-[10px] font-black items-center justify-center animate-bounce"><%= pendingBuzzCount %></span>
                <% } %>
            </a>
            <div style="margin-top: auto; padding-top: 2rem; border-top: 1px solid #334155;">
                <p class="text-sm font-bold text-white mb-4"><%= admin.getAdminName() %></p>
                <a href="logout" class="nav-link" style="color: #ef4444;">🚪 Logout</a>
            </div>
        </nav>

        <main class="main-content p-10">
            <header class="mb-10 flex justify-between items-end">
                <div>
                    <h1 class="text-4xl font-black text-slate-800 tracking-tighter">System Overview</h1>
                    <p class="text-slate-500 mt-1 font-medium">Real-time engagement metrics.</p>
                </div>
                <div class="text-right">
                    <p class="text-[10px] font-black text-slate-400 uppercase tracking-widest">Server Time</p>
                    <p class="font-bold text-slate-700"><%= lastLogin %></p>
                </div>
            </header>

            <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-10">
                <div class="interactive-card bg-white p-8 rounded-[2rem] shadow-sm border border-slate-100">
                    <span class="text-slate-400 font-black uppercase text-[10px] tracking-widest">Registered Clubs</span>
                    <div class="text-blue-600 text-5xl font-black mt-2"><%= totalClubs %></div>
                </div>
                <div class="interactive-card bg-white p-8 rounded-[2rem] shadow-sm border border-slate-100">
                    <span class="text-slate-400 font-black uppercase text-[10px] tracking-widest">Active Events</span>
                    <div class="text-amber-500 text-5xl font-black mt-2"><%= totalEvents %></div>
                </div>
                <div class="interactive-card bg-white p-8 rounded-[2rem] shadow-sm border border-slate-100">
                    <span class="text-slate-400 font-black uppercase text-[10px] tracking-widest">Leave Requests</span>
                    <div class="text-red-500 text-5xl font-black mt-2"><%= pendingLeaves %></div>
                    <% if (pendingLeaves > 0) { %><a href="#leaveSection" class="text-red-400 text-[10px] font-bold mt-4 block uppercase hover:underline">Review Applications ↓</a><% } %>
                </div>
            </div>

            <%-- PENDING LEAVE SECTION --%>
            <% if (pendingLeaves > 0) { %>
            <div id="leaveSection" class="mb-10 bg-white p-8 rounded-[2rem] shadow-sm border border-slate-100">
                <h3 class="text-xl font-black text-slate-800 mb-6 flex items-center tracking-tight">
                    <span class="w-1.5 h-6 bg-red-500 mr-3 rounded-full"></span> Membership Exit Applications
                </h3>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <% for (Object obj : leaveRequests) { Map req = (Map) obj; %>
                    <div class="p-5 bg-slate-50 rounded-2xl border border-slate-100 flex justify-between items-center">
                        <div>
                            <p class="text-sm font-black text-slate-800"><%= req.get("studentName") %></p>
                            <p class="text-[10px] font-bold text-slate-400 uppercase mt-1">Club: <%= req.get("clubName") %></p>
                        </div>
                        <div class="flex gap-2">
                            <form action="MemberController" method="POST">
                                <input type="hidden" name="action" value="approveLeave">
                                <input type="hidden" name="studentId" value="<%= req.get("studentId") %>">
                                <input type="hidden" name="clubId" value="<%= req.get("clubId") %>">
                                <button type="submit" class="bg-blue-600 text-white px-4 py-2 rounded-xl text-[10px] font-black uppercase">Approve</button>
                            </form>
                            <form action="MemberController" method="POST">
                                <input type="hidden" name="action" value="rejectLeave">
                                <input type="hidden" name="studentId" value="<%= req.get("studentId") %>">
                                <input type="hidden" name="clubId" value="<%= req.get("clubId") %>">
                                <button type="submit" class="bg-white border border-slate-200 px-4 py-2 rounded-xl text-[10px] font-black uppercase">Reject</button>
                            </form>
                        </div>
                    </div>
                    <% } %>
                </div>
            </div>
            <% } %>

            <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
                <div class="interactive-card bg-white p-10 rounded-[2.5rem] shadow-sm border border-slate-100">
                    <h3 class="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-10 text-center">Membership Distribution</h3>
                    <div class="h-[300px]"><canvas id="clubChart"></canvas></div>
                </div>
                <div class="interactive-card bg-slate-900 p-10 rounded-[2.5rem] text-white shadow-2xl">
                    <h3 class="text-xl font-black mb-6 flex items-center">
                        <span class="w-1.5 h-6 bg-blue-500 mr-3 rounded-full"></span> Top Contributors
                    </h3>
                    <div class="space-y-4">
                        <% if (topList != null) { for (Object obj : topList) { Map contributor = (Map) obj; %>
                            <div class="flex items-center justify-between p-4 bg-slate-800 rounded-2xl">
                                <span class="font-bold text-sm text-slate-100"><%= contributor.get("name") %></span>
                                <span class="bg-blue-900/50 text-blue-400 px-3 py-1 rounded-full font-black text-[9px] uppercase"><%= contributor.get("count") %> Posts</span>
                            </div>
                        <% } } %>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <script>
        new Chart(document.getElementById('clubChart'), {
            type: 'bar',
            data: {
                labels: [<%= labels.toString() %>],
                datasets: [{
                    label: 'Active Members',
                    data: [<%= dataValues.toString() %>],
                    backgroundColor: '#3b82f6',
                    borderRadius: 12
                }]
            },
            options: { maintainAspectRatio: false, plugins: { legend: { display: false } } }
        });
    </script>
    <!-- Footer -->
<footer class="bg-white border-t border-gray-200 text-gray-500 text-sm text-center py-6">
    <div class="max-w-7xl mx-auto px-4">
        <p>
            &copy; <%= java.time.Year.now() %> University Club Management System. All rights reserved.
        </p>
        <p class="mt-1">Made with ❤️ for university students</p>
    </div>
</footer>

</body>
</html>