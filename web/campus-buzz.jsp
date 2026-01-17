<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ucms2.model.Student, com.ucms2.model.Admin, com.ucms2.model.CampusBuzz, java.util.*, java.sql.*" %>
<%
    if (request.getAttribute("approvedBuzz") == null) {
        request.getRequestDispatcher("/CampusBuzzController").forward(request, response);
        return; 
    }
    String userRole = (String) session.getAttribute("userRole");
    Student student = (Student) session.getAttribute("student");
    List pending = (List) request.getAttribute("pendingBuzz");
    List approved = (List) request.getAttribute("approvedBuzz");
    if (approved == null) approved = new ArrayList();

    // ADD: Student's own posts
    List myBuzz = (List) request.getAttribute("myBuzz");
    if (myBuzz == null) myBuzz = new ArrayList();

    String successParam = request.getParameter("success");

    // Fetch Leave Count for Sidebar
    int leafCount = 0;
    Connection connC = null; 
    Statement stmtC = null; 
    ResultSet rsC = null;
    try {
        connC = com.ucms2.db.DBConnection.getConnection();
        stmtC = connC.createStatement();
        rsC = stmtC.executeQuery("SELECT COUNT(*) FROM CLUB_MEMBERSHIP WHERE Status = 'leave_pending'");
        if(rsC.next()) {
            leafCount = rsC.getInt(1);
        }
    } catch(Exception e){ 
        e.printStackTrace(); 
    } finally { 
        if(rsC != null) try { rsC.close(); } catch(SQLException e) {} 
        if(stmtC != null) try { stmtC.close(); } catch(SQLException e) {} 
        if(connC != null) try { connC.close(); } catch(SQLException e) {} 
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>Campus Buzz | UCMS</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="css/styles.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;700;800&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif !important; }
        .nav-link.active { background: rgba(59, 130, 246, 0.15); border-right: 4px solid #3b82f6; color: #fff !important; }
        .tab-btn.active { background: #3b82f6; color: white; box-shadow: 0 4px 14px 0 rgba(59, 130, 246, 0.39); }
        
        /* Popup Animation */
        @keyframes slideIn {
            from { transform: translateY(-20px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }
        .toast-notification { animation: slideIn 0.4s cubic-bezier(0.17, 0.67, 0.83, 0.67) forwards; }
    </style>
</head>
<body class="bg-slate-50 font-['Inter']">

    <%-- POPUP NOTIFICATION: Only shows if success=true --%>
    <% if ("true".equals(successParam)) { %>
    <div id="toast" class="fixed top-8 left-1/2 -translate-x-1/2 z-[100] toast-notification">
        <div class="bg-slate-900 text-white px-8 py-4 rounded-2xl shadow-2xl flex items-center gap-4 border border-slate-700">
            <div class="bg-emerald-500 p-2 rounded-full">
                <svg class="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7"></path>
                </svg>
            </div>
            <div>
                <p class="text-[10px] font-black uppercase tracking-widest text-emerald-400">Status Update</p>
                <p class="text-sm font-bold">Your application for approval has been sent!</p>
            </div>
            <button onclick="document.getElementById('toast').remove()" class="ml-4 hover:text-red-400 transition-colors">
                <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20"><path d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z"></path></svg>
            </button>
        </div>
    </div>
    <script>
        // Auto-hide the popup after 4 seconds
        setTimeout(() => {
            const t = document.getElementById('toast');
            if(t) {
                t.style.transition = "opacity 0.5s ease";
                t.style.opacity = "0";
                setTimeout(() => t.remove(), 500);
            }
        }, 4000);
    </script>
    <% } %>

    <div class="dashboard-container">
        <nav class="sidebar">
            <a href="index.jsp" class="sidebar-brand text-2xl font-black tracking-tighter">UCMS</a>
            <% if ("admin".equals(userRole)) { %>
                <a href="admin-dashboard.jsp" class="nav-link">📊 Overview</a>
                <a href="clubs.jsp" class="nav-link">🏛️ Manage Clubs</a>
                <a href="events.jsp" class="nav-link">📅 Event Control</a>
                <a href="campus-buzz.jsp" class="nav-link active relative flex items-center justify-between">
                    <span>📢 Moderation</span>
                    <% if (pending != null && !pending.isEmpty()) { %>
                        <span class="bg-red-500 text-white text-[10px] font-black px-2 py-0.5 rounded-full animate-bounce"><%= pending.size() %></span>
                    <% } %>
                </a>
            <% } else { %>
                <a href="student-dashboard.jsp" class="nav-link">🏠 Dashboard</a>
                <a href="clubs.jsp" class="nav-link">🔍 Explore Clubs</a>
                <a href="events.jsp" class="nav-link">📅 Events</a>
                <a href="campus-buzz.jsp" class="nav-link active">📢 Campus Buzz</a>
            <% } %>
            <div style="margin-top: auto;"><a href="logout" class="nav-link text-red-400 font-bold">🚪 Logout</a></div>
        </nav>

        <main class="main-content p-10">
            <header class="mb-10 flex justify-between items-center">
                <div>
                    <h1 class="text-4xl font-black text-slate-800 tracking-tighter">Campus Buzz 📢</h1>
                    <p class="text-slate-500 mt-1 font-medium"><%= "admin".equals(userRole) ? "Review student submissions." : "Share updates with the campus." %></p>
                </div>
                <% if ("admin".equals(userRole)) { %>
                    <form action="CampusBuzzController" method="POST">
                        <input type="hidden" name="action" value="clearClaimed">
                        <button type="submit" class="bg-white border border-slate-200 text-slate-500 px-6 py-2 rounded-xl text-[10px] font-black uppercase hover:bg-red-50 hover:text-red-500 transition">Clear Claimed</button>
                    </form>
                <% } %>
            </header>

            <% if ("admin".equals(userRole)) { %>
                <%-- ADMIN MODERATION AREA --%>
                <div class="mb-12">
                    <h3 class="text-xl font-black text-slate-800 mb-6 flex items-center tracking-tight">
                        <span class="w-1.5 h-6 bg-blue-600 mr-3 rounded-full"></span> Moderation Queue
                    </h3>
                    <div class="grid grid-cols-1 gap-6">
                        <% if (pending != null && !pending.isEmpty()) { 
                            for (int i = 0; i < pending.size(); i++) { CampusBuzz pBuzz = (CampusBuzz) pending.get(i); %>
                            <div class="bg-white p-8 rounded-[2rem] shadow-sm border-2 border-blue-50 flex justify-between items-center transition-all hover:border-blue-200">
                                <div class="flex-1">
                                    <span class="text-[10px] font-black text-blue-600 uppercase tracking-widest block mb-1"><%= pBuzz.getCategory() %></span>
                                    <h4 class="font-bold text-slate-800 text-lg mb-1"><%= pBuzz.getStudentName() %></h4>
                                    <p class="text-slate-500 font-medium whitespace-pre-wrap"><%= pBuzz.getContent() %></p>
                                </div>
                                <div class="flex gap-3 ml-8">
                                    <form action="CampusBuzzController" method="POST">
                                        <input type="hidden" name="action" value="approve"><input type="hidden" name="buzzId" value="<%= pBuzz.getPostId() %>">
                                        <button type="submit" class="bg-blue-600 text-white px-6 py-2 rounded-xl font-black text-[10px] uppercase shadow-lg hover:bg-blue-700 transition">Approve</button>
                                    </form>
                                    <form action="CampusBuzzController" method="POST">
                                        <input type="hidden" name="action" value="reject"><input type="hidden" name="buzzId" value="<%= pBuzz.getPostId() %>">
                                        <button type="submit" class="bg-white border border-red-200 text-red-500 px-6 py-2 rounded-xl font-black text-[10px] uppercase hover:bg-red-50 transition">Reject</button>
                                    </form>
                                </div>
                            </div>
                        <% } } else { %>
                            <div class="p-12 bg-white rounded-[2rem] text-center border-2 border-dashed border-slate-100 text-slate-400 font-bold">Queue is empty. Great job!</div>
                        <% } %>
                    </div>
                </div>
            <% } else { %>
                <%-- STUDENT POSTING AREA --%>
                <div class="bg-white p-10 rounded-[2.5rem] shadow-sm border border-slate-100 mb-12">
                    <h3 class="text-sm font-black text-slate-400 uppercase tracking-widest mb-6">Start a Buzz</h3>
                    <form method="POST" action="CampusBuzzController">
                        <input type="hidden" name="action" value="create">
                        <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-6">
                            <select name="category" id="catSelect" onchange="checkCategory()" class="p-4 bg-slate-50 border border-slate-100 rounded-2xl outline-none font-bold text-sm focus:ring-4 focus:ring-blue-50">
                                <option value="General Info">📢 Info</option>
                                <option value="Lost & Found">🔍 Lost & Found</option>
                                <option value="Program">🎓 Program</option>
                            </select>
                            <textarea name="content" class="md:col-span-3 p-5 bg-slate-50 border border-slate-100 rounded-[1.5rem] outline-none h-24 font-medium focus:ring-4 focus:ring-blue-50" placeholder="What's on your mind?" required></textarea>
                        </div>
                        <div id="programDetails" class="hidden grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                            <div class="p-5 bg-blue-50/50 rounded-2xl border border-blue-100">
                                <label class="block text-[10px] font-black text-blue-500 uppercase mb-2 ml-1">Venue</label>
                                <select name="venue" class="w-full p-3 bg-white border border-blue-100 rounded-xl outline-none text-sm font-bold">
                                    <option value="Hall Ali">Hall Ali</option><option value="Hall Abu">Hall Abu</option><option value="Hall Fatimah">Hall Fatimah</option>
                                    <option value="Room A">Room A</option><option value="Room B">Room B</option><option value="Room C">Room C</option>
                                    <option value="Football Field">Football Field</option><option value="Netball Court">Netball Court</option>
                                </select>
                            </div>
                            <div class="p-5 bg-blue-50/50 rounded-2xl border border-blue-100">
                                <label class="block text-[10px] font-black text-blue-500 uppercase mb-2 ml-1">Date</label>
                                <input type="date" name="eventDate" class="w-full p-3 bg-white border border-blue-100 rounded-xl outline-none text-sm font-bold">
                            </div>
                        </div>
                        <div class="flex justify-end"><button type="submit" class="bg-blue-600 text-white px-12 py-4 rounded-2xl font-black shadow-xl hover:bg-blue-700 transition transform hover:scale-105">Publish Post</button></div>
                    </form>
                </div>
            <% } %>

            <%-- THE FEED --%>
            <div class="space-y-8" id="buzzFeed">
                <%
                    List feedList = "admin".equals(userRole) ? approved : myBuzz;
                    for (int i = 0; i < feedList.size(); i++) { 
                        CampusBuzz buzz = (CampusBuzz) feedList.get(i); 
                        boolean isMine = student != null && student.getStudentId().equals(buzz.getStudentId());
                        if ("rejected".equals(buzz.getStatus()) && !isMine) continue;
                %>
                <div class="bg-white p-8 rounded-[2rem] shadow-sm border border-slate-50 buzz-card transition-all hover:shadow-md <%= isMine ? "my-post ring-2 ring-blue-50" : "" %>">
                    <div class="flex justify-between items-start mb-4">
                        <div class="flex items-center gap-3">
                            <span class="text-[11px] font-black text-blue-600 uppercase tracking-widest"><%= buzz.getCategory() %></span>
                            <% if(isMine) { %>
                                <% if("pending".equals(buzz.getStatus())) { %>
                                    <span class="bg-yellow-100 text-yellow-700 px-3 py-1 rounded-full text-[9px] font-black uppercase">Pending ⏳</span>
                                <% } else if("rejected".equals(buzz.getStatus())) { %>
                                    <span class="bg-red-100 text-red-600 px-3 py-1 rounded-full text-[9px] font-black uppercase">Rejected ❌</span>
                                <% } %>
                            <% } %>
                        </div>
                        <% if("Lost & Found".equals(buzz.getCategory()) && !"claimed".equals(buzz.getStatus())) { %>
                            <form action="CampusBuzzController" method="POST">
                                <input type="hidden" name="action" value="claim"><input type="hidden" name="buzzId" value="<%= buzz.getPostId() %>">
                                <button type="submit" class="bg-emerald-50 text-emerald-600 px-4 py-1.5 rounded-full text-[9px] font-black uppercase hover:bg-emerald-600 hover:text-white transition">Mark Claimed</button>
                            </form>
                        <% } %>
                    </div>
                    <p class="text-slate-700 whitespace-pre-wrap font-medium text-lg leading-relaxed <%= "claimed".equals(buzz.getStatus()) ? "opacity-50" : "" %>"><%= buzz.getContent() %></p>
                    <div class="mt-6 pt-6 border-t border-slate-50 flex justify-between items-center">
                        <span class="text-[10px] font-bold text-slate-400 uppercase tracking-widest"><%= isMine ? "You posted this" : buzz.getStudentName() %></span>
                        <span class="text-[10px] font-medium text-slate-300 uppercase"><%= buzz.getUploadDate() %></span>
                    </div>
                </div>
                <% } %>
            </div>
        </main>
    </div>

    <script>
    function checkCategory() {
        var val = document.getElementById('catSelect').value;
        var details = document.getElementById('programDetails');
        if(val === 'Program') { details.classList.remove('hidden'); } 
        else { details.classList.add('hidden'); }
    }
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
