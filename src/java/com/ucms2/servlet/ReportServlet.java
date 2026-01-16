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
        
        // Parameters for Admin multi-report and filtering logic
        String targetStudentId = request.getParameter("studentId");
        String reportType = request.getParameter("type");
        String clubFilter = request.getParameter("clubId"); // Captured from the dropdown filter
        
        List reportData = new ArrayList();
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            
            // LOGIC A: ADMIN GLOBAL EXPORT (With Club Separator Filter)
            if ("admin".equals(userRole) && "all_members".equals(reportType)) {
                StringBuilder sql = new StringBuilder(
                    "SELECT m.StudentID, s.StudentName, c.ClubName FROM CLUB_MEMBERSHIP m " +
                    "JOIN STUDENT s ON m.StudentID = s.StudentID " +
                    "JOIN CLUB c ON m.ClubID = c.ClubID "
                );

                // Apply filter if a specific club was chosen in the dropdown
                if (clubFilter != null && !clubFilter.trim().isEmpty()) {
                    sql.append(" WHERE m.ClubID = ? ");
                }
                sql.append(" ORDER BY s.StudentName ASC");

                PreparedStatement stmt = conn.prepareStatement(sql.toString());
                if (clubFilter != null && !clubFilter.trim().isEmpty()) {
                    stmt.setString(1, clubFilter);
                }

                ResultSet rs = stmt.executeQuery();
                String filterName = "All Societies";

                while(rs.next()) {
                    Map row = new HashMap();
                    row.put("id", rs.getString("StudentID"));
                    row.put("name", rs.getString("StudentName"));
                    row.put("club", rs.getString("ClubName"));
                    reportData.add(row);
                    filterName = rs.getString("ClubName"); // Get club name for the header
                }

                request.setAttribute("isGlobalReport", true);
                if (clubFilter != null && !clubFilter.trim().isEmpty() && !reportData.isEmpty()) {
                    request.setAttribute("filterTitle", filterName);
                } else {
                    request.setAttribute("filterTitle", "General Membership Directory");
                }
            } 
            // LOGIC B: INDIVIDUAL TRANSCRIPT (Unchanged logic for individual view)
            else {
                String studentIdToFetch = null;
                String studentNameToDisplay = "";

                if ("admin".equals(userRole) && targetStudentId != null) {
                    studentIdToFetch = targetStudentId;
                    PreparedStatement psN = conn.prepareStatement("SELECT StudentName FROM STUDENT WHERE StudentID = ?");
                    psN.setString(1, studentIdToFetch);
                    ResultSet rsN = psN.executeQuery();
                    if(rsN.next()) studentNameToDisplay = rsN.getString("StudentName");
                } else {
                    Student s = (Student) session.getAttribute("student");
                    if (s != null) {
                        studentIdToFetch = s.getStudentId();
                        studentNameToDisplay = s.getStudentName();
                    }
                }

                if (studentIdToFetch != null) {
                    // Fetch Clubs for individual
                    PreparedStatement ps1 = conn.prepareStatement("SELECT c.ClubName FROM CLUB c JOIN CLUB_MEMBERSHIP m ON c.ClubID = m.ClubID WHERE m.StudentID = ?");
                    ps1.setString(1, studentIdToFetch);
                    ResultSet rs1 = ps1.executeQuery();
                    List clubs = new ArrayList();
                    while(rs1.next()) { clubs.add(rs1.getString("ClubName")); }
                    request.setAttribute("studentClubs", clubs);

                    // Fetch Events for individual
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
                    request.setAttribute("reportStudentName", studentNameToDisplay);
                    request.setAttribute("reportStudentId", studentIdToFetch);
                    request.setAttribute("isGlobalReport", false);
                }
            }
            
            request.setAttribute("reportData", reportData);
            request.setAttribute("generatedDate", new java.text.SimpleDateFormat("dd MMM yyyy, HH:mm").format(new java.util.Date()));
            request.getRequestDispatcher("report-view.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (conn != null) conn.close(); } catch (SQLException ex) { }
        }
    }
}