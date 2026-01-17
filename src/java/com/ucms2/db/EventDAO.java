package com.ucms2.db;

import com.ucms2.model.Event;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class EventDAO {

    // 1. Fetch ALL Events with Live Counters (Used for Grid/Calendar)
    public List<Event> getAllEvents() {
        List<Event> events = new ArrayList<>();
        String sql = "SELECT e.*, (SELECT COUNT(*) FROM EVENT_REGISTRATION r WHERE r.EventID = e.EventID) AS liveCount " +
                     "FROM EVENT e ORDER BY e.EventDate ASC";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                Event event = new Event();
                event.setEventId(rs.getInt("EventID"));
                event.setEventName(rs.getString("EventName"));

                // --- SPLIT LOGIC ---
                String rawVenue = rs.getString("EventVenue");
                int goal = rs.getInt("TargetGoal");
                if (rawVenue != null && rawVenue.contains("|")) {
                    try {
                        goal = Integer.parseInt(rawVenue.split("\\|")[1].trim());
                    } catch(Exception e) { goal = 50; }
                } else if (goal <= 0) {
                    goal = 50;
                }

                event.setEventVenue(rawVenue);
                event.setTargetGoal(goal);
                event.setEventDate(rs.getDate("EventDate"));
                event.setAttendanceCount(rs.getInt("liveCount"));
                events.add(event);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return events;
    }

    // 2. Fetch Events with Search Filter
    public List<Event> getEventsWithSearch(String search) {
        List<Event> list = new ArrayList<>();
        String sql = "SELECT e.*, (SELECT COUNT(*) FROM EVENT_REGISTRATION r WHERE r.EventID = e.EventID) AS liveCount " +
                     "FROM EVENT e WHERE UPPER(e.EventName) LIKE ? OR UPPER(e.EventVenue) LIKE ? " +
                     "ORDER BY e.EventDate ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            String pattern = "%" + search.toUpperCase() + "%";
            ps.setString(1, pattern);
            ps.setString(2, pattern);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Event e = new Event();
                e.setEventId(rs.getInt("EventID"));
                e.setEventName(rs.getString("EventName"));

                // --- SPLIT LOGIC ---
                String rawVenue = rs.getString("EventVenue");
                int goal = rs.getInt("TargetGoal");
                if (rawVenue != null && rawVenue.contains("|")) {
                    try {
                        goal = Integer.parseInt(rawVenue.split("\\|")[1].trim());
                    } catch(Exception ex) { goal = 50; }
                } else if (goal <= 0) {
                    goal = 50;
                }

                e.setEventVenue(rawVenue);
                e.setTargetGoal(goal);
                e.setEventDate(rs.getDate("EventDate"));
                e.setAttendanceCount(rs.getInt("liveCount"));
                list.add(e);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // 3. Fetch Events specifically for one Student (Dashboard Refresh)
    public List<Event> getEventsByStudent(String studentId) {
        List<Event> list = new ArrayList<>();
        String sql = "SELECT e.*, (SELECT COUNT(*) FROM EVENT_REGISTRATION r2 WHERE r2.EventID = e.EventID) as liveCount " +
                     "FROM EVENT e JOIN EVENT_REGISTRATION r ON e.EventID = r.EventID " +
                     "WHERE r.StudentID = ? ORDER BY e.EventDate ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Event e = new Event();
                e.setEventId(rs.getInt("EventID"));
                e.setEventName(rs.getString("EventName"));

                // --- SPLIT LOGIC ---
                String rawVenue = rs.getString("EventVenue");
                int goal = rs.getInt("TargetGoal");
                if (rawVenue != null && rawVenue.contains("|")) {
                    try {
                        goal = Integer.parseInt(rawVenue.split("\\|")[1].trim());
                    } catch(Exception ex) { goal = 50; }
                } else if (goal <= 0) {
                    goal = 50;
                }

                e.setEventVenue(rawVenue);
                e.setTargetGoal(goal);
                e.setEventDate(rs.getDate("EventDate"));
                e.setAttendanceCount(rs.getInt("liveCount"));
                list.add(e);
            }
        } catch (SQLException ex) { ex.printStackTrace(); }
        return list;
    }

    // 4. Fetch Single Event (Crucial for Registration Validation)
    public Event getEventById(int eventId) {
        Event event = null;
        String sql = "SELECT e.*, (SELECT COUNT(*) FROM EVENT_REGISTRATION r WHERE r.EventID = e.EventID) AS liveCount " +
                     "FROM EVENT e WHERE e.EventID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                event = new Event();
                event.setEventId(rs.getInt("EventID"));
                event.setEventName(rs.getString("EventName"));

                // --- SPLIT LOGIC ---
                String rawVenue = rs.getString("EventVenue");
                int goal = rs.getInt("TargetGoal");
                if (rawVenue != null && rawVenue.contains("|")) {
                    try {
                        goal = Integer.parseInt(rawVenue.split("\\|")[1].trim());
                    } catch(Exception e) { goal = 50; }
                } else if (goal <= 0) {
                    goal = 50;
                }

                event.setEventVenue(rawVenue);
                event.setTargetGoal(goal);
                event.setEventDate(rs.getDate("EventDate"));
                event.setAttendanceCount(rs.getInt("liveCount"));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return event;
    }

    // 5. Register Student
    public boolean registerStudent(int eventId, String studentId, String studentName) {
            String sql = "INSERT INTO EVENT_REGISTRATION (EventID, StudentID, StudentName) VALUES (?, ?, ?)";

            try (Connection conn = DBConnection.getConnection()) {
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setInt(1, eventId);
                ps.setString(2, studentId);
                ps.setString(3, studentName);

                int rows = ps.executeUpdate();
                return rows > 0;
            } catch (SQLException e) { 
                System.out.println("DB INSERT ERROR: " + e.getMessage());
                e.printStackTrace(); 
                return false; 
            }
        }

    // 6. Unregister Student
    public boolean unregisterStudent(int eventId, String studentId) {
        String sql = "DELETE FROM EVENT_REGISTRATION WHERE EventID = ? AND StudentID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            ps.setString(2, studentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // 7. Create Event
    public boolean createEvent(String name, String venue, String date, int goal) {
        String sql = "INSERT INTO EVENT (EventName, EventVenue, EventDate, TargetGoal) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setString(2, venue);
            ps.setString(3, date);
            ps.setInt(4, goal);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // 8. Get Attendance List for Admin
    public List<String[]> getAttendance(int eventId) {
        List<String[]> attendance = new ArrayList<>();
        String sql = "SELECT StudentID, StudentName, RegistrationDate FROM EVENT_REGISTRATION WHERE EventID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                attendance.add(new String[]{ 
                    rs.getString("StudentID"), 
                    rs.getString("StudentName"), 
                    rs.getString("RegistrationDate") 
                });
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return attendance;
    }
}