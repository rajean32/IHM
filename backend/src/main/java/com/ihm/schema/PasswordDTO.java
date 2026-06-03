package com.ihm.schema;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public class PasswordDTO {

    public static class ChangeRequest {
        @NotBlank(message = "Current password is required")
        private String currentPassword;
        @NotBlank(message = "New password is required")
        private String newPassword;

        public ChangeRequest() {}

        public String getCurrentPassword() { return currentPassword; }
        public void setCurrentPassword(String currentPassword) { this.currentPassword = currentPassword; }
        public String getNewPassword() { return newPassword; }
        public void setNewPassword(String newPassword) { this.newPassword = newPassword; }
    }

    public static class ResetRequest {
        @NotBlank(message = "Email is required")
        @Email(message = "Valid email is required")
        private String email;

        public ResetRequest() {}

        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
    }

    public static class ResetConfirmRequest {
        @NotBlank(message = "Email is required")
        @Email(message = "Valid email is required")
        private String email;
        @NotBlank(message = "Reset token is required")
        private String token;
        @NotBlank(message = "New password is required")
        private String newPassword;

        public ResetConfirmRequest() {}

        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        public String getToken() { return token; }
        public void setToken(String token) { this.token = token; }
        public String getNewPassword() { return newPassword; }
        public void setNewPassword(String newPassword) { this.newPassword = newPassword; }
    }

    public static class AdminResetRequest {
        @NotBlank(message = "User code is required")
        private String codeUtilisateur;
        @NotBlank(message = "New password is required")
        private String newPassword;

        public AdminResetRequest() {}

        public String getCodeUtilisateur() { return codeUtilisateur; }
        public void setCodeUtilisateur(String codeUtilisateur) { this.codeUtilisateur = codeUtilisateur; }
        public String getNewPassword() { return newPassword; }
        public void setNewPassword(String newPassword) { this.newPassword = newPassword; }
    }
}
