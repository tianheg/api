export default defineEventHandler(async () => {
  const data = await import("~/data/words.json");
  return data.default;
});
