package com.ucms2.db;

import com.ucms2.model.CampusBuzz;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CampusBuzzDAO {

    public List<CampusBuzz> getBuzzByStatus(String status) {
        List<CampusBuzz> list = new ArrayList<>();
        String sql = "SELECT * FROM CAMPUS_BUZZ WHERE Status = ? ORDER BY UploadDate DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                CampusBuzz b = new CampusBuzz();
                b.setPostId(rs.getInt("PostID"));
                b.setStudentId(rs.getString("StudentID"));
                b.setContent(rs.getString("Content"));
                b.setStudentName(rs.getString("StudentName"));
                b.setCategory(rs.getString("Category"));
                b.setStatus(rs.getString("Status"));
                b.setUploadDate(rs.getTimestamp("UploadDate"));
                list.add(b);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }
    public List<CampusBuzz> getBuzzByStudent(String studentId) {
        List<CampusBuzz> list = new ArrayList<>();
        String sql = "SELECT * FROM CAMPUS_BUZZ WHERE StudentID = ? ORDER BY UploadDate DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, studentId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                CampusBuzz b = new CampusBuzz();
                b.setPostId(rs.getInt("PostID"));
                b.setStudentId(rs.getString("StudentID"));
                b.setStudentName(rs.getString("StudentName"));
                b.setContent(rs.getString("Content"));
                b.setCategory(rs.getString("Category"));
                b.setStatus(rs.getString("Status"));
                b.setUploadDate(rs.getTimestamp("UploadDate"));
                list.add(b);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }


    public boolean updateStatus(int postId, String status) {
        String sql = "UPDATE CAMPUS_BUZZ SET Status = ?, ApprovedDate = CURRENT_TIMESTAMP WHERE PostID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, postId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { return false; }
    }

    public boolean markAsClaimed(int postId) {
        String sql = "UPDATE CAMPUS_BUZZ SET Status = 'claimed' WHERE PostID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, postId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean createPost(String studentId, String studentName, String content, String category, String venue, String eventDate) {
        String finalContent = content;
        if ("Program".equalsIgnoreCase(category)) {
            finalContent += "\n\n📍 Venue: " + venue + "\n📅 Date: " + eventDate;
        }

        String sql = "INSERT INTO CAMPUS_BUZZ (StudentID, StudentName, Content, Status, Category) VALUES (?, ?, ?, 'pending', ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            ps.setString(2, studentName);
            ps.setString(3, finalContent);
            ps.setString(4, category);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { 
            e.printStackTrace();
            return false; 
        }
    }
}