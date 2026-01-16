<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, java.sql.*, com.ucms2.db.DBConnection" %>
<%
    if (!"admin".equals(session.getAttribute("userRole"))) { 
        response.sendRedirect("login.jsp"); 
        return; 
    }
    
    String selectedClubId = request.getParameter("clubFilter");
    List members = new ArrayList();
    List allClubs = new ArrayList();
    int totalMemberships = 0;
    Connection conn = null;

    try {
        conn = DBConnection.getConnection();
        
        // 1. Fetch clubs for dropdown
        ResultSet rsClubs = conn.createStatement().executeQuery("SELECT ClubID, ClubName FROM CLUB ORDER BY ClubName ASC");
        while(rsClubs.next()){
            Map c = new HashMap();
            c.put("id", rsClubs.getString("ClubID"));
            c.put("name", rsClubs.getString("ClubName"));
            allClubs.add(c);
        }

        // 2. Global Membership Count (Shows '4' as seen in your screenshot)
        ResultSet rsStat = conn.createStatement().executeQuery("SELECT COUNT(*) FROM CLUB_MEMBERSHIP");
        if(rsStat.next()) totalMemberships = rsStat.getInt(1);

        // 3. Robust SQL logic - FIXED COLUMN NAMES
        String sql;
        PreparedStatement ps;
        
        if(selectedClubId != null && !selectedClubId.trim().isEmpty()) {
            // Filtered View: INNER JOIN ensures only students in that specific club show up
            sql = "SELECT s.StudentID, s.StudentName, s.StudentEmail FROM STUDENT s " +
                  "INNER JOIN CLUB_MEMBERSHIP m ON s.StudentID = m.StudentID " +
                  "WHERE m.ClubID = ? ORDER BY s.StudentName ASC";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, Integer.parseInt(selectedClubId)); // Explicitly parse as INT
        } else {
            // DEFAULT: Show every student who has at least one club membership
            sql = "SELECT DISTINCT s.StudentID, s.StudentName, s.StudentEmail FROM STUDENT s " +
                  "JOIN CLUB_MEMBERSHIP m ON s.StudentID = m.StudentID ORDER BY s.StudentName ASC";
            ps = conn.prepareStatement(sql);
        }
        
        ResultSet rs = ps.executeQuery();
        while(rs.next()){
            Map row = new HashMap();
            row.put("id", rs.getString("StudentID"));
            row.put("name", rs.getString("StudentName"));
            row.put("email", rs.getString("StudentEmail")); // Corrected column name
            members.add(row);
        }
    } catch(Exception e){ 
        e.printStackTrace(); 
    } finally { 
        try { if(conn!=null) conn.close(); } catch(Exception e){} 
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>User Records | UCMS Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="css/styles.css">
    <style>
        .nav-link.active { background: rgba(59, 130, 246, 0.15); border-right: 4px solid #3b82f6; box-shadow: inset 0 0 10px rgba(59, 130, 246, 0.2); color: #fff !important; }
        .interactive-card { transition: all 0.3s ease; }
        .interactive-card:hover { transform: translateY(-5px); border-color: #3b82f6; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(-10px); } to { opacity: 1; transform: translateY(0); } }
        .animate-fadeIn { animation: fadeIn 0.4s ease-out forwards; }
    </style>
</head>
<body class="bg-[#f8fafc]">
    <div class="dashboard-container">
        <nav class="sidebar">
            <a href="index.jsp" class="sidebar-brand">UCMS Admin</a>
            <a href="admin-dashboard.jsp" class="nav-link">📊 Overview</a>
            <a href="clubs.jsp" class="nav-link">🏛️ Manage Clubs</a>
            <a href="events.jsp" class="nav-link">📅 Event Control</a>
            <a href="members.jsp" class="nav-link active">👥 User Records</a>
            <a href="campus-buzz.jsp" class="nav-link">📢 Moderation</a>
            <div style="margin-top: auto;"><a href="logout" class="nav-link text-red-400">🚪 Logout</a></div>
        </nav>

        <main class="main-content">
            <div class="mb-8 grid grid-cols-1 md:grid-cols-3 gap-6">
                <div class="interactive-card bg-white p-6 rounded-3xl border border-slate-100 shadow-sm">
                    <p class="text-[10px] font-black text-slate-400 uppercase tracking-widest leading-none">Global Engagement</p>
                    <p class="text-3xl font-black text-blue-600 mt-2"><%= totalMemberships %></p>
                    <p class="text-[10px] font-bold text-slate-400 mt-1">Total System Memberships</p>
                </div>
                <% if(selectedClubId != null && !selectedClubId.isEmpty() && !members.isEmpty()) { %>
                    <div class="interactive-card bg-white p-6 rounded-3xl border border-blue-100 shadow-sm animate-fadeIn">
                        <p class="text-[10px] font-black text-blue-500 uppercase tracking-widest leading-none">Club Size</p>
                        <p class="text-3xl font-black text-slate-800 mt-2"><%= members.size() %></p>
                        <p class="text-[10px] font-bold text-slate-400 mt-1">Active Members Here</p>
                    </div>
                <% } %>
            </div>

            <header class="flex flex-col xl:flex-row justify-between items-start xl:items-center mb-10 gap-4">
                <div>
                    <h1 class="text-3xl font-black text-[#1e293b]">User Records</h1>
                    <p class="text-slate-500 mt-1">Search or filter students to view transcripts.</p>
                </div>
                
                <div class="flex flex-wrap items-center gap-3">
                    <div class="relative">
                        <span class="absolute inset-y-0 left-3 flex items-center text-slate-400">🔍</span>
                        <input type="text" id="memberSearch" onkeyup="filterTable()" placeholder="Search Name or ID..." 
                               class="bg-white border border-slate-200 pl-10 pr-4 py-2.5 rounded-xl text-sm font-medium outline-none focus:ring-2 focus:ring-blue-500 shadow-sm w-64">
                    </div>

                    <form action="members.jsp" method="GET" class="flex items-center">
                        <select name="clubFilter" onchange="this.form.submit()" 
                                class="bg-white border border-slate-200 px-4 py-2.5 rounded-xl text-sm font-bold text-slate-600 outline-none focus:ring-2 focus:ring-blue-500 shadow-sm">
                            <option value="">All Societies</option>
                            <% for(Object obj : allClubs) { Map c = (Map) obj; %>
                                <option value="<%= c.get("id") %>" <%= String.valueOf(c.get("id")).equals(selectedClubId) ? "selected" : "" %>><%= c.get("name") %></option>
                            <% } %>
                        </select>
                    </form>

                    <a href="ReportController?type=all_members<%= (selectedClubId != null ? "&clubId=" + selectedClubId : "") %>" 
                       class="bg-blue-600 text-white px-6 py-2.5 rounded-xl font-bold shadow-lg hover:scale-105 transition text-sm">
                        📄 Export Visual List
                    </a>
                </div>
            </header>

            <div class="bg-white rounded-[2rem] shadow-sm border border-slate-100 overflow-hidden">
                <table class="w-full text-left" id="membersTable">
                    <thead class="bg-slate-50 border-b border-slate-100">
                        <tr class="text-[10px] font-black text-slate-400 uppercase tracking-widest">
                            <th class="p-6">Student ID</th>
                            <th class="p-6">Full Name</th>
                            <th class="p-6 text-center">Action</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-50">
                        <% if (members.isEmpty()) { %>
                            <tr><td colspan="3" class="p-10 text-center text-slate-400 italic">No students found for this selection.</td></tr>
                        <% } else { %>
                            <% for (Object obj : members) { Map m = (Map) obj; %>
                            <tr class="member-row hover:bg-slate-50 transition-colors">
                                <td class="p-6 font-mono text-xs student-id"><%= m.get("id") %></td>
                                <td class="p-6 font-bold text-slate-700 student-name"><%= m.get("name") %></td>
                                <td class="p-6 text-center">
                                    <a href="ReportController?studentId=<%= m.get("id") %>" 
                                       class="bg-blue-50 text-blue-600 px-5 py-2 rounded-xl text-xs font-black hover:bg-blue-600 hover:text-white transition-all">
                                        View Transcript
                                    </a>
                                </td>
                            </tr>
                            <% } %>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </main>
    </div>

    <script>
        function filterTable() {
            const input = document.getElementById('memberSearch').value.toUpperCase();
            const rows = document.getElementsByClassName('member-row');
            for (let i = 0; i < rows.length; i++) {
                const name = rows[i].querySelector('.student-name').innerText.toUpperCase();
                const id = rows[i].querySelector('.student-id').innerText.toUpperCase();
                rows[i].style.display = (name.includes(input) || id.includes(input)) ? "" : "none";
            }
        }
    </script>
</body>
</html>