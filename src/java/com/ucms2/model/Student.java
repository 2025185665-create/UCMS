package com.ucms2.model;

import java.io.Serializable;
import java.util.Date;

public class Student implements Serializable {
    private String studentId;
    private String studentName;
    private String studentEmail;
    private String studentPassword;
    private Date createdAt;
    
    public Student() {}
    
    public Student(String studentId, String studentName, String studentEmail, String studentPassword) {
        this.studentId = studentId;
        this.studentName = studentName;
        this.studentEmail = studentEmail;
        this.studentPassword = studentPassword;
    }
    
    // Getters and Setters
    public String getStudentId() { return studentId; }
    public void setStudentId(String studentId) { this.studentId = studentId; }
    
    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }
    
    public String getStudentEmail() { return studentEmail; }
    public void setStudentEmail(String studentEmail) { this.studentEmail = studentEmail; }
    
    public String getStudentPassword() { return studentPassword; }
    public void setStudentPassword(String studentPassword) { this.studentPassword = studentPassword; }
    
    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
}