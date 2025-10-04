package com.auren.model.dto;

import java.time.LocalDate;
import lombok.Data;

@Data
public class InsightsRequest {
    private LocalDate from;
    private LocalDate to;
}
