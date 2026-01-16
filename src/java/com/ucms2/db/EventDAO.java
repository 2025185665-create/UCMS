package com.ucms2.db;

import com.ucms2.model.Event;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class EventDAO {

    // FETCH ALL EVENTS WITH LIVE ATTENDANCE COUNT
    public List<Event> getAllEvents() {
        List<Event> events = new ArrayList<>();
        // This SQL query calculates the current registrations (attendanceCount) automatically
        String sql = "SELECT e.*, (SELECT COUNT(*) FROM EVENT_REGISTRATION r WHERE r.EventID = e.EventID) AS currentReg " +
                     "FROM EVENT e ORDER BY e.EventDate ASC";
                     
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                Event event = new Event();
                event.setEventId(rs.getInt("EventID"));
                event.setEventName(rs.getString("EventName"));
                event.setEventDate(rs.getDate("EventDate"));
                event.setEventVenue(rs.getString("EventVenue"));
                event.setTargetGoal(rs.getInt("TargetGoal"));
                event.setAttendanceCount(rs.getInt("currentReg"));
                events.add(event);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return events;
    }

    // FETCH A SINGLE EVENT (Used for the Capacity Check in Servlet)
    public Event getEventById(int eventId) {
        Event event = null;
        String sql = "SELECT e.*, (SELECT COUNT(*) FROM EVENT_REGISTRATION r WHERE r.EventID = e.EventID) AS currentReg " +
                     "FROM EVENT e WHERE e.EventID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                event = new Event();
                event.setEventId(rs.getInt("EventID"));
                event.setEventName(rs.getString("EventName"));
                event.setEventDate(rs.getDate("EventDate"));
                event.setEventVenue(rs.getString("EventVenue"));
                event.setTargetGoal(rs.getInt("TargetGoal"));
                event.setAttendanceCount(rs.getInt("currentReg"));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return event;
    }

    // CREATE EVENT (Includes Target Goal)
    public boolean createEvent(String name, String venue, String date, int goal) {
        String sql = "INSERT INTO EVENT (EventName, EventVenue, EventDate, TargetGoal) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setString(2, venue);
            ps.setString(3, date);
            ps.setInt(4, goal);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { return false; }
    }

    // GET ATTENDANCE, REGISTER, and UNREGISTER (Keep these as they were)
    public List<String[]> getAttendance(int eventId) {
        List<String[]> attendance = new ArrayList<>();
        String sql = "SELECT StudentID, StudentName FROM EVENT_REGISTRATION WHERE EventID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                attendance.add(new String[]{rs.getString("StudentID"), rs.getString("StudentName")});
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return attendance;
    }

    public boolean registerStudent(int eventId, String studentId, String studentName) {
        String sql = "INSERT INTO EVENT_REGISTRATION (EventID, StudentID, StudentName) VALUES (?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            ps.setString(2, studentId);
            ps.setString(3, studentName);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { return false; }
    }

    public boolean unregisterStudent(int eventId, String studentId) {
        String sql = "DELETE FROM EVENT_REGISTRATION WHERE EventID = ? AND StudentID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            ps.setString(2, studentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { return false; }
    }
}