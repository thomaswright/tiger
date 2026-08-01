import { describe, expect, it } from "vitest";
import {
  DataError,
  parseDeleteTodoInput,
  parseRestoreTodosInput,
  parseUpdateTodoInput,
} from "./data";

const token = "33333333-3333-4333-8333-333333333333";

describe("todo detail input", () => {
  it("accepts notes, a real calendar date, and clearing the date", () => {
    expect(parseUpdateTodoInput({ notes: "Context", dueDate: "2026-08-31", version: 2 }))
      .toEqual({ notes: "Context", dueDate: "2026-08-31", version: 2 });
    expect(parseUpdateTodoInput({ dueDate: null, version: 3 })).toEqual({
      dueDate: null,
      version: 3,
    });
  });

  it("rejects impossible calendar dates", () => {
    expect(() => parseUpdateTodoInput({ dueDate: "2026-02-31", version: 1 }))
      .toThrow(new DataError("Invalid due date", 400));
  });
});

describe("delete and restore input", () => {
  it("requires a UUID token and optimistic-concurrency version", () => {
    expect(parseDeleteTodoInput({ deletionToken: token, version: 4 })).toEqual({
      deletionToken: token,
      version: 4,
    });
    expect(parseRestoreTodosInput({ deletionToken: token })).toBe(token);
    expect(() => parseDeleteTodoInput({ deletionToken: "guessable", version: 4 }))
      .toThrow(new DataError("Invalid deletion token", 400));
  });
});
