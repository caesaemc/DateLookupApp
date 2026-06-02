package com.datelookup.records;

import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.HashMap;
import java.util.Map;

public record RecordRequest(
    @NotNull RecordCategory category,
    @NotBlank @Size(max = 80) String title,
    @NotNull LocalDate date,
    @JsonFormat(pattern = "HH:mm")
    @NotNull LocalTime time,
    @Size(max = 500) String note,
    @Size(max = 20) String mood,
    Map<String, Object> details) {

  public String safeNote() {
    return note == null ? "" : note;
  }

  public String safeMood() {
    return mood == null ? "" : mood;
  }

  public Map<String, Object> safeDetails() {
    return details == null ? new HashMap<>() : details;
  }
}
