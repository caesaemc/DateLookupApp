package com.datelookup.records;

import jakarta.validation.Valid;
import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class RecordsController {
  private final RecordsRepository recordsRepository;

  public RecordsController(RecordsRepository recordsRepository) {
    this.recordsRepository = recordsRepository;
  }

  @GetMapping("/health")
  Map<String, Boolean> health() {
    return Map.of("ok", true);
  }

  @GetMapping("/records")
  Map<String, Object> listRecords(
      @RequestParam(required = false) String month,
      @RequestParam(required = false) String date) {
    return Map.of("records", recordsRepository.list(month, date));
  }

  @PostMapping("/records")
  ResponseEntity<Map<String, CalendarRecord>> createRecord(@Valid @RequestBody RecordRequest request) {
    return ResponseEntity.status(HttpStatus.CREATED).body(Map.of("record", recordsRepository.create(request)));
  }

  @PutMapping("/records/{id}")
  ResponseEntity<Map<String, CalendarRecord>> updateRecord(
      @PathVariable String id,
      @Valid @RequestBody RecordRequest request) {
    CalendarRecord updated = recordsRepository.update(id, request);
    if (updated == null) {
      return ResponseEntity.notFound().build();
    }
    return ResponseEntity.ok(Map.of("record", updated));
  }

  @DeleteMapping("/records/{id}")
  ResponseEntity<Void> deleteRecord(@PathVariable String id) {
    if (!recordsRepository.delete(id)) {
      return ResponseEntity.notFound().build();
    }
    return ResponseEntity.noContent().build();
  }

  @GetMapping("/stats")
  Map<String, MonthStats> stats(@RequestParam String month) {
    return Map.of("stats", recordsRepository.stats(month));
  }
}
