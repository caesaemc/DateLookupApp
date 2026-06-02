import cors from "cors";
import express from "express";
import type { AppDatabase } from "./database.js";
import { recordSchema } from "./domain.js";
import { RecordsRepository } from "./recordsRepository.js";

export function createApp(db: AppDatabase) {
  const app = express();
  const records = new RecordsRepository(db);

  app.use(cors());
  app.use(express.json());

  app.get("/api/health", (_req, res) => {
    res.json({ ok: true });
  });

  app.get("/api/records", (req, res) => {
    try {
      const month = typeof req.query.month === "string" ? req.query.month : undefined;
      const date = typeof req.query.date === "string" ? req.query.date : undefined;
      res.json({ records: records.list({ month, date }) });
    } catch (error) {
      res.status(400).json({ error: error instanceof Error ? error.message : "Invalid request" });
    }
  });

  app.post("/api/records", (req, res) => {
    const parsed = recordSchema.safeParse(req.body);
    if (!parsed.success) {
      res.status(400).json({ error: parsed.error.flatten() });
      return;
    }

    res.status(201).json({ record: records.create(parsed.data) });
  });

  app.put("/api/records/:id", (req, res) => {
    const parsed = recordSchema.safeParse(req.body);
    if (!parsed.success) {
      res.status(400).json({ error: parsed.error.flatten() });
      return;
    }

    const record = records.update(req.params.id, parsed.data);
    if (!record) {
      res.status(404).json({ error: "Record not found" });
      return;
    }

    res.json({ record });
  });

  app.delete("/api/records/:id", (req, res) => {
    if (!records.delete(req.params.id)) {
      res.status(404).json({ error: "Record not found" });
      return;
    }

    res.status(204).end();
  });

  app.get("/api/stats", (req, res) => {
    try {
      const month = typeof req.query.month === "string" ? req.query.month : new Date().toISOString().slice(0, 7);
      res.json({ stats: records.stats(month) });
    } catch (error) {
      res.status(400).json({ error: error instanceof Error ? error.message : "Invalid request" });
    }
  });

  return app;
}
