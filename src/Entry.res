open Types

@react.component
let make = (~input: array<todo>, ~logout) => {
  let todos = input->Array.reduce(SMap.empty, (a, c) => {
    let key = c.parent_todo->Nullable.toOption->Option.getOr("root")

    a->SMap.update(key, o =>
      switch o {
      | None => Some([c])
      | Some(v) => Some(v->Array.concat([c]))
      }
    )
  })
  // ->SMap.mapWithKey((parent_todo, v) =>
  //   v->Array.toSorted((a, b) => {
  //     let result = ref(0.)

  //     // Date
  //     if result.contents == 0. {
  //       result :=
  //         switch (
  //           a.target_date->Nullable.toOption->Option.map(Date.fromString),
  //           b.target_date->Nullable.toOption->Option.map(Date.fromString),
  //         ) {
  //         | (Some(_), None) => -1.
  //         | (None, Some(_)) => 1.
  //         | (None, None) => 0.
  //         | (Some(a), Some(b)) => Date.compare(a, b)
  //         }
  //     }

  //     // Mode
  //     if result.contents == 0. {
  //       result := a.mode->modeCompare -. b.mode->modeCompare
  //     }

  //     Text
  //     if result.contents == 0. {
  //       result :=
  //         String.localeCompare(
  //           a.text->Nullable.toOption->Option.getOr(""),
  //           b.text->Nullable.toOption->Option.getOr(""),
  //         )
  //     }

  //     result.contents
  //   })
  // )

  let filterer = (arr, c) => {
    arr->Array.filter(x => c.modes_shown->Array.includes(x.mode))
  }

  let checkIfHiddenChildren = (arr, c) => {
    !(arr->Array.every(x => c.modes_shown->Array.includes(x.mode)))
  }

  let checkIfArchivedChildren = (arr, c) => {
    arr->Array.some(v => v.mode == Archive)
  }

  let checkIfStashedChildren = (arr, c) => {
    arr->Array.some(v => v.mode == Stashed)
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
          let hasStashed = ref(false)
          let hasArchived = ref(false)

          let children =
            children
            ->Array.toSorted(
              (a, b) => {
                let result = ref(0.)

                // // Date
                // if result.contents == 0. {
                //   result :=
                //     switch (
                //       a.target_date->Nullable.toOption->Option.map(Date.fromString),
                //       b.target_date->Nullable.toOption->Option.map(Date.fromString),
                //     ) {
                //     | (Some(_), None) => -1.
                //     | (None, Some(_)) => 1.
                //     | (None, None) => 0.
                //     | (Some(a), Some(b)) => Date.compare(a, b)
                //     }
                // }

                // Mode
                if result.contents == 0. {
                  result := a.mode->modeCompare -. b.mode->modeCompare
                }

                // Order
                if result.contents == 0. {
                  let len = self.order->Array.length
                  let aIndex = self.order->Array.indexOf(a.id)
                  let bIndex = self.order->Array.indexOf(b.id)
                  let aIndex = aIndex == -1 ? len : aIndex
                  let bIndex = bIndex == -1 ? len : bIndex

                  result := (aIndex - bIndex)->Int.toFloat
                }

                // Text
                if result.contents == 0. {
                  result :=
                    String.localeCompare(
                      a.text->Nullable.toOption->Option.getOr(""),
                      b.text->Nullable.toOption->Option.getOr(""),
                    )
                }

                result.contents
              },
            )
            ->Array.map(
              child => {
                if !hasStashed.contents && child.mode == Stashed {
                  hasStashed := true

                  {
                    ...child,
                    is_first_of_mode: Some(Stashed),
                  }
                } else if !hasArchived.contents && child.mode == Archive {
                  hasArchived := true

                  {
                    ...child,
                    is_first_of_mode: Some(Archive),
                  }
                } else {
                  child
                }
              },
            )
          // + (self.mode == Stashed || self.mode == Archive ? 1 : 0)
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
        hasArchivedChildren: checkIfArchivedChildren(children, self),
        hasStashedChildren: checkIfStashedChildren(children, self),
        hasHiddenChildren: showAll ? false : checkIfHiddenChildren(children, self),
      }
      a->Array.concat([newItem])->Array.concat(des)
    })
  }
  todos
  ->SMap.get("root")
  ->Option.mapOr(React.null, root => {
    let todosToDisplay = recurse(root->Array.filter(x => x.mode == Working), 0, Null, [], 0, false)
    todosToDisplay
    ->Array.find(x => x.depth == 0)
    ->Option.mapOr(React.null, rootTodo => {
      <Dashboard
        allTodos={recurse(root, 0, Null, [], 0, true)}
        todos={todosToDisplay->Array.filter(x => x.depth != 0)}
        logout={logout}
        root={rootTodo}
      />
    })
  })
}

let default = make
