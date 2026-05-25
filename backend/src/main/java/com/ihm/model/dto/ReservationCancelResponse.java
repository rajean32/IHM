package com.ihm.model.dto;

import com.fasterxml.jackson.annotation.JsonInclude;

import java.math.BigDecimal;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class ReservationCancelResponse {

    private Integer idReservation;
    private String status;
    private BigDecimal refundAmount;
    private String message;

    public ReservationCancelResponse() {}

    public Integer getIdReservation() { return idReservation; }
    public void setIdReservation(Integer idReservation) { this.idReservation = idReservation; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public BigDecimal getRefundAmount() { return refundAmount; }
    public void setRefundAmount(BigDecimal refundAmount) { this.refundAmount = refundAmount; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
}
