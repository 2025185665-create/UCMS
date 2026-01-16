package com.ucms2.model;

import java.io.Serializable;
import java.util.Date;

public class EventRegistration implements Serializable {
    private int registrationId;
    private int eventId;
    private String studentId;
    private String studentName;
    private Date registrationDate;
    
    public EventRegistration() {}
    
    public EventRegistration(int eventId, String studentId, String studentName) {
        this.eventId = eventId;
        this.studentId = studentId;
        this.studentName = studentName;
    }
    
    // Getters and Setters
    public int getRegistrationId() { return registrationId; }
    public void setRegistrationId(int registrationId) { this.registrationId = registrationId; }
    
    public int getEventId() { return eventId; }
    public void setEventId(int eventId) { this.eventId = eventId; }
    
    public String getStudentId() { return studentId; }
    public void setStudentId(String studentId) { this.studentId = studentId; }
    
    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }
    
    public Date getRegistrationDate() { return registrationDate; }
    public void setRegistrationDate(Date registrationDate) { this.registrationDate = registrationDate; }
}