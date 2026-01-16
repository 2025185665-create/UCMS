package com.ucms2.servlet;

import com.ucms2.db.DBConnection;
import java.io.IOException;
import java.sql.*;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/MemberController")
public class MemberController extends HttpServlet {

    // GET: Fetches the list of all members across all clubs
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        List<Map<String, String>> members = new ArrayList<Map<String, String>>();
        
        String sql = "SELECT m.StudentID, s.StudentName, c.ClubName, m.JoinDate " +
                     "FROM CLUB_MEMBERSHIP m " +
                     "JOIN STUDENT s ON m.StudentID = s.StudentID " +
                     "JOIN CLUB c ON m.ClubID = c.ClubID " +
                     "ORDER BY m.JoinDate DESC";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                Map<String, String> member = new HashMap<String, String>();
                member.put("id", rs.getString("StudentID"));
                member.put("name", rs.getString("StudentName"));
                member.put("club", rs.getString("ClubName"));
                member.put("date", rs.getString("JoinDate"));
                members.add(member);
            }
            
            request.setAttribute("members", members);
            // Forward to the JSP so URL shows members.jsp
            request.getRequestDispatcher("members.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin-dashboard.jsp?error=Data load failed");
        }
    }

    // POST: Handles revoking (removing) a student from a club
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String studentId = request.getParameter("studentId");
        String clubName = request.getParameter("clubName");

        // SQL to delete by student ID and identifying the club by name
        String sql = "DELETE FROM CLUB_MEMBERSHIP WHERE StudentID = ? " +
                     "AND ClubID = (SELECT ClubID FROM CLUB WHERE ClubName = ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, studentId);
            ps.setString(2, clubName);
            ps.executeUpdate();
            
            // Redirect back to .jsp
            response.sendRedirect("members.jsp?success=Membership revoked successfully");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("members.jsp?error=Remove failed");
        }
    }
}