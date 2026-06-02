package com.datelookup.records;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.time.ZoneOffset;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class RecordsRepository {
  private static final TypeReference<Map<String, Object>> DETAILS_TYPE = new TypeReference<>() {};

  private final JdbcTemplate jdbcTemplate;
  private final ObjectMapper objectMapper;

  public RecordsRepository(
      JdbcTemplate jdbcTemplate,
      ObjectMapper objectMapper,
      @Value("${app.seed-data:true}") boolean seedData) {
    this.jdbcTemplate = jdbcTemplate;
    this.objectMapper = objectMapper;
    initialize();
    if (seedData) {
      seedIfEmpty();
    }
  }

  public List<CalendarRecord> list(String month, String date) {
    if (date != null && !date.isBlank()) {
      return jdbcTemplate.query(
          "SELECT * FROM records WHERE date = ? ORDER BY time ASC, created_at ASC",
          this::mapRow,
          date);
    }

    if (month != null && !month.isBlank()) {
      validateMonth(month);
      return jdbcTemplate.query(
          "SELECT * FROM records WHERE substr(date, 1, 7) = ? ORDER BY date ASC, time ASC",
          this::mapRow,
          month);
    }

    return jdbcTemplate.query(
        "SELECT * FROM records ORDER BY date DESC, time DESC LIMIT 200",
        this::mapRow);
  }

  public CalendarRecord create(RecordRequest input) {
    Instant now = Instant.now();
    CalendarRecord record = new CalendarRecord(
        UUID.randomUUID().toString(),
        input.category(),
        input.title(),
        input.date(),
        input.time(),
        input.safeNote(),
        input.safeMood(),
        input.safeDetails(),
        now,
        now);

    jdbcTemplate.update(
        """
        INSERT INTO records
          (id, category, title, date, time, note, mood, details, created_at, updated_at)
        VALUES
          (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """,
        record.id(),
        record.category().name(),
        record.title(),
        record.date().toString(),
        record.time().toString(),
        record.note(),
        record.mood(),
        toJson(record.details()),
        record.createdAt().toString(),
        record.updatedAt().toString());

    return record;
  }

  public CalendarRecord update(String id, RecordRequest input) {
    CalendarRecord existing = find(id);
    if (existing == null) {
      return null;
    }

    Instant now = Instant.now();
    CalendarRecord updated = new CalendarRecord(
        id,
        input.category(),
        input.title(),
        input.date(),
        input.time(),
        input.safeNote(),
        input.safeMood(),
        input.safeDetails(),
        existing.createdAt(),
        now);

    jdbcTemplate.update(
        """
        UPDATE records SET
          category = ?,
          title = ?,
          date = ?,
          time = ?,
          note = ?,
          mood = ?,
          details = ?,
          updated_at = ?
        WHERE id = ?
        """,
        updated.category().name(),
        updated.title(),
        updated.date().toString(),
        updated.time().toString(),
        updated.note(),
        updated.mood(),
        toJson(updated.details()),
        updated.updatedAt().toString(),
        id);

    return updated;
  }

  public boolean delete(String id) {
    return jdbcTemplate.update("DELETE FROM records WHERE id = ?", id) > 0;
  }

  public CalendarRecord find(String id) {
    List<CalendarRecord> records = jdbcTemplate.query(
        "SELECT * FROM records WHERE id = ?",
        this::mapRow,
        id);
    return records.isEmpty() ? null : records.get(0);
  }

  public MonthStats stats(String month) {
    validateMonth(month);
    List<CalendarRecord> records = list(month, null);
    EnumMap<RecordCategory, Integer> counts = new EnumMap<>(RecordCategory.class);
    for (RecordCategory category : RecordCategory.values()) {
      counts.put(category, 0);
    }

    double activityDistanceKm = 0;
    double activityCalories = 0;
    double mealCalories = 0;
    double expenseAmount = 0;

    for (CalendarRecord record : records) {
      counts.merge(record.category(), 1, Integer::sum);
      if (record.category() == RecordCategory.activity) {
        activityDistanceKm += number(record.details().get("distanceKm"));
        activityCalories += number(record.details().get("calories"));
      }
      if (record.category() == RecordCategory.meal) {
        mealCalories += number(record.details().get("calories"));
      }
      if (record.category() == RecordCategory.expense) {
        expenseAmount += number(record.details().get("amount"));
      }
    }

    Set<LocalDate> days = records.stream().map(CalendarRecord::date).collect(Collectors.toSet());
    return new MonthStats(month, activityDistanceKm, activityCalories, mealCalories, expenseAmount, days.size(), counts);
  }

  private void initialize() {
    jdbcTemplate.execute(
        """
        CREATE TABLE IF NOT EXISTS records (
          id TEXT PRIMARY KEY,
          category TEXT NOT NULL,
          title TEXT NOT NULL,
          date TEXT NOT NULL,
          time TEXT NOT NULL,
          note TEXT NOT NULL DEFAULT '',
          mood TEXT NOT NULL DEFAULT '',
          details TEXT NOT NULL DEFAULT '{}',
          created_at TIMESTAMP NOT NULL,
          updated_at TIMESTAMP NOT NULL
        )
        """);
    jdbcTemplate.execute("CREATE INDEX IF NOT EXISTS idx_records_date ON records(date)");
    jdbcTemplate.execute("CREATE INDEX IF NOT EXISTS idx_records_month ON records(substr(date, 1, 7))");
    jdbcTemplate.execute("CREATE INDEX IF NOT EXISTS idx_records_category ON records(category)");
  }

  private void seedIfEmpty() {
    Integer count = jdbcTemplate.queryForObject("SELECT COUNT(*) FROM records", Integer.class);
    if (count != null && count > 0) {
      return;
    }

    LocalDate today = LocalDate.now();
    create(new RecordRequest(RecordCategory.activity, "晨跑", today, java.time.LocalTime.of(7, 30), "状态轻松，配速稳定。", "适中",
        Map.of("distanceKm", 5.02, "durationMinutes", 30, "calories", 320, "intensity", "适中")));
    create(new RecordRequest(RecordCategory.meal, "早餐", today, java.time.LocalTime.of(8, 25), "燕麦、鸡蛋和水果。", "轻松",
        Map.of("calories", 360, "protein", 22, "carbs", 45, "fat", 10)));
    create(new RecordRequest(RecordCategory.expense, "咖啡", today, java.time.LocalTime.of(12, 30), "午后提神。", "",
        Map.of("amount", 25, "category", "餐饮")));
    create(new RecordRequest(RecordCategory.tip, "今日 Tips", today, java.time.LocalTime.of(21, 30), "晚间拉伸 10 分钟，明天继续保持。", "愉快",
        Map.of("tag", "健康")));
  }

  private CalendarRecord mapRow(ResultSet rs, int rowNum) throws SQLException {
    return new CalendarRecord(
        rs.getString("id"),
        RecordCategory.valueOf(rs.getString("category")),
        rs.getString("title"),
        LocalDate.parse(rs.getString("date")),
        java.time.LocalTime.parse(rs.getString("time")),
        rs.getString("note"),
        rs.getString("mood"),
        fromJson(rs.getString("details")),
        parseInstant(rs.getString("created_at")),
        parseInstant(rs.getString("updated_at")));
  }

  private Map<String, Object> fromJson(String value) {
    try {
      return objectMapper.readValue(value, DETAILS_TYPE);
    } catch (Exception error) {
      throw new IllegalStateException("Failed to parse record details", error);
    }
  }

  private String toJson(Map<String, Object> value) {
    try {
      return objectMapper.writeValueAsString(value);
    } catch (Exception error) {
      throw new IllegalStateException("Failed to serialize record details", error);
    }
  }

  private static double number(Object value) {
    if (value instanceof Number number) {
      return number.doubleValue();
    }
    if (value instanceof String string && !string.isBlank()) {
      return Double.parseDouble(string);
    }
    return 0;
  }

  private static Instant parseInstant(String value) {
    if (value.matches("\\d+")) {
      return Instant.ofEpochMilli(Long.parseLong(value));
    }
    try {
      return Instant.parse(value);
    } catch (Exception ignored) {
      return LocalDateTime.parse(value.replace(' ', 'T')).toInstant(ZoneOffset.UTC);
    }
  }

  private static void validateMonth(String month) {
    YearMonth.parse(month);
  }
}
