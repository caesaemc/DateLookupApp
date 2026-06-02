package com.datelookup.records;

import com.fasterxml.jackson.annotation.JsonFormat;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.Map;

public record CalendarRecord(
    String id,
    RecordCategory category,
    String title,
    LocalDate date,
    @JsonFormat(pattern = "HH:mm")
    LocalTime time,
    String note,
    String mood,
    Map<String, Object> details,
    Instant createdAt,
    Instant updatedAt) {
}
