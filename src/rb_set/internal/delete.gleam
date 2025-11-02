import gleam/option.{type Option, None, Some}

import rb_set/internal/core.{type RBNode, Black, RBNode, Red}

type CompareRes {
  Left
  Right
  NoOne
}

fn find_next_key(node: RBNode(member)) -> member {
  // Спускается вниз пока есть левый ребёнокк и возвращает ключ последнего левого ребёнка
  case node {
    RBNode(_, Some(left), _, _) -> find_next_key(left)
    RBNode(val, _, _, _) -> val
  }
}

fn delete_next_key(
  init_node: RBNode(member),
  node: RBNode(member),
) -> Option(RBNode(member)) {
  // Спускается вниз пока есть левый ребёнокк и удаляет последнего левого ребёнка
  case node {
    RBNode(_, Some(left), _, _) ->
      case left {
        RBNode(_, Some(_), _, _) -> delete_next_key(init_node, left)
        RBNode(_, None, _, _) -> delete_impl(Some(node), left)
      }
    RBNode(_, None, _, _) -> delete_impl(Some(init_node), node)
  }
}

fn delete_impl(
  parent: Option(RBNode(member)),
  node: RBNode(member),
) -> Option(RBNode(member)) {
  case parent {
    Some(some_parent) ->
      case some_parent {
        RBNode(_, Some(left_uncle), Some(_right_uncle), _) ->
          case node {
            // Если у node оба ребёнка, то на место node ставим следующее значение ключа (один раз вправо и до конца влево)
            RBNode(_, Some(left), Some(right), color) -> {
              let next_key = find_next_key(right)
              let with_deleted_next_key = delete_next_key(node, right)
              let new_node =
                RBNode(next_key, Some(left), with_deleted_next_key, color)
              case node == left_uncle {
                True ->
                  Some(RBNode(
                    some_parent.value,
                    Some(new_node),
                    some_parent.right,
                    some_parent.color,
                  ))
                False ->
                  Some(RBNode(
                    some_parent.value,
                    some_parent.left,
                    Some(new_node),
                    some_parent.color,
                  ))
              }
            }
            RBNode(_, Some(left), None, _) -> {
              // Если у node один ребёнок, то поднимаем его на место node
              case node == left_uncle {
                True ->
                  Some(RBNode(
                    some_parent.value,
                    Some(left),
                    some_parent.right,
                    some_parent.color,
                  ))
                False ->
                  Some(RBNode(
                    some_parent.value,
                    some_parent.left,
                    Some(left),
                    some_parent.color,
                  ))
              }
            }
            RBNode(_, None, Some(right), _) -> {
              // Если у node один ребёнок, то поднимаем его на место node
              case node == left_uncle {
                True ->
                  Some(RBNode(
                    some_parent.value,
                    Some(right),
                    some_parent.right,
                    some_parent.color,
                  ))
                False ->
                  Some(RBNode(
                    some_parent.value,
                    some_parent.left,
                    Some(right),
                    some_parent.color,
                  ))
              }
            }
            RBNode(_, None, None, _) -> {
              // Если детей нет, то просто удаляем узел
              case node == left_uncle {
                True ->
                  Some(RBNode(
                    some_parent.value,
                    None,
                    some_parent.right,
                    some_parent.color,
                  ))
                False ->
                  Some(RBNode(
                    some_parent.value,
                    some_parent.left,
                    None,
                    some_parent.color,
                  ))
              }
            }
          }
        RBNode(p_val, None, Some(right_uncle), p_color) ->
          case node == right_uncle {
            // Если node - единственный ребёнок parent, то детей у него быть не должно (нарушение балансировки)
            True -> Some(RBNode(p_val, None, None, p_color))
            False -> panic
          }
        RBNode(p_val, Some(left_uncle), None, p_color) ->
          case node == left_uncle {
            // Если node - единственный ребёнок parent, то детей у него быть не должно (нарушение балансировки)
            True -> Some(RBNode(p_val, None, None, p_color))
            False -> panic
          }
        RBNode(_, None, None, _) -> panic
      }
    None -> {
      case node {
        // Если у node оба ребёнка, то на место node ставим следующее значение ключа (один раз вправо и до конца влево)
        RBNode(_, Some(left), Some(right), color) -> {
          let next_key = find_next_key(right)
          let with_deleted_next_key = delete_next_key(node, right)
          Some(RBNode(next_key, Some(left), with_deleted_next_key, color))
        }
        RBNode(_, Some(left), None, _) -> Some(left)
        RBNode(_, None, Some(right), _) -> Some(right)
        RBNode(_, None, None, _) -> None
      }
    }
  }
}

pub fn delete_find(
  node: RBNode(member),
  member_to_delete: member,
  comparator: fn(member, member) -> Int,
) -> Option(RBNode(member)) {
  case comparator(node.value, member_to_delete) == 0 {
    True -> delete_impl(None, node)
    False ->
      case node {
        RBNode(cur_val, Some(left), Some(right), color) -> {
          let a = case comparator(left.value, member_to_delete) == 0 {
            True -> Left
            False -> NoOne
          }
          let a = case comparator(right.value, member_to_delete) == 0 {
            True -> Right
            False -> a
          }

          case a {
            Left -> delete_impl(Some(node), left)
            Right -> delete_impl(Some(node), right)
            NoOne ->
              case comparator(cur_val, member_to_delete) > 0 {
                True ->
                  Some(RBNode(
                    cur_val,
                    Some(left),
                    delete_find(right, member_to_delete, comparator),
                    color,
                  ))
                False ->
                  Some(RBNode(
                    cur_val,
                    delete_find(left, member_to_delete, comparator),
                    Some(right),
                    color,
                  ))
              }
          }
        }
        RBNode(cur_val, Some(left), None, color) -> {
          case comparator(left.value, member_to_delete) == 0 {
            True -> delete_impl(Some(node), left)
            False ->
              Some(RBNode(
                cur_val,
                delete_find(left, member_to_delete, comparator),
                None,
                color,
              ))
          }
        }
        RBNode(cur_val, None, Some(right), color) -> {
          case comparator(right.value, member_to_delete) == 0 {
            True -> delete_impl(Some(node), right)
            False ->
              Some(RBNode(
                cur_val,
                None,
                delete_find(right, member_to_delete, comparator),
                color,
              ))
          }
        }
        RBNode(_, None, None, _) -> Some(node)
      }
  }
}

fn fix_deletion() {
  todo
}
