<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ucms2.model.Admin, java.util.*, java.sql.*, com.ucms2.db.DBConnection" %>
<%
    // --- DATA HANDLING: INTERNAL FORWARDING ---
    if (request.getAttribute("totalClubs") == null) {
        request.getRequestDispatcher("/AdminDashboardController").forward(request, response);
        return;
    }

    Admin admin = (Admin) session.getAttribute("admin");
    if (admin == null || !"admin".equals(session.getAttribute("userRole"))) {
        response.sendRedirect("login.jsp?error=Unauthorized Access");
        return;
    }

    // --- LAST LOGIN LOGIC ---
    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd MMM yyyy, HH:mm");
    String lastLogin = sdf.format(new java.util.Date());

    // --- CHART DATA PROCESSING ---
    StringBuilder labels = new StringBuilder();
    StringBuilder dataValues = new StringBuilder();
    Connection conn = null;
    try {
        conn = DBConnection.getConnection();
        String sql = "SELECT c.ClubName, COUNT(m.StudentID) as cnt FROM CLUB c " +
                     "LEFT JOIN CLUB_MEMBERSHIP m ON c.ClubID = m.ClubID GROUP BY c.ClubName";
        ResultSet rs = conn.createStatement().executeQuery(sql);
        while(rs.next()) {
            labels.append("'").append(rs.getString("ClubName")).append("',");
            dataValues.append(rs.getInt("cnt")).append(",");
        }
    } catch(Exception e) { e.printStackTrace(); } 
    finally { try { if(conn != null) conn.close(); } catch(Exception e){} }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>UCMS Admin - Overview</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <link rel="stylesheet" href="css/styles.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;800&display=swap" rel="stylesheet">
    <style>
        .nav-link.active {
            background: rgba(59, 130, 246, 0.15);
            border-right: 4px solid #3b82f6;
            box-shadow: inset 0 0 10px rgba(59, 130, 246, 0.2);
            color: #fff !important;
        }
        .interactive-card { transition: all 0.3s ease; }
        .interactive-card:hover { transform: translateY(-5px); border-color: #3b82f6; }
    </style>
</head>
<body class="bg-gray-50">
    <div class="dashboard-container">
        <nav class="sidebar">
            <a href="index.jsp" class="sidebar-brand">UCMS Admin</a>
            <a href="admin-dashboard-data" class="nav-link active">📊 Overview</a>
            <a href="clubs.jsp" class="nav-link">🏛️ Manage Clubs</a>
            <a href="events.jsp" class="nav-link">📅 Event Control</a>
            <a href="members.jsp" class="nav-link">👥 User Records</a>
            <a href="campus-buzz.jsp" class="nav-link">📢 Moderation</a>
            
            <div style="margin-top: auto; padding-top: 2rem; border-top: 1px solid #334155;">
                <p class="text-[9px] text-slate-500 mb-1 uppercase font-bold tracking-widest">Administrator</p>
                <p class="text-sm font-bold text-white mb-1"><%= admin.getAdminName() %></p>
                <p class="text-[9px] text-slate-400 italic mb-4">Last active: <%= lastLogin %></p>
                <a href="logout" class="nav-link" style="color: #ef4444; background: rgba(239, 68, 68, 0.1);">🚪 Logout</a>
            </div>
        </nav>

        <main class="main-content">
            <header class="mb-10">
                <h1 class="text-3xl font-black text-slate-800">System Overview</h1>
                <p class="text-slate-500 mt-1">Real-time statistics for the University Club Management Society.</p>
            </header>

            <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-10">
                <div class="interactive-card bg-white p-6 rounded-3xl shadow-sm border border-slate-100">
                    <span class="text-slate-400 font-bold uppercase text-[10px] tracking-widest">Registered Clubs</span>
                    <div class="text-blue-600 text-4xl font-black mt-2"><%= request.getAttribute("totalClubs") %></div>
                </div>
                <div class="interactive-card bg-white p-6 rounded-3xl shadow-sm border border-slate-100">
                    <span class="text-slate-400 font-bold uppercase text-[10px] tracking-widest">Active Events</span>
                    <div class="text-amber-500 text-4xl font-black mt-2"><%= request.getAttribute("totalEvents") %></div>
                </div>
                <div class="interactive-card bg-white p-6 rounded-3xl shadow-sm border border-slate-100">
                    <span class="text-slate-400 font-bold uppercase text-[10px] tracking-widest">System Status</span>
                    <div class="flex items-center mt-4">
                        <span class="h-3 w-3 bg-emerald-500 rounded-full animate-pulse mr-2"></span>
                        <span class="text-emerald-600 font-bold uppercase text-xs tracking-wider">Online</span>
                    </div>
                </div>
            </div>

            <div class="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-10">
                <div class="interactive-card bg-white p-8 rounded-[2rem] shadow-sm border border-slate-100">
                    <h3 class="text-xs font-black text-slate-400 uppercase tracking-widest mb-6 text-center">Membership Distribution</h3>
                    <div class="h-[250px] flex items-center justify-center">
                        <canvas id="clubChart"></canvas>
                    </div>
                </div>

                <div class="interactive-card bg-white p-8 rounded-[2rem] shadow-sm border border-slate-200">
                    <h3 class="text-lg font-extrabold text-slate-800 mb-6 flex items-center">
                        <span class="w-1.5 h-6 bg-amber-500 mr-3 rounded-full"></span> Top Informants
                    </h3>
                    <div class="overflow-x-auto">
                        <table class="w-full text-left">
                            <tbody class="divide-y divide-slate-50">
                                <% List<Map<String, String>> topList = (List<Map<String, String>>) request.getAttribute("topContributors");
                                   if (topList != null && !topList.isEmpty()) { 
                                       for (Map<String, String> contributor : topList) { %>
                                    <tr class="group hover:bg-slate-50 transition-colors">
                                        <td class="py-4 font-bold text-slate-700"><%= contributor.get("name") %></td>
                                        <td class="py-4 text-right">
                                            <span class="bg-amber-100 text-amber-700 px-3 py-1 rounded-full text-xs font-black">
                                                <%= contributor.get("count") %> Posts
                                            </span>
                                        </td>
                                    </tr>
                                <% } } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <div class="bg-white p-8 rounded-[2rem] shadow-sm border border-slate-200">
                <h3 class="text-lg font-extrabold text-slate-700 mb-6 flex items-center">
                    <span class="w-1.5 h-6 bg-blue-600 mr-3 rounded-full"></span> Actions
                </h3>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <a href="clubs.jsp?action=add" class="p-6 border border-slate-100 rounded-2xl hover:bg-slate-50 transition flex items-center justify-between group bg-slate-50/50">
                        <div>
                            <p class="font-bold text-slate-800 text-lg">New Club</p>
                            <p class="text-xs text-slate-500">Add society to directory.</p>
                        </div>
                        <span class="text-2xl group-hover:translate-x-1 transition-transform">🏛️</span>
                    </a>
                    <a href="events.jsp?action=add" class="p-6 border border-slate-100 rounded-2xl hover:bg-slate-50 transition flex items-center justify-between group bg-slate-50/50">
                        <div>
                            <p class="font-bold text-slate-800 text-lg">New Event</p>
                            <p class="text-xs text-slate-500">Create student activities.</p>
                        </div>
                        <span class="text-2xl group-hover:translate-x-1 transition-transform">📅</span>
                    </a>
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
                    borderRadius: 8
                }]
            },
            options: { 
                maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: { 
                    y: { beginAtZero: true, grid: { display: false }, ticks: { font: { size: 10 } } }, 
                    x: { grid: { display: false }, ticks: { font: { size: 10 } } } 
                }
            }
        });
    </script>
</body>
</html>