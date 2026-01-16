package com.ucms2.servlet;

import com.ucms2.db.DBConnection;
import com.ucms2.model.Student;
import com.ucms2.model.CampusBuzz;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Date;
import java.text.SimpleDateFormat;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/MyProfileController")
public class MyProfileServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Student student = (Student) session.getAttribute("student");
        if (student == null) { response.sendRedirect("login.jsp"); return; }

        List myClubs = new ArrayList();
        List myEvents = new ArrayList();
        List myBuzzHistory = new ArrayList();
        int claimedCount = 0;
        int certCount = 0;
        
        SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy, HH:mm");
        String lastLogin = sdf.format(new Date()); 

        Connection conn = null;
        PreparedStatement ps1 = null; PreparedStatement ps2 = null; 
        PreparedStatement ps3 = null; PreparedStatement ps4 = null; 
        PreparedStatement ps5 = null;
        ResultSet rs1 = null; ResultSet rs2 = null; 
        ResultSet rs3 = null; ResultSet rs4 = null; 
        ResultSet rs5 = null;

        try {
            conn = DBConnection.getConnection();

            ps1 = conn.prepareStatement("SELECT c.ClubName FROM CLUB c JOIN CLUB_MEMBERSHIP m ON c.ClubID = m.ClubID WHERE m.StudentID = ?");
            ps1.setString(1, student.getStudentId());
            rs1 = ps1.executeQuery();
            while (rs1.next()) { myClubs.add(rs1.getString("ClubName")); }

            ps2 = conn.prepareStatement("SELECT e.EventName FROM EVENT e JOIN EVENT_REGISTRATION r ON e.EventID = r.EventID WHERE r.StudentID = ?");
            ps2.setString(1, student.getStudentId());
            rs2 = ps2.executeQuery();
            while (rs2.next()) { myEvents.add(rs2.getString("EventName")); }

            ps3 = conn.prepareStatement("SELECT Content, Status, Category, UploadDate FROM CAMPUS_BUZZ WHERE StudentID = ? ORDER BY UploadDate DESC");
            ps3.setString(1, student.getStudentId());
            rs3 = ps3.executeQuery();
            while (rs3.next()) {
                CampusBuzz b = new CampusBuzz();
                b.setContent(rs3.getString("Content"));
                b.setStatus(rs3.getString("Status"));
                b.setCategory(rs3.getString("Category"));
                b.setUploadDate(rs3.getTimestamp("UploadDate"));
                myBuzzHistory.add(b);
            }

            ps4 = conn.prepareStatement("SELECT COUNT(*) FROM CAMPUS_BUZZ WHERE StudentID = ? AND Status = 'claimed'");
            ps4.setString(1, student.getStudentId());
            rs4 = ps4.executeQuery();
            if (rs4.next()) claimedCount = rs4.getInt(1);

            ps5 = conn.prepareStatement("SELECT COUNT(*) FROM EVENT_REGISTRATION r JOIN EVENT e ON r.EventID = e.EventID WHERE r.StudentID = ? AND e.EventDate < CURRENT_DATE");
            ps5.setString(1, student.getStudentId());
            rs5 = ps5.executeQuery();
            if (rs5.next()) certCount = rs5.getInt(1);

            request.setAttribute("myClubs", myClubs);
            request.setAttribute("myEvents", myEvents);
            request.setAttribute("myBuzzHistory", myBuzzHistory);
            request.setAttribute("claimedCount", claimedCount);
            request.setAttribute("certCount", certCount);
            request.setAttribute("lastLogin", lastLogin);
            request.setAttribute("streak", 5);
            
            request.getRequestDispatcher("my-output.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs1 != null) rs1.close(); if (ps1 != null) ps1.close();
                if (rs2 != null) rs2.close(); if (ps2 != null) ps2.close();
                if (rs3 != null) rs3.close(); if (ps3 != null) ps3.close();
                if (rs4 != null) rs4.close(); if (ps4 != null) ps4.close();
                if (rs5 != null) rs5.close(); if (ps5 != null) ps5.close();
                if (conn != null) conn.close();
            } catch (SQLException ex) { ex.printStackTrace(); }
        }
    }
}