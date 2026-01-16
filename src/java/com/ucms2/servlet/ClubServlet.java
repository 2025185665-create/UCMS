package com.ucms2.servlet;

import com.ucms2.db.DBConnection;
import com.ucms2.db.ClubDAO;
import com.ucms2.model.Club;
import com.ucms2.model.Admin;
import com.ucms2.model.Student;
import java.io.IOException;
import java.sql.*;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/ClubController")
public class ClubServlet extends HttpServlet { 
    
    private ClubDAO clubDAO = new ClubDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        try {
            if ("edit".equals(action)) {
                // Load single club data for editing
                int clubId = Integer.parseInt(request.getParameter("clubId"));
                Club c = clubDAO.getClubById(clubId); // Ensure this method exists in your DAO
                request.setAttribute("club", c);
                request.getRequestDispatcher("clubs.jsp").forward(request, response);
            } else {
                List clubList = clubDAO.getAllClubs();
                request.setAttribute("clubList", clubList);
                request.getRequestDispatcher("clubs.jsp").forward(request, response);
            }
        } catch (Exception e) {
            response.sendRedirect("clubs.jsp?error=Data Error");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        HttpSession session = request.getSession();

        try (Connection conn = DBConnection.getConnection()) {
            if ("create".equals(action)) {
                Admin admin = (Admin) session.getAttribute("admin");
                PreparedStatement ps = conn.prepareStatement("INSERT INTO CLUB (ClubName, ClubDescription, CreatedBy) VALUES (?, ?, ?)");
                ps.setString(1, request.getParameter("clubName"));
                ps.setString(2, request.getParameter("clubDescription"));
                ps.setString(3, admin.getAdminName());
                ps.executeUpdate();
                response.sendRedirect("clubs.jsp?success=Club created successfully!");
            } else if ("update".equals(action)) {
                PreparedStatement ps = conn.prepareStatement("UPDATE CLUB SET ClubName = ?, ClubDescription = ? WHERE ClubID = ?");
                ps.setString(1, request.getParameter("clubName"));
                ps.setString(2, request.getParameter("clubDescription"));
                ps.setInt(3, Integer.parseInt(request.getParameter("clubId")));
                ps.executeUpdate();
                response.sendRedirect("clubs.jsp?success=Club updated!");
            } else if ("delete".equals(action)) {
                PreparedStatement ps = conn.prepareStatement("DELETE FROM CLUB WHERE ClubID = ?");
                ps.setInt(1, Integer.parseInt(request.getParameter("clubId")));
                ps.executeUpdate();
                response.sendRedirect("clubs.jsp?success=Club deleted!");
            } else if ("join".equals(action) || "leave".equals(action)) {
                handleStudentAction(request, conn, action);
                response.sendRedirect("clubs.jsp?success=Action confirmed!");
            }
        } catch (Exception e) {
            response.sendRedirect("clubs.jsp?error=Process failed");
        }
    }

    private void handleStudentAction(HttpServletRequest request, Connection conn, String action) throws Exception {
        Student student = (Student) request.getSession().getAttribute("student");
        int clubId = Integer.parseInt(request.getParameter("clubId"));
        if ("join".equals(action)) {
            PreparedStatement ps = conn.prepareStatement("INSERT INTO CLUB_MEMBERSHIP (ClubID, StudentID) VALUES (?, ?)");
            ps.setInt(1, clubId); ps.setString(2, student.getStudentId());
            ps.executeUpdate();
        } else {
            PreparedStatement ps = conn.prepareStatement("DELETE FROM CLUB_MEMBERSHIP WHERE ClubID = ? AND StudentID = ?");
            ps.setInt(1, clubId); ps.setString(2, student.getStudentId());
            ps.executeUpdate();
        }
    }
}