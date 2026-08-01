import { describe, expect, it } from "vitest";
import { formatDateValue, parseDateValue } from "./date";

describe("date-only values", () => {
  it("round trips without applying a timezone offset", () => {
    const date = parseDateValue("2026-08-01");
    expect(date).not.toBeNull();
    expect(formatDateValue(date!)).toBe("2026-08-01");
  });

  it("rejects malformed and impossible dates", () => {
    expect(parseDateValue("2026-02-31")).toBeNull();
    expect(parseDateValue("August 1")).toBeNull();
    expect(parseDateValue(null)).toBeNull();
  });
});
