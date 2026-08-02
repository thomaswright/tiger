import { describe, expect, it } from "vitest";
import type { Todo } from "./shared/domain";
import {
  applyMove,
  destinationIndexFromTarget,
  getSortedSiblings,
  getSubtree,
  planDirectionalMove,
  planMoveTo,
  planProjectedMove,
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

describe("todo subtrees", () => {
  it("includes descendants but not unrelated siblings", () => {
    const todos = [
      todo("root", null, 100),
      todo("child", "root", 100),
      todo("grandchild", "child", 100),
      todo("other", null, 200),
    ];
    expect(getSubtree(todos, "root").map((item) => item.id)).toEqual([
      "root",
      "child",
      "grandchild",
    ]);
  });
});

describe("sibling sorting", () => {
  it("sorts due dates ascending with undated todos last", () => {
    const todos = [
      { ...todo("undated", null, 100), dueDate: null },
      { ...todo("later", null, 200), dueDate: "2026-08-20" },
      { ...todo("sooner", null, 300), dueDate: "2026-08-05" },
    ];

    expect(
      getSortedSiblings(todos, null, "dueDate").map((item) => item.id),
    ).toEqual(["sooner", "later", "undated"]);
  });

  it("uses canonical status order and only sorts within a parent", () => {
    const todos = [
      { ...todo("root-done", null, 100), status: "ResolveDone" as const },
      { ...todo("root-future", null, 200), status: "Future" as const },
      { ...todo("parent", null, 300), status: "Unsorted" as const },
      { ...todo("child-paused", "parent", 100), status: "Paused" as const },
      { ...todo("child-underway", "parent", 200), status: "Underway" as const },
    ];

    expect(
      getSortedSiblings(todos, null, "status").map((item) => item.id),
    ).toEqual(["parent", "root-future", "root-done"]);
    expect(
      getSortedSiblings(todos, "parent", "status").map((item) => item.id),
    ).toEqual(["child-underway", "child-paused"]);
  });
});

describe("drag projection", () => {
  const todos = [
    todo("previous", null, 100),
    todo("previous-child", "previous", 100),
    todo("parent", null, 200),
    todo("moving-child", "parent", 100),
    todo("next", null, 300),
  ];

  it("outdents a child above its former parent when dragged left", () => {
    expect(
      planProjectedMove(todos, "moving-child", "previous", 1, -20),
    ).toMatchObject({
      parentId: null,
      previousId: "previous",
      nextId: "parent",
    });
  });

  it("makes the same vertical drop a child when kept indented", () => {
    expect(
      planProjectedMove(todos, "moving-child", "previous", 1, 0),
    ).toMatchObject({
      parentId: "previous",
      previousId: "previous-child",
      nextId: null,
    });
  });

  it("indents a root todo beneath the item above it when dragged right", () => {
    const roots = [todo("a", null, 100), todo("b", null, 200)];
    expect(planProjectedMove(roots, "b", null, 1, 20)).toMatchObject({
      parentId: "a",
      previousId: null,
      nextId: null,
    });
  });

  it("never projects a parent into its own subtree", () => {
    expect(planProjectedMove(todos, "parent", "moving-child", 0, 20)).toBeNull();
  });
});

describe("drop target indexing", () => {
  it("accounts for removing the source before a same-group insertion", () => {
    expect(destinationIndexFromTarget(1, false, true, 0)).toBe(0);
    expect(destinationIndexFromTarget(1, true, true, 0)).toBe(1);
  });

  it("uses the target index directly when changing parents", () => {
    expect(destinationIndexFromTarget(1, false, false, 0)).toBe(1);
    expect(destinationIndexFromTarget(1, true, false, 0)).toBe(2);
  });
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
