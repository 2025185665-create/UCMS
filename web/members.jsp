<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, java.sql.*, com.ucms2.db.DBConnection" %>
<%
    if (!"admin".equals(session.getAttribute("userRole"))) { 
        response.sendRedirect("login.jsp"); 
        return; 
    }

    String viewStudentId = request.getParameter("studentId"); // For Transcript View
    List sessionMembers = (List) session.getAttribute("members");
    
    if (sessionMembers == null && viewStudentId == null) {
        response.sendRedirect("MemberController");
        return;
    }
    
    String selectedClubId = request.getParameter("clubFilter");
    List filteredMembers = new ArrayList();
    List allClubs = new ArrayList();
    int totalMemberships = 0;
    Connection conn = null;

    try {
        conn = DBConnection.getConnection();
        ResultSet rsClubs = conn.createStatement().executeQuery("SELECT ClubID, ClubName FROM CLUB ORDER BY ClubName ASC");
        while(rsClubs.next()){
            Map c = new HashMap();
            c.put("id", rsClubs.getString("ClubID"));
            c.put("name", rsClubs.getString("ClubName"));
            allClubs.add(c);
        }
        ResultSet rsStat = conn.createStatement().executeQuery("SELECT COUNT(*) FROM CLUB_MEMBERSHIP");
        if(rsStat.next()) totalMemberships = rsStat.getInt(1);

        if(viewStudentId == null) {
            String sql;
            PreparedStatement ps;
            if(selectedClubId != null && !selectedClubId.trim().isEmpty()) {
                sql = "SELECT s.StudentID, s.StudentName, s.StudentEmail FROM STUDENT s " +
                      "INNER JOIN CLUB_MEMBERSHIP m ON s.StudentID = m.StudentID " +
                      "WHERE m.ClubID = ? AND m.Status = 'active' ORDER BY s.StudentName ASC";
                ps = conn.prepareStatement(sql);
                ps.setInt(1, Integer.parseInt(selectedClubId));
            } else {
                sql = "SELECT DISTINCT s.StudentID, s.StudentName, s.StudentEmail FROM STUDENT s " +
                      "JOIN CLUB_MEMBERSHIP m ON s.StudentID = m.StudentID WHERE m.Status = 'active' ORDER BY s.StudentName ASC";
                ps = conn.prepareStatement(sql);
            }
            ResultSet rs = ps.executeQuery();
            while(rs.next()){
                Map row = new HashMap();
                row.put("id", rs.getString("StudentID"));
                row.put("name", rs.getString("StudentName"));
                row.put("email", rs.getString("StudentEmail"));
                filteredMembers.add(row);
            }
        }
    } catch(Exception e){ e.printStackTrace(); } 
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>User Records | UCMS Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="css/styles.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;800&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; }
        .nav-link.active { background: rgba(59, 130, 246, 0.15); border-right: 4px solid #3b82f6; color: #fff !important; }
    </style>
</head>
<body class="bg-[#f8fafc]">
    <div class="dashboard-container">
        <nav class="sidebar">
            <a href="index.jsp" class="sidebar-brand flex items-center gap-3">
         <img src="<%= request.getContextPath() %>/img/ucms_logo.png"
         alt="UCMS Logo"
         class="h-10 w-auto">
         <span class="text-2xl font-black tracking-tighter text-blue-400">Admin</span></a>
            <a href="AdminDashboardController" class="nav-link">🏠 Dashboard</a>
            <a href="ClubController" class="nav-link">🏛️ Manage Clubs</a>
            <a href="EventController" class="nav-link">📅 Event Control</a>
            <a href="MemberController" class="nav-link active">👥 User Records</a>
            <div style="margin-top: auto;"><a href="logout" class="nav-link text-red-400 font-bold">🚪 Logout</a></div>
        </nav>

        <main class="main-content p-10">

            <% if (viewStudentId != null) { 
                // --- STUDENT TRANSCRIPT VIEW LOGIC ---
                Map studentInfo = new HashMap();
                List myClubs = new ArrayList();
                List myEvents = new ArrayList();
                try {
                    PreparedStatement psS = conn.prepareStatement("SELECT * FROM STUDENT WHERE StudentID = ?");
                    psS.setString(1, viewStudentId);
                    ResultSet rsS = psS.executeQuery();
                    if(rsS.next()) {
                        studentInfo.put("name", rsS.getString("StudentName"));
                        studentInfo.put("id", rsS.getString("StudentID"));
                    }

                    PreparedStatement psC = conn.prepareStatement("SELECT c.ClubName, m.JoinDate FROM CLUB_MEMBERSHIP m JOIN CLUB c ON m.ClubID = c.ClubID WHERE m.StudentID = ? AND m.Status = 'active'");
                    psC.setString(1, viewStudentId);
                    ResultSet rsC = psC.executeQuery();
                    while(rsC.next()) {
                        Map c = new HashMap();
                        c.put("name", rsC.getString("ClubName"));
                        c.put("date", rsC.getString("JoinDate"));
                        myClubs.add(c);
                    }
                } catch(Exception e) {}
            %>
                <div class="max-w-4xl mx-auto animate-fade">
                    <div class="flex justify-between items-center mb-8">
                        <a href="members.jsp" class="text-slate-400 font-bold text-xs uppercase tracking-widest hover:text-blue-600">← Back to Records</a>
                        <button onclick="window.print()" class="bg-blue-600 text-white px-6 py-2 rounded-xl font-black text-[10px] uppercase tracking-widest shadow-lg">Print Transcript</button>
                    </div>

                    <div class="bg-white p-12 rounded-[3rem] shadow-xl border border-slate-100">
                        <div class="border-b-4 border-slate-900 pb-6 mb-8">
                            <h2 class="text-4xl font-black text-slate-800 tracking-tighter uppercase">Activity Transcript</h2>
                            <p class="text-slate-400 font-bold text-sm tracking-widest mt-1">OFFICIAL UNIVERSITY RECORD</p>
                        </div>

                        <div class="grid grid-cols-2 gap-8 mb-12">
                            <div>
                                <p class="text-[10px] font-black text-slate-400 uppercase tracking-widest">Student Name</p>
                                <p class="text-xl font-bold text-slate-800"><%= studentInfo.get("name") %></p>
                            </div>
                            <div>
                                <p class="text-[10px] font-black text-slate-400 uppercase tracking-widest">Student ID</p>
                                <p class="text-xl font-bold text-slate-800"><%= studentInfo.get("id") %></p>
                            </div>
                        </div>

                        <h3 class="text-lg font-black text-slate-800 mb-4 border-l-4 border-blue-500 pl-4 uppercase tracking-tight">Society Memberships</h3>
                        <table class="w-full mb-12">
                            <tr class="text-left text-[10px] font-black text-slate-400 uppercase border-b">
                                <th class="py-4">Organization Name</th>
                                <th class="py-4">Status</th>
                                <th class="py-4 text-right">Join Date</th>
                            </tr>
                            <% for(Object obj : myClubs) { Map c = (Map) obj; %>
                                <tr class="border-b border-slate-50">
                                    <td class="py-4 font-bold text-slate-700"><%= c.get("name") %></td>
                                    <td class="py-4"><span class="bg-emerald-50 text-emerald-600 text-[10px] font-black px-3 py-1 rounded-full uppercase">Active</span></td>
                                    <td class="py-4 text-right text-slate-500 font-mono text-xs"><%= c.get("date") %></td>
                                </tr>
                            <% } %>
                            <% if(myClubs.isEmpty()){ %> <tr><td colspan="3" class="py-6 text-slate-400 italic">No active memberships found.</td></tr> <% } %>
                        </table>
                    </div>
                </div>

            <% } else { %>
                <%-- ORIGINAL TABLE VIEW --%>
                <header class="flex flex-col xl:flex-row justify-between items-start xl:items-center mb-10 gap-4">
                    <div>
                        <h1 class="text-3xl font-black text-[#1e293b] tracking-tighter">User Records</h1>
                        <p class="text-slate-500 mt-1">Review student involvement and official transcripts.</p>
                    </div>
                    <div class="flex flex-wrap items-center gap-3">
                        <form action="members.jsp" method="GET" class="flex items-center">
                            <select name="clubFilter" onchange="this.form.submit()" 
                                    class="bg-white border border-slate-200 px-4 py-2.5 rounded-xl text-sm font-bold text-slate-600 shadow-sm outline-none">
                                <option value="">All Societies</option>
                                <% for(Object obj : allClubs) { Map c = (Map) obj; %>
                                    <option value="<%= c.get("id") %>" <%= String.valueOf(c.get("id")).equals(selectedClubId) ? "selected" : "" %>><%= c.get("name") %></option>
                                <% } %>
                            </select>
                        </form>
                    </div>
                </header>

                <div class="bg-white rounded-[2rem] shadow-sm border border-slate-100 overflow-hidden">
                    <table class="w-full text-left" id="membersTable">
                        <thead class="bg-slate-50 border-b border-slate-100">
                            <tr class="text-[10px] font-black text-slate-400 uppercase tracking-widest">
                                <th class="p-6">Student ID</th>
                                <th class="p-6">Full Name</th>
                                <th class="p-6 text-center">Transcript</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-50">
                            <% for (Object obj : filteredMembers) { Map m = (Map) obj; %>
                            <tr class="member-row hover:bg-slate-50 transition-colors group">
                                <td class="p-6 font-mono text-xs font-bold text-blue-600 student-id"><%= m.get("id") %></td>
                                <td class="p-6 font-bold text-slate-700 student-name"><%= m.get("name") %></td>
                            <td class="p-6 text-center">
                                <a href="MemberController?studentId=<%= m.get("id") %>" 
                                   class="inline-block bg-white border border-slate-200 text-slate-600 px-4 py-1.5 rounded-lg text-[10px] font-black uppercase hover:bg-slate-900 hover:text-white transition-all">
                                    View Transcript
                                </a>
                            </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>
        </main>
    </div>
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
<% if(conn != null) try { conn.close(); } catch(Exception e) {} %>