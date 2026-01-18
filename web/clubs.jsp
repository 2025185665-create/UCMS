<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, java.sql.*, com.ucms2.db.DBConnection, com.ucms2.model.Club, com.ucms2.model.Admin, com.ucms2.model.Student" %>
<%
    if (request.getAttribute("clubList") == null && request.getAttribute("club") == null && !"add".equals(request.getParameter("action"))) {
        request.getRequestDispatcher("/ClubController").forward(request, response);
        return;
    }

    String userRole = (String) session.getAttribute("userRole");
    Student student = (Student) session.getAttribute("student");
    Integer pendingBuzzCount = (Integer) session.getAttribute("pendingBuzzCount");
    if (pendingBuzzCount == null) {
    pendingBuzzCount = 0;
    }
    List clubs = (List) request.getAttribute("clubList");
    Club editClub = (Club) request.getAttribute("club");
    String action = request.getParameter("action");
    String searchTerm = request.getParameter("search");

    // Logic: Prevent Double Club Entry / Track Membership
    Map membershipMap = new HashMap(); 
    if (student != null) {
        Connection connM = null; PreparedStatement psM = null; ResultSet rsM = null;
        try {
            connM = DBConnection.getConnection();
            psM = connM.prepareStatement("SELECT ClubID, Status FROM CLUB_MEMBERSHIP WHERE StudentID = ?");
            psM.setString(1, student.getStudentId());
            rsM = psM.executeQuery();
            while(rsM.next()){ 
                membershipMap.put(new Integer(rsM.getInt(1)), rsM.getString(2)); 
            }
        } catch(Exception e){ e.printStackTrace(); } 
        finally { 
            if(rsM!=null) try{rsM.close();}catch(Exception e){} 
            if(psM!=null) try{psM.close();}catch(Exception e){} 
            if(connM!=null) try{connM.close();}catch(Exception e){} 
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>Societies Management | UCMS</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="css/styles.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;700;800&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif !important; }
        .nav-link.active { background: rgba(59, 130, 246, 0.15); border-right: 4px solid #3b82f6; color: #fff !important; }
        #toast { transition: opacity 0.5s ease-out; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
        .animate-fade { animation: fadeIn 0.3s ease-out forwards; }
    </style>
</head>
<body class="bg-slate-50 font-['Inter']">

    <%-- Success & Error Toast Notifications --%>
    <% if (request.getParameter("success") != null) { 
        String msg = request.getParameter("success");
        boolean isError = msg.toLowerCase().contains("error") || msg.toLowerCase().contains("fail");
    %>
    <div id="toast" class="fixed top-5 right-5 z-50 <%= isError ? "bg-red-500" : "bg-emerald-500" %> text-white px-8 py-4 rounded-2xl shadow-2xl flex items-center animate-bounce">
        <span class="mr-3"><%= isError ? "⚠️" : "✨" %></span>
        <p class="font-bold text-sm tracking-tight"><%= msg %></p>
    </div>
    <script>setTimeout(function(){ var t = document.getElementById('toast'); if(t){ t.style.opacity='0'; setTimeout(function(){t.remove()}, 500); }}, 5000);</script>
    <% } %>

    <div class="dashboard-container">
        <nav class="sidebar">
            <a href="index.jsp" class="sidebar-brand flex items-center gap-3">
            <img src="<%= request.getContextPath() %>/img/ucms_logo.png"
            alt="UCMS Logo"
            class="h-10 w-auto">
            <span class="text-2xl font-black tracking-tighter text-blue-400">Clubs</span></a>
            <% if ("admin".equals(userRole)) { %>
                <a href="admin-dashboard.jsp" class="nav-link">🏠 Dashboard</a>
                <a href="clubs.jsp" class="nav-link active">🏛️ Manage Clubs</a>
                <a href="events.jsp" class="nav-link">📅 Event Control</a>
                <a href="members.jsp" class="nav-link">👥 User Records</a>
                <a href="campus-buzz.jsp" class="nav-link relative flex items-center justify-between">
    <span>📢 Campus Buzz</span>

    <% if (pendingBuzzCount > 0) { %>
        <span class="inline-flex h-5 w-5 rounded-full bg-red-500 text-white text-[10px] font-black items-center justify-center animate-bounce">
            <%= pendingBuzzCount %>
        </span>
    <% } %>
</a>

            <% } else { %>
                <a href="student-dashboard.jsp" class="nav-link">🏠 Dashboard</a>
                <a href="my-output.jsp" class="nav-link ">📊 My Progress</a>
                <a href="clubs.jsp" class="nav-link active">🔍 Explore Clubs</a>
                <a href="events.jsp" class="nav-link">📅 Campus Events</a>
                <a href="campus-buzz.jsp" class="nav-link">📢 Campus Buzz</a>
            <% } %>
            <div style="margin-top: auto;"><a href="logout" class="nav-link text-red-400 font-bold">🚪 Logout</a></div>
        </nav>

        <main class="main-content p-10">
    
        <%-- 1. EDIT CLUB FORM  --%>
        <% if ("edit".equals(action) && "admin".equals(userRole) && editClub != null) { %>
            <div class="max-w-3xl mx-auto bg-white p-12 rounded-[2.5rem] border shadow-2xl animate-fade">
                <h2 class="text-3xl font-black text-slate-800 mb-2 tracking-tight">Update Society Profile</h2>
                <p class="text-slate-400 font-bold mb-8 text-xs uppercase tracking-widest">Editing: <%= editClub.getClubName() %></p>

                <form action="ClubController" method="POST" class="space-y-8">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="clubId" value="<%= editClub.getClubId() %>">

                    <div>
                        <label class="block text-[11px] font-black text-slate-500 uppercase tracking-widest mb-3 ml-1">Society Name</label>
                        <input type="text" name="clubName" value="<%= editClub.getClubName() %>" required 
                               class="w-full p-5 bg-slate-50 border border-slate-200 rounded-2xl outline-none font-bold text-slate-700 text-lg focus:ring-4 focus:ring-blue-50 transition-all">
                    </div>

                    <div>
                        <label class="block text-[11px] font-black text-slate-500 uppercase tracking-widest mb-3 ml-1">Purpose & Description</label>
                        <textarea name="clubDescription" required 
                                  class="w-full p-5 bg-slate-50 border border-slate-200 rounded-2xl outline-none h-48 font-medium text-slate-600 focus:ring-4 focus:ring-blue-50 transition-all"><%= editClub.getClubDescription() %></textarea>
                    </div>

                    <div class="flex gap-4 pt-4">
                        <button type="submit" class="flex-1 bg-slate-900 text-white py-5 rounded-2xl font-black text-xs uppercase tracking-widest hover:bg-blue-600 transition shadow-xl">Save Changes</button>
                        <a href="ClubController" class="px-12 bg-slate-100 text-slate-500 py-5 rounded-2xl font-black flex items-center uppercase text-[10px] tracking-widest">Cancel</a>
                    </div>
                </form>
            </div>

        <%-- 2. ADD CLUB FORM --%>
        <% } else if ("add".equals(action) && "admin".equals(userRole)) { %>
            <div class="max-w-3xl mx-auto bg-white p-12 rounded-[2.5rem] border shadow-2xl animate-fade">
                <h2 class="text-3xl font-black text-slate-800 mb-8 tracking-tight italic">Establish New Society</h2>
                <form action="ClubController" method="POST" class="space-y-8">
                    <input type="hidden" name="action" value="create">
                    <div>
                        <label class="block text-[11px] font-black text-slate-500 uppercase tracking-widest mb-3 ml-1">Society Name</label>
                        <input type="text" name="clubName" required class="w-full p-5 bg-slate-50 border border-slate-200 rounded-2xl outline-none font-bold text-slate-700 text-lg focus:ring-4 focus:ring-blue-50 transition-all">
                    </div>
                    <div>
                        <label class="block text-[11px] font-black text-slate-500 uppercase tracking-widest mb-3 ml-1">Purpose & Description</label>
                        <textarea name="clubDescription" required class="w-full p-5 bg-slate-50 border border-slate-200 rounded-2xl outline-none h-48 font-medium text-slate-600 focus:ring-4 focus:ring-blue-50 transition-all"></textarea>
                    </div>
                    <div class="flex gap-4 pt-4">
                        <button type="submit" class="flex-1 bg-slate-900 text-white py-5 rounded-2xl font-black text-xs uppercase tracking-widest hover:bg-blue-600 transition shadow-xl">Establish Society</button>
                        <a href="ClubController" class="px-12 bg-slate-100 text-slate-500 py-5 rounded-2xl font-black flex items-center uppercase text-[10px] tracking-widest">Cancel</a>
                    </div>
                </form>
            </div>

        <%-- 3. DIRECTORY VIEW --%>
        <% } else if (clubs != null) { %>
            <%-- CLUBS DIRECTORY VIEW --%>
            <header class="flex flex-col md:flex-row justify-between items-end mb-12 gap-8">
                <div>
                    <h1 class="text-5xl font-black text-slate-800 tracking-tighter italic">Societies Directory</h1>
                    <p class="text-slate-400 font-bold mt-2 text-sm uppercase tracking-widest">Official Campus Organizations</p>
                </div>
                
                <div class="flex items-center gap-4">
                    <%-- SEARCH FORM --%>
                    <form action="ClubController" method="GET" class="relative group">
                        <input type="text" name="search" value="<%= (searchTerm != null) ? searchTerm : "" %>" 
                               placeholder="Search societies..." 
                               class="bg-white border-2 border-slate-100 pl-6 pr-14 py-4 rounded-2xl text-sm outline-none w-80 shadow-sm font-bold text-slate-700 focus:border-blue-500 transition-all">
                        <button type="submit" class="absolute right-5 top-4 text-slate-300 group-hover:text-blue-500 transition-colors text-lg">🔍</button>
                    </form>

                    <%-- FUNCTIONAL CLEAR BUTTON --%>
                    <% if (searchTerm != null && !searchTerm.isEmpty()) { %>
                        <a href="clubs.jsp" class="bg-red-50 text-red-500 p-4 rounded-2xl font-black text-[10px] uppercase tracking-widest hover:bg-red-500 hover:text-white transition-all shadow-sm">
                            ✕ Clear
                        </a>
                    <% } %>

                    <% if ("admin".equals(userRole)) { %>
                        <a href="ClubController?action=add" class="bg-blue-600 text-white px-8 py-4 rounded-2xl font-black shadow-xl shadow-blue-100 text-[11px] uppercase tracking-widest hover:bg-slate-900 transition-all">
                            Establish New Club
                        </a>
                    <% } %>
                </div>
            </header>

            <div class="bg-white rounded-[3rem] border border-slate-100 shadow-xl overflow-hidden">
                <table class="w-full text-left">
                    <thead class="bg-slate-50/50 border-b border-slate-100">
                        <tr class="text-[12px] font-black text-slate-400 uppercase tracking-[0.2em]">
                            <th class="p-10">Identity</th>
                            <th class="p-10">Manifesto</th>
                            <th class="p-10 text-center">Engagement</th>
                            <th class="p-10 text-center">Action</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-50">
                        <% if(clubs.isEmpty()) { %>
                            <tr>
                                <td colspan="4" class="p-20 text-center text-slate-400 font-bold italic uppercase tracking-widest">No societies found matching your criteria.</td>
                            </tr>
                        <% } %>
                        <% for (Object obj : clubs) { 
                            Map c = (Map) obj; 
                            Integer cid = (Integer) c.get("id");
                            int count = ((Integer)c.get("count")).intValue();
                            String mStatus = (String) membershipMap.get(cid);
                        %>
                        <tr class="hover:bg-slate-50/50 transition-all group">
                            <td class="p-10 font-black text-slate-800 text-xl tracking-tight"><%= c.get("name") %></td>
                            <td class="p-10 text-sm text-slate-500 font-medium leading-relaxed max-w-sm italic opacity-80 group-hover:opacity-100 transition-opacity">
                                <%= c.get("desc") %>
                            </td>
                            <td class="p-10 text-center">
                                <span class="inline-block bg-blue-50 text-blue-600 px-5 py-2 rounded-full text-[11px] font-black uppercase tracking-widest">
                                    <%= count %> Members
                                </span>
                            </td>
                            <td class="p-10">
                                <div class="flex gap-4 justify-center items-center">
                                    <% if ("admin".equals(userRole)) { %>
                                        <a href="ClubController?action=edit&clubId=<%= cid %>" class="text-blue-600 font-black text-[11px] uppercase tracking-widest hover:underline">Update</a>
                                        <% if (count > 0) { %>
                                            <span title="Society has active members" class="text-slate-200 font-black text-[11px] uppercase tracking-widest cursor-not-allowed">Delete 🔒</span>
                                        <% } else { %>
                                            <form action="ClubController" method="POST" onsubmit="return confirm('Permanently dissolve this society?')">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="clubId" value="<%= cid %>">
                                                <button type="submit" class="text-red-400 font-black text-[11px] uppercase tracking-widest hover:text-red-600">Dissolve</button>
                                            </form>
                                        <% } %>
                                    <% } else { %>
                                        <%-- STUDENT ACTION BUTTONS --%>
                                        <% if ("active".equals(mStatus)) { %>
                                            <form action="ClubController" method="POST">
                                                <input type="hidden" name="action" value="leave">
                                                <input type="hidden" name="clubId" value="<%= cid %>">
                                                <button type="submit" class="text-red-500 font-black border-2 border-red-100 px-8 py-3 rounded-2xl text-[10px] uppercase hover:bg-red-500 hover:text-white transition-all">Leave Society</button>
                                            </form>
                                        <% } else if ("leave_pending".equals(mStatus)) { %>
                                            <span class="text-amber-500 font-black text-[10px] uppercase border-2 border-amber-50 px-8 py-3 rounded-2xl bg-amber-50/30">Exit Pending...</span>
                                        <% } else { %>
                                            <form action="ClubController" method="POST">
                                                <input type="hidden" name="action" value="join">
                                                <input type="hidden" name="clubId" value="<%= cid %>">
                                                <button type="submit" class="bg-slate-900 text-white px-10 py-3.5 rounded-2xl font-black text-[10px] shadow-lg hover:bg-blue-600 transition-all uppercase tracking-widest">Join Society</button>
                                            </form>
                                        <% } %>
                                    <% } %>
                                </div>
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