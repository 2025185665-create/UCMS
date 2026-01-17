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

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("admin") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            ClubDAO clubDAO = new ClubDAO();
            EventDAO eventDAO = new EventDAO();
            conn = DBConnection.getConnection();
            stmt = conn.createStatement();
            
            // 1. Stats
            int totalClubs = clubDAO.getAllClubs().size();
            int totalEvents = eventDAO.getAllEvents().size();
            
            // 2. Pending Exits
            List leaveRequests = new ArrayList();
            String leaveSql = "SELECT s.StudentName, c.ClubName, m.StudentID, m.ClubID " +
                              "FROM CLUB_MEMBERSHIP m " +
                              "JOIN STUDENT s ON m.StudentID = s.StudentID " +
                              "JOIN CLUB c ON m.ClubID = c.ClubID " +
                              "WHERE m.Status = 'leave_pending'";
            rs = stmt.executeQuery(leaveSql);
            while(rs.next()) {
                Map req = new HashMap();
                req.put("studentName", rs.getString("StudentName"));
                req.put("clubName", rs.getString("ClubName"));
                req.put("studentId", rs.getString("StudentID"));
                req.put("clubId", rs.getInt("ClubID"));
                leaveRequests.add(req);
            }
            rs.close(); 

            // 3. Buzz Count
            rs = stmt.executeQuery("SELECT COUNT(*) FROM CAMPUS_BUZZ WHERE Status = 'pending'");
            int pendingBuzzCount = 0;
            if(rs.next()) pendingBuzzCount = rs.getInt(1);
            rs.close();

            // 4. Contributors
            List topContributors = new ArrayList();
            String informantSql = "SELECT StudentName, COUNT(*) as cnt FROM CAMPUS_BUZZ " +
                                 "WHERE Status = 'approved' " +
                                 "GROUP BY StudentName ORDER BY cnt DESC";
            rs = stmt.executeQuery(informantSql);
            int count = 0;
            while(rs.next() && count < 5) {
                Map contributor = new HashMap();
                contributor.put("name", rs.getString("StudentName"));
                contributor.put("count", rs.getString("cnt"));
                topContributors.add(contributor);
                count++;
            }

            session.setAttribute("totalClubs", totalClubs);
            session.setAttribute("totalEvents", totalEvents);
            session.setAttribute("leaveRequests", leaveRequests);
            session.setAttribute("pendingLeaves", leaveRequests.size());
            session.setAttribute("pendingBuzzCount", pendingBuzzCount);
            session.setAttribute("topContributors", topContributors);

            response.sendRedirect("admin-dashboard.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("login.jsp?error=Dashboard Error");
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    }
}