package com.ucms2.servlet;

import com.ucms2.db.DBConnection;
import com.ucms2.model.Student;
import java.io.IOException;
import java.sql.*;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/ReportController")
public class ReportServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        String userRole = (String) session.getAttribute("userRole");
        String targetStudentId = request.getParameter("studentId");
        String reportType = request.getParameter("type");
        String clubFilter = request.getParameter("clubId"); 
        
        List reportData = new ArrayList();
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            
            // LOGIC A: ADMIN GLOBAL EXPORT (Added Status)
            if ("admin".equals(userRole) && "all_members".equals(reportType)) {
                StringBuilder sql = new StringBuilder(
                    "SELECT m.StudentID, s.StudentName, c.ClubName, m.Status FROM CLUB_MEMBERSHIP m " +
                    "JOIN STUDENT s ON m.StudentID = s.StudentID " +
                    "JOIN CLUB c ON m.ClubID = c.ClubID "
                );

                if (clubFilter != null && !clubFilter.trim().isEmpty()) {
                    sql.append(" WHERE m.ClubID = ? ");
                }
                sql.append(" ORDER BY s.StudentName ASC");

                PreparedStatement stmt = conn.prepareStatement(sql.toString());
                if (clubFilter != null && !clubFilter.trim().isEmpty()) {
                    stmt.setInt(1, Integer.parseInt(clubFilter));
                }

                ResultSet rs = stmt.executeQuery();
                while(rs.next()) {
                    Map row = new HashMap();
                    row.put("id", rs.getString("StudentID"));
                    row.put("name", rs.getString("StudentName"));
                    row.put("club", rs.getString("ClubName"));
                    row.put("status", rs.getString("Status")); // Status added for badges
                    reportData.add(row);
                }
                request.setAttribute("isGlobalReport", Boolean.TRUE);
            } 
            // LOGIC B: INDIVIDUAL TRANSCRIPT
            else {
                String studentIdToFetch = (targetStudentId != null) ? targetStudentId : ((Student)session.getAttribute("student")).getStudentId();
                
                // Fetch Clubs with status for individual view
                PreparedStatement ps1 = conn.prepareStatement("SELECT c.ClubName, m.Status FROM CLUB c JOIN CLUB_MEMBERSHIP m ON c.ClubID = m.ClubID WHERE m.StudentID = ?");
                ps1.setString(1, studentIdToFetch);
                ResultSet rs1 = ps1.executeQuery();
                List clubs = new ArrayList();
                while(rs1.next()) { 
                    Map cMap = new HashMap();
                    cMap.put("name", rs1.getString("ClubName"));
                    cMap.put("status", rs1.getString("Status"));
                    clubs.add(cMap); 
                }
                request.setAttribute("studentClubs", clubs);

                // Fetch Events
                PreparedStatement ps2 = conn.prepareStatement("SELECT e.EventName, e.EventDate, e.EventVenue FROM EVENT e JOIN EVENT_REGISTRATION r ON e.EventID = r.EventID WHERE r.StudentID = ? ORDER BY e.EventDate DESC");
                ps2.setString(1, studentIdToFetch);
                ResultSet rs2 = ps2.executeQuery();
                while(rs2.next()) {
                    Map row = new HashMap();
                    row.put("eventName", rs2.getString("EventName"));
                    row.put("eventDate", rs2.getDate("EventDate"));
                    row.put("eventVenue", rs2.getString("EventVenue"));
                    reportData.add(row);
                }
                request.setAttribute("reportStudentId", studentIdToFetch);
                request.setAttribute("isGlobalReport", Boolean.FALSE);
            }
            
            request.setAttribute("reportData", reportData);
            request.setAttribute("generatedDate", new java.text.SimpleDateFormat("dd MMM yyyy").format(new java.util.Date()));
            request.getRequestDispatcher("report-view.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (conn != null) try { conn.close(); } catch (SQLException ex) { }
        }
    }
}