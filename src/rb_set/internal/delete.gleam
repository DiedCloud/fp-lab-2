import gleam/option.{type Option, None, Some}

import rb_set/internal/core.{type RBColor, type RBNode, Black, RBNode, Red}

fn paint_black(node: Option(RBNode(member))) -> Option(RBNode(member)) {
  case node {
    Some(n) -> Some(RBNode(n.value, n.left, n.right, Black))
    None -> None
  }
}

fn remove(
  color: RBColor,
  left: Option(RBNode(member)),
  right: Option(RBNode(member)),
) -> Option(RBNode(member)) {
  case color, left, right {
    _, None, None -> None
    _, Some(_), None -> left
    _, None, Some(_) -> right
    _, Some(l), Some(r) -> {
      let #(y, r1) = del_min(Some(r))
      Some(fix_color(RBNode(y, Some(l), r1, color)))
    }
  }
}

fn del_min(node: Option(RBNode(member))) -> #(member, Option(RBNode(member))) {
  case node {
    Some(RBNode(val, None, right, color)) -> #(val, fix_left(color, right))
    Some(RBNode(val, Some(left), right, color)) -> {
      let #(y, left1) = del_min(Some(left))
      #(y, Some(del_left(RBNode(val, left1, right, color))))
    }
    None -> panic
  }
}

fn del_left(node: RBNode(member)) -> RBNode(member) {
  case node.color {
    Black -> bal_left(node)
    Red -> node
  }
}

fn del_right(node: RBNode(member)) -> RBNode(member) {
  case node.color {
    Black -> bal_right(node)
    Red -> node
  }
}

fn fix_left(
  color: RBColor,
  node: Option(RBNode(member)),
) -> Option(RBNode(member)) {
  case color {
    Black -> paint_black(node)
    Red -> node
  }
}

fn fix_color(node: RBNode(member)) {
  case node {
    RBNode(val, left, right, Black) -> balance(RBNode(val, left, right, Black))
    RBNode(val, left, right, Red) -> RBNode(val, left, right, Black)
  }
}

fn balance(node: RBNode(member)) -> RBNode(member) {
  case node {
    RBNode(z, Some(RBNode(y, Some(RBNode(x, a, b, Red)), c, Red)), d, Black) ->
      RBNode(y, Some(RBNode(x, a, b, Black)), Some(RBNode(z, c, d, Black)), Red)
    RBNode(z, Some(RBNode(x, a, Some(RBNode(y, b, c, Red)), Red)), d, Black) ->
      RBNode(y, Some(RBNode(x, a, b, Black)), Some(RBNode(z, c, d, Black)), Red)
    RBNode(x, a, Some(RBNode(z, Some(RBNode(y, b, c, Red)), d, Red)), Black) ->
      RBNode(y, Some(RBNode(x, a, b, Black)), Some(RBNode(z, c, d, Black)), Red)
    RBNode(x, a, Some(RBNode(y, b, Some(RBNode(z, c, d, Red)), Red)), Black) ->
      RBNode(y, Some(RBNode(x, a, b, Black)), Some(RBNode(z, c, d, Black)), Red)
    _ -> node
  }
}

fn bal_left(node: RBNode(member)) -> RBNode(member) {
  case node {
    RBNode(y, Some(RBNode(x, a, b, Red)), c, Black) ->
      RBNode(x, a, Some(RBNode(y, b, c, Red)), Black)
    RBNode(x, a, Some(RBNode(y, b, c, Black)), Black) ->
      balance(RBNode(x, a, Some(RBNode(y, b, c, Red)), Black))
    RBNode(x, a, Some(RBNode(z, Some(RBNode(y, b, c, Black)), d, Red)), Black) ->
      RBNode(
        y,
        Some(RBNode(x, a, b, Black)),
        Some(balance(RBNode(z, c, paint_black(d), Black))),
        Red,
      )
    _ -> node
  }
}

fn bal_right(node: RBNode(member)) -> RBNode(member) {
  case node {
    RBNode(x, a, Some(RBNode(y, b, c, Red)), Black) ->
      RBNode(y, Some(RBNode(x, a, b, Red)), c, Black)
    RBNode(y, Some(RBNode(x, a, b, Black)), c, Black) ->
      balance(RBNode(y, Some(RBNode(x, a, b, Red)), c, Black))
    RBNode(z, Some(RBNode(x, a, Some(RBNode(y, b, c, Black)), Red)), d, Black) ->
      RBNode(
        y,
        Some(balance(RBNode(x, paint_black(a), b, Black))),
        Some(RBNode(z, c, d, Black)),
        Red,
      )
    _ -> node
  }
}

fn del(
  node: Option(RBNode(member)),
  member_to_delete: member,
  comparator: fn(member, member) -> Int,
) -> Option(RBNode(member)) {
  case node {
    Some(RBNode(cur_val, left, right, color)) -> {
      case comparator(cur_val, member_to_delete) {
        0 -> remove(color, left, right)
        i if i > 0 ->
          Some(
            del_right(RBNode(
              cur_val,
              left,
              del(right, member_to_delete, comparator),
              color,
            )),
          )
        _ ->
          Some(
            del_left(RBNode(
              cur_val,
              del(left, member_to_delete, comparator),
              right,
              color,
            )),
          )
      }
    }
    None -> None
  }
}

pub fn delete_impl(
  node: Option(RBNode(member)),
  member_to_delete: member,
  comparator: fn(member, member) -> Int,
) -> Option(RBNode(member)) {
  node |> del(member_to_delete, comparator) |> paint_black
}
