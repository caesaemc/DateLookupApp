import { createApp } from "./app.js";
import { openDatabase } from "./database.js";
import { RecordsRepository } from "./recordsRepository.js";

const port = Number(process.env.PORT ?? 4000);
const dbPath = process.env.DATABASE_PATH ?? "data/app.sqlite";
const db = openDatabase(dbPath);

new RecordsRepository(db).seedIfEmpty();

createApp(db).listen(port, () => {
  console.log(`DateLookupApp API listening on http://localhost:${port}`);
});
