package com.ihm.schema;

import com.fasterxml.jackson.annotation.JsonInclude;
import java.time.LocalDateTime;
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ApiResponse<T> {
    private boolean success;
    private int status;
    private String message;
    private T data;
    private String error;
    private LocalDateTime timestamp;
    public ApiResponse() { this.timestamp = LocalDateTime.now(); }
    public static <T> ApiResponse<T> success(int status, String message, T data) {
        ApiResponse<T> r = new ApiResponse<>();
        r.success = true; r.status = status; r.message = message; r.data = data;
        return r;
    }
    public static <T> ApiResponse<T> success(int status, String message) {
        ApiResponse<T> r = new ApiResponse<>();
        r.success = true; r.status = status; r.message = message;
        return r;
    }
    public static <T> ApiResponse<T> error(int status, String message, String error) {
        ApiResponse<T> r = new ApiResponse<>();
        r.success = false; r.status = status; r.message = message; r.error = error;
        return r;
    }
    public boolean isSuccess() { return success; }
    public void setSuccess(boolean success) { this.success = success; }
    public int getStatus() { return status; }
    public void setStatus(int status) { this.status = status; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public T getData() { return data; }
    public void setData(T data) { this.data = data; }
    public String getError() { return error; }
    public void setError(String error) { this.error = error; }
    public LocalDateTime getTimestamp() { return timestamp; }
    public void setTimestamp(LocalDateTime timestamp) { this.timestamp = timestamp; }
}
