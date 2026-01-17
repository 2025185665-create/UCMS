package com.ucms2.db;

import com.ucms2.model.Student;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class StudentDAO {
    public List<Student> getAllStudents() {
        List<Student> studentList = new ArrayList<>();
        String sql = "SELECT * FROM STUDENT ORDER BY StudentName ASC";
        
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                Student s = new Student();
                s.setStudentId(rs.getString("StudentID"));
                s.setStudentName(rs.getString("StudentName"));
                s.setStudentEmail(rs.getString("StudentEmail"));
                try {
                    s.setCreatedAt(rs.getTimestamp("CreatedAt"));
                } catch (SQLException e) {
                }
                studentList.add(s);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return studentList;
    }
}