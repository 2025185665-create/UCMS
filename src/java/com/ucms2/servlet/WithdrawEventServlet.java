package com.ucms2.servlet;

import com.ucms2.db.DBConnection;
import com.ucms2.model.Student;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/withdraw-event")
public class WithdrawEventServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Student student = (Student) session.getAttribute("student");
        String eventId = request.getParameter("eventId");

        if (student == null || eventId == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            // Remove the specific student registration for this event
            String sql = "DELETE FROM EVENT_REGISTRATION WHERE EventID = ? AND StudentID = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, Integer.parseInt(eventId));
            ps.setString(2, student.getStudentId());
            
            ps.executeUpdate();
            response.sendRedirect("register-event?success=You have withdrawn from the event.");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("register-event?error=Failed to withdraw.");
        }
    }
}