package com.ucms2.servlet;

import com.ucms2.db.ClubDAO;
import com.ucms2.db.EventDAO;
import com.ucms2.db.DBConnection;
import java.io.IOException;
import java.sql.*;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/AdminDashboardController")
public class AdminDashboardServlet extends HttpServlet {

@Override
protected void doGet(HttpServletRequest request, HttpServletResponse response) 
        throws ServletException, IOException {
    
    HttpSession session = request.getSession(false);
    
    // 1. Security Check
    if (session == null || !"admin".equals(session.getAttribute("userRole"))) {
        response.sendRedirect("login.jsp");
        return;
    }

    try {
        ClubDAO clubDAO = new ClubDAO();
        EventDAO eventDAO = new EventDAO();
        
        // 2. Stats from DAOs
        List clubsList = (List) clubDAO.getAllClubs();
        int totalClubs = (clubsList != null) ? clubsList.size() : 0;
        
        List eventsList = (List) eventDAO.getAllEvents();
        int totalEvents = (eventsList != null) ? eventsList.size() : 0;

        // Use a single connection for the remaining manual queries
        try (Connection conn = DBConnection.getConnection()) {
            
            // 3. Pending Leave Requests
            List<Map<String, Object>> leaveRequests = new ArrayList<>();
            String leaveSql = "SELECT s.StudentName, c.ClubName, m.StudentID, m.ClubID " +
                              "FROM CLUB_MEMBERSHIP m " +
                              "JOIN STUDENT s ON m.StudentID = s.StudentID " +
                              "JOIN CLUB c ON m.ClubID = c.ClubID " +
                              "WHERE m.Status = 'leave_pending'";
            
            try (Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery(leaveSql)) {
                while(rs.next()) {
                    Map<String, Object> req = new HashMap<>();
                    req.put("studentName", rs.getString("StudentName"));
                    req.put("clubName", rs.getString("ClubName"));
                    req.put("studentId", rs.getString("StudentID"));
                    req.put("clubId", rs.getInt("ClubID"));
                    leaveRequests.add(req);
                }
            }

            // 4. Pending Buzz Count (FIXED: Only one place to calculate this)
            int pendingBuzzCount = 0;
            String sqlBuzz = "SELECT COUNT(*) FROM CAMPUS_BUZZ WHERE Status = 'pending'";
            try (PreparedStatement psBuzz = conn.prepareStatement(sqlBuzz);
                 ResultSet rsBuzz = psBuzz.executeQuery()) {
                if (rsBuzz.next()) {
                    pendingBuzzCount = rsBuzz.getInt(1);
                }
            }

            // 5. Contributors
            List<Map<String, Object>> topContributors = new ArrayList<>();
            String informantSql = "SELECT StudentName, COUNT(*) as cnt FROM CAMPUS_BUZZ " +
                                 "WHERE Status = 'approved' " +
                                 "GROUP BY StudentName ORDER BY cnt DESC";
            
            try (Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery(informantSql)) {
                int contribCount = 0;
                while(rs.next() && contribCount < 5) {
                    Map<String, Object> contributor = new HashMap<>();
                    contributor.put("name", rs.getString("StudentName"));
                    contributor.put("count", rs.getInt("cnt"));
                    topContributors.add(contributor);
                    contribCount++;
                }
            }

            // 6. Synchronize Session Attributes
            session.setAttribute("totalClubs", totalClubs);
            session.setAttribute("totalEvents", totalEvents);
            session.setAttribute("leaveRequests", leaveRequests);
            session.setAttribute("pendingLeaves", leaveRequests.size());
            session.setAttribute("pendingBuzzCount", pendingBuzzCount);
            session.setAttribute("topContributors", topContributors);
        }

        // 7. Forward
        request.getRequestDispatcher("admin-dashboard.jsp").forward(request, response);

    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("login.jsp?error=DashboardLoadError");
    }
}
}