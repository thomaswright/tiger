import { describe, expect, it } from "vitest";
import type { Todo } from "./shared/domain";
import {
  applyMove,
  planDirectionalMove,
  planMoveTo,
} from "./tree";

const todo = (
  id: string,
  parentId: string | null,
  sortKey: number,
): Todo => ({
  id,
  listId: "list",
  parentId,
  title: id,
  notes: "",
  status: "Unsorted",
  dueDate: null,
  sortKey,
  version: 1,
  createdAt: "2026-01-01T00:00:00.000Z",
  updatedAt: "2026-01-01T00:00:00.000Z",
});

describe("tree move planning", () => {
  const todos = [
    todo("a", null, 100),
    todo("b", null, 200),
    todo("c", null, 300),
    todo("b-child", "b", 100),
  ];

  it("plans sibling moves from semantic neighbors", () => {
    expect(planDirectionalMove(todos, "b", "up")).toMatchObject({
      parentId: null,
      previousId: null,
      nextId: "a",
    });
    expect(planDirectionalMove(todos, "b", "down")).toMatchObject({
      parentId: null,
      previousId: "c",
      nextId: null,
    });
  });

  it("indents under the previous sibling after its existing children", () => {
    expect(planDirectionalMove(todos, "c", "indent")).toMatchObject({
      parentId: "b",
      previousId: "b-child",
      nextId: null,
    });
  });

  it("outdents immediately after its parent", () => {
    expect(planDirectionalMove(todos, "b-child", "outdent")).toMatchObject({
      parentId: null,
      previousId: "b",
      nextId: "c",
    });
  });

  it("returns null for impossible directional moves", () => {
    expect(planDirectionalMove(todos, "a", "up")).toBeNull();
    expect(planDirectionalMove(todos, "a", "indent")).toBeNull();
    expect(planDirectionalMove(todos, "a", "outdent")).toBeNull();
  });
});

describe("optimistic tree moves", () => {
  it("reparents immediately without mutating the previous snapshot", () => {
    const todos = [todo("a", null, 100), todo("b", null, 200)];
    const move = planMoveTo(todos, "b", "a", 0);
    expect(move).not.toBeNull();

    const moved = applyMove(todos, "b", move!);
    expect(moved.find((item) => item.id === "b")).toMatchObject({
      parentId: "a",
      sortKey: 100,
      version: 2,
    });
    expect(todos.find((item) => item.id === "b")).toMatchObject({
      parentId: null,
      version: 1,
    });
  });
});
