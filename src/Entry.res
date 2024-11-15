open Types

@react.component
let make = (~input: array<todo>, ~logout) => {
  let todos = Common.groupByAndSort(input, x => x.parent_todo->Nullable.toOption, x => x.position)
  let filterer = (arr, c) => {
    arr->Array.filter(x => c.modes_shown->Array.includes(x.mode))
  }

  let checkIfHiddenChildren = (arr, c) => {
    !(arr->Array.every(x => c.modes_shown->Array.includes(x.mode)))
  }

  let rec recurse = (
    sibs: array<todo>,
    depth: int,
    parent: Nullable.t<todo>,
    tios: array<todo>,
    parentIndex: int,
    showAll: bool,
  ) => {
    sibs->Array.reduceWithIndex([], (a, self, index) => {
      let (children, des) =
        todos
        ->SMap.get(self.id)
        ->Option.mapOr(([], []), children => {
          (
            children,
            recurse(
              showAll ? children : filterer(children, self),
              depth + 1,
              self->Value,
              sibs,
              index,
              showAll,
            ),
          )
        })

      let newItem: todoRelation = {
        self,
        depth,
        parent,
        parentIndex,
        tios,
        index,
        children,
        sibs,
        hasHiddenChildren: showAll ? false : checkIfHiddenChildren(children, self),
      }
      a->Array.concat([newItem])->Array.concat(des)
    })
  }

  let todosToDisplay =
    todos
    ->SMap.get("root")
    ->Option.mapOr([], root =>
      recurse(root->Array.filter(x => x.mode == Working), 0, Null, [], 0, false)
    )

  let allTodos =
    todos
    ->SMap.get("root")
    ->Option.mapOr([], root => recurse(root, 0, Null, [], 0, true))

  <Dashboard
    allTodos={allTodos}
    todos={todosToDisplay}
    rootTodos={todos
    ->SMap.get("root")
    ->Option.getOr([])}
    logout={logout}
  />
}

let default = make
