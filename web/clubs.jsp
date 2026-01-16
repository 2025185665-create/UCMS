<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.ucms2.model.Club, com.ucms2.model.Admin, com.ucms2.model.Student" %>
<%
    // --- LECTURER REQUIREMENT: INTERNAL FORWARDING ---
    // If no data and not in "add" mode, call the Servlet internally
    if (request.getAttribute("clubList") == null && request.getAttribute("club") == null && !"add".equals(request.getParameter("action"))) {
        request.getRequestDispatcher("/ClubController").forward(request, response);
        return;
    }

    String userRole = (String) session.getAttribute("userRole");
    Student student = (Student) session.getAttribute("student");
    List clubs = (List) request.getAttribute("clubList");
    Club editClub = (Club) request.getAttribute("club");
    String action = request.getParameter("action");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>Clubs Management | UCMS</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="css/styles.css">
</head>
<body class="bg-slate-50">
    <div class="dashboard-container">
        <nav class="sidebar">
            <a href="index.jsp" class="sidebar-brand">UCMS</a>
            <% if ("admin".equals(userRole)) { %>
                <a href="admin-dashboard-data" class="nav-link">📊 Overview</a>
                <a href="clubs.jsp" class="nav-link active">🏛️ Manage Clubs</a>
                <a href="events.jsp" class="nav-link">📅 Events</a>
                <a href="members.jsp" class="nav-link">👥 Members</a>
            <% } else { %>
                <a href="student-dashboard.jsp" class="nav-link">🏠 Dashboard</a>
                <a href="clubs.jsp" class="nav-link active">🔍 Explore Clubs</a>
                <a href="events.jsp" class="nav-link">📅 Events</a>
                <a href="my-output.jsp" class="nav-link">👤 Profile</a>
            <% } %>
            <div style="margin-top: auto;"><a href="logout" class="nav-link" style="color: #ef4444;">🚪 Logout</a></div>
        </nav>

        <main class="main-content">
            <%-- ALERT MESSAGES --%>
            <% if (request.getParameter("success") != null) { %>
                <div class="bg-emerald-100 text-emerald-700 p-4 rounded-2xl mb-6 font-bold text-sm">✅ <%= request.getParameter("success") %></div>
            <% } %>

            <%-- MODE 1: ADD CLUB FORM --%>
            <% if ("add".equals(action) && "admin".equals(userRole)) { %>
                <div class="max-w-2xl mx-auto bg-white p-8 rounded-3xl border shadow-sm">
                    <h2 class="text-2xl font-black mb-6">Register New Club</h2>
                    <form action="ClubController" method="POST" class="space-y-6">
                        <input type="hidden" name="action" value="create">
                        <div>
                            <label class="block text-xs font-black text-slate-500 uppercase mb-2">Club Name</label>
                            <input type="text" name="clubName" required class="w-full p-3 bg-slate-50 border rounded-xl outline-none focus:ring-2 focus:ring-blue-500">
                        </div>
                        <div>
                            <label class="block text-xs font-black text-slate-500 uppercase mb-2">Description</label>
                            <textarea name="clubDescription" required class="w-full p-3 bg-slate-50 border rounded-xl outline-none h-32 focus:ring-2 focus:ring-blue-500"></textarea>
                        </div>
                        <button type="submit" class="w-full bg-slate-800 text-white py-4 rounded-2xl font-bold hover:bg-slate-700 transition">Create Society</button>
                    </form>
                </div>

            <%-- MODE 2: EDIT CLUB FORM --%>
            <% } else if ("edit".equals(action) && editClub != null && "admin".equals(userRole)) { %>
                <div class="max-w-2xl mx-auto bg-white p-8 rounded-3xl border shadow-sm">
                    <h2 class="text-2xl font-black mb-6">Edit Club: <%= editClub.getClubName() %></h2>
                    <form action="ClubController" method="POST" class="space-y-6">
                        <input type="hidden" name="action" value="update">
                        <input type="hidden" name="clubId" value="<%= editClub.getClubId() %>">
                        <div>
                            <label class="block text-xs font-black text-slate-500 uppercase mb-2">Club Name</label>
                            <input type="text" name="clubName" value="<%= editClub.getClubName() %>" required class="w-full p-3 border rounded-xl">
                        </div>
                        <div>
                            <label class="block text-xs font-black text-slate-500 uppercase mb-2">Description</label>
                            <textarea name="clubDescription" required class="w-full p-3 border rounded-xl h-32"><%= editClub.getClubDescription() %></textarea>
                        </div>
                        <div class="flex gap-4">
                            <button type="submit" class="flex-1 bg-blue-600 text-white py-4 rounded-2xl font-bold">Save Changes</button>
                            <a href="clubs.jsp" class="px-8 bg-slate-100 py-4 rounded-2xl font-bold">Cancel</a>
                        </div>
                    </form>
                </div>

            <%-- MODE 3: LIST VIEW --%>
            <% } else if (clubs != null) { %>
                <header class="flex justify-between items-center mb-10">
                    <h1 class="text-3xl font-black text-slate-800"><%= "admin".equals(userRole) ? "Clubs Directory" : "Explore Societies" %></h1>
                    <% if ("admin".equals(userRole)) { %>
                        <a href="clubs.jsp?action=add" class="btn-primary">+ New Club</a>
                    <% } %>
                </header>

                <div class="data-table-container">
                    <table class="ucms-table">
                        <thead><tr><th>Club Details</th><th>Description</th><th class="text-center">Action</th></tr></thead>
                        <tbody>
                            <% for (Object obj : clubs) { Club c = (Club) obj; %>
                            <tr>
                                <td class="font-bold"><%= c.getClubName() %></td>
                                <td class="text-sm text-slate-500"><%= c.getClubDescription() %></td>
                                <td class="text-center">
                                    <% if ("admin".equals(userRole)) { %>
                                        <div class="flex gap-4 justify-center">
                                            <a href="ClubController?action=edit&clubId=<%= c.getClubId() %>" class="text-blue-600 font-bold">Edit</a>
                                            <form action="ClubController" method="POST" onsubmit="return confirm('Delete this club?')">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="clubId" value="<%= c.getClubId() %>">
                                                <button type="submit" class="text-red-500 font-bold">Delete</button>
                                            </form>
                                        </div>
                                    <% } else { 
                                        com.ucms2.db.ClubDAO dao = new com.ucms2.db.ClubDAO();
                                        if (dao.isMember(student.getStudentId(), c.getClubId())) { %>
                                            <form action="ClubController" method="POST">
                                                <input type="hidden" name="action" value="leave"><input type="hidden" name="clubId" value="<%= c.getClubId() %>">
                                                <button type="submit" class="text-red-500 font-bold border border-red-200 px-4 py-1 rounded-lg">Leave</button>
                                            </form>
                                        <% } else { %>
                                            <form action="ClubController" method="POST">
                                                <input type="hidden" name="action" value="join"><input type="hidden" name="clubId" value="<%= c.getClubId() %>">
                                                <button type="submit" class="bg-blue-600 text-white px-6 py-2 rounded-xl font-bold">Join</button>
                                            </form>
                                    <% } } %>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>
        </main>
    </div>
</body>
</html>