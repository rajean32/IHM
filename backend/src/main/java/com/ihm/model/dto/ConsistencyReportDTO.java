package com.ihm.model.dto;

import java.util.List;

public class ConsistencyReportDTO {

    private List<String> issues;
    private List<String> warnings;
    private long issueCount;
    private long warningCount;

    public ConsistencyReportDTO(List<String> issues, List<String> warnings) {
        this.issues = issues;
        this.warnings = warnings;
        this.issueCount = issues.size();
        this.warningCount = warnings.size();
    }

    public List<String> getIssues() { return issues; }
    public List<String> getWarnings() { return warnings; }
    public long getIssueCount() { return issueCount; }
    public long getWarningCount() { return warningCount; }
}
