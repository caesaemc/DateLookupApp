package com.datelookup.records;

import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Sql(statements = "DELETE FROM records", executionPhase = Sql.ExecutionPhase.BEFORE_TEST_METHOD)
class RecordsControllerTest {
  @Autowired
  private MockMvc mockMvc;

  @Test
  void createsAndListsRecordsByDate() throws Exception {
    mockMvc.perform(post("/api/records")
        .contentType("application/json")
        .content("""
            {
              "category": "activity",
              "title": "晨跑",
              "date": "2026-06-02",
              "time": "07:30",
              "note": "跑步很舒服",
              "mood": "适中",
              "details": { "distanceKm": 5.02, "calories": 320 }
            }
            """))
        .andExpect(status().isCreated())
        .andExpect(jsonPath("$.record.id").exists());

    mockMvc.perform(get("/api/records?date=2026-06-02"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.records", hasSize(1)))
        .andExpect(jsonPath("$.records[0].title").value("晨跑"));
  }

  @Test
  void aggregatesMonthlyStats() throws Exception {
    mockMvc.perform(post("/api/records")
        .contentType("application/json")
        .content("""
            {
              "category": "meal",
              "title": "早餐",
              "date": "2026-06-02",
              "time": "08:10",
              "details": { "calories": 360 }
            }
            """))
        .andExpect(status().isCreated());

    mockMvc.perform(post("/api/records")
        .contentType("application/json")
        .content("""
            {
              "category": "expense",
              "title": "午餐",
              "date": "2026-06-02",
              "time": "12:10",
              "details": { "amount": 48 }
            }
            """))
        .andExpect(status().isCreated());

    mockMvc.perform(get("/api/stats?month=2026-06"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.stats.mealCalories").value(360))
        .andExpect(jsonPath("$.stats.expenseAmount").value(48))
        .andExpect(jsonPath("$.stats.recordDays").value(1));
  }

  @Test
  void deletesRecords() throws Exception {
    String response = mockMvc.perform(post("/api/records")
        .contentType("application/json")
        .content("""
            {
              "category": "tip",
              "title": "今日 Tips",
              "date": "2026-06-02",
              "time": "21:10",
              "details": { "tag": "健康" }
            }
            """))
        .andExpect(status().isCreated())
        .andReturn()
        .getResponse()
        .getContentAsString();

    String id = response.replaceAll(".*\\\"id\\\":\\\"([^\\\"]+)\\\".*", "$1");
    mockMvc.perform(MockMvcRequestBuilders.delete("/api/records/" + id))
        .andExpect(status().isNoContent());
  }
}
