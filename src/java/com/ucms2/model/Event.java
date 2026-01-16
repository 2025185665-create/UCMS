package com.ucms2.model;
import java.sql.Date;

public class Event {
    private int eventId;
    private String eventName;
    private String eventVenue;
    private Date eventDate;
    private int attendanceCount; 
    private int targetGoal; // New field for capacity
    private int clubId; // Added to fix the stubs below

    // Getters and Setters
    public int getEventId() { return eventId; }
    public void setEventId(int eventId) { this.eventId = eventId; }
    
    public String getEventName() { return eventName; }
    public void setEventName(String eventName) { this.eventName = eventName; }
    
    public String getEventVenue() { return eventVenue; }
    public void setEventVenue(String eventVenue) { this.eventVenue = eventVenue; }
    
    public Date getEventDate() { return eventDate; }
    public void setEventDate(Date eventDate) { this.eventDate = eventDate; }
    
    public int getAttendanceCount() { return attendanceCount; }
    public void setAttendanceCount(int attendanceCount) { this.attendanceCount = attendanceCount; }

    public int getTargetGoal() { return targetGoal; }
    public void setTargetGoal(int targetGoal) { this.targetGoal = targetGoal; }

    // Fixed the ClubID methods
    public void setClubId(int clubId) { this.clubId = clubId; }
    public int getClubId() { return clubId; }
}