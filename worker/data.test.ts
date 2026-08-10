import { describe, expect, it } from "vitest";
import {
  DataError,
  parseCreateDailySummaryInput,
  parseCreateTodoInput,
  parseDeleteTodoInput,
  parseRestoreTodosInput,
  parseUpdateDailySummaryInput,
  parseUpdateTodoInput,
} from "./data";

const token = "33333333-3333-4333-8333-333333333333";
const todoId = "11111111-1111-4111-8111-111111111111";
const neighborId = "22222222-2222-4222-8222-222222222222";

describe("daily summary input", () => {
  it("accepts a blank summary for a real calendar date", () => {
    expect(
      parseCreateDailySummaryInput({
        id: todoId,
        date: "2026-08-10",
        body: "",
      }),
    ).toEqual({
      id: todoId,
      date: "2026-08-10",
      body: "",
    });
  });

  it("rejects impossible dates and oversized content", () => {
    expect(() =>
      parseCreateDailySummaryInput({
        id: todoId,
        date: "2026-02-30",
        body: "",
      }),
    ).toThrow(new DataError("Invalid daily summary date", 400));
    expect(() =>
      parseUpdateDailySummaryInput({ body: "x".repeat(20001), version: 1 }),
    ).toThrow(new DataError("Daily summary body is too long", 400));
  });

  it("requires a version and a body", () => {
    expect(
      parseUpdateDailySummaryInput({ body: "Reflection", version: 2 }),
    ).toEqual({ body: "Reflection", version: 2 });
    expect(() => parseUpdateDailySummaryInput({ version: 2 })).toThrow(
      new DataError("Daily summary body is required", 400),
    );
  });
});

describe("create input", () => {
  it("allows a blank title for a newly focused inline todo", () => {
    expect(parseCreateTodoInput({
      id: todoId,
      title: "",
      parentId: null,
      previousId: null,
      nextId: null,
      status: "Unsorted",
    }).title).toBe("");
  });

  it("accepts semantic placement neighbors", () => {
    expect(parseCreateTodoInput({
      id: todoId,
      title: "New todo",
      parentId: null,
      previousId: neighborId,
      nextId: null,
      status: "Unsorted",
    })).toMatchObject({
      id: todoId,
      previousId: neighborId,
      nextId: null,
    });
  });

  it("rejects invalid or identical placement neighbors", () => {
    const input = {
      id: todoId,
      title: "New todo",
      parentId: null,
      previousId: neighborId,
      nextId: neighborId,
      status: "Unsorted",
    };
    expect(() => parseCreateTodoInput(input)).toThrow(
      new DataError("Create neighbors must be different", 400),
    );
    expect(() => parseCreateTodoInput({ ...input, nextId: "invalid" })).toThrow(
      new DataError("Invalid create neighbors", 400),
    );
  });
});

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
