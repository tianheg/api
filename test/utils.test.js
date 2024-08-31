import tap from "tap";
import { getPaginatedData } from "../routes/utils.js";

tap.test("getPaginatedData", async (t) => {
  const data = [
    { id: 1, name: "John" },
    { id: 2, name: "Jane" },
    { id: 3, name: "Bob" },
  ];

  t.test("should return paginated data with default values", async (t) => {
    const result = getPaginatedData(data, "", 1, 3);

    t.same(result, {
      page: 1,
      limit: 3,
      total: 3,
      totalPages: 1,
      data: [
        { id: 1, name: "John" },
        { id: 2, name: "Jane" },
        { id: 3, name: "Bob" },
      ],
    });
  });

  t.test("should return paginated data with custom values", async (t) => {
    const result = getPaginatedData(data, "j", 2, 1);

    t.same(result, {
      page: 2,
      limit: 1,
      total: 2,
      totalPages: 2,
      data: [{ id: 2, name: "Jane" }],
    });
  });

  t.end();
});
