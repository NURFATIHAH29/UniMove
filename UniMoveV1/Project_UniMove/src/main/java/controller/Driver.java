/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */

/**
 *
 * @author user
 */
/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */

/**
 *
 * @author user
 */
package controller;

public class Driver {
    private int id;
    private String fullName;
    private String staffId;
    private String licenseClass;
    private String phone;
    private String status;

    // Constructor
    public Driver(int id, String fullName, String staffId, String licenseClass, String phone, String status) {
        this.id = id;
        this.fullName = fullName;
        this.staffId = staffId;
        this.licenseClass = licenseClass;
        this.phone = phone;
        this.status = status;
    }

    // Getters
    public int getId() { return id; }
    public String getFullName() { return fullName; }
    public String getStaffId() { return staffId; }
    public String getLicenseClass() { return licenseClass; }
    public String getPhone() { return phone; }
    public String getStatus() { return status; }
}