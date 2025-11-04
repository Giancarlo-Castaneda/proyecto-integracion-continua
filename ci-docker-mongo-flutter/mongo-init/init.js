// /docker-entrypoint-initdb.d/init.js
db = db.getSiblingDB('appdb');
db.messages.updateOne(
  { _id: "welcome" },
  { $set: { text: "¡Hola desde MongoDB!" } },
  { upsert: true }
);