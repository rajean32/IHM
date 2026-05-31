package com.ihm.model.dto;

import java.time.LocalDate;

public class DailySalesDTO {
    private LocalDate date;
    private long ticketsSold;
    private double revenue;

    public DailySalesDTO() {}

    public DailySalesDTO(LocalDate date, long ticketsSold, double revenue) {
        this.date = date;
        this.ticketsSold = ticketsSold;
        this.revenue = revenue;
    }

    public LocalDate getDate() { return date; }
    public void setDate(LocalDate date) { this.date = date; }

    public long getTicketsSold() { return ticketsSold; }
    public void setTicketsSold(long ticketsSold) { this.ticketsSold = ticketsSold; }

    public double getRevenue() { return revenue; }
    public void setRevenue(double revenue) { this.revenue = revenue; }
}
