import gleam/option.{type Option, None, Some}
import rb_set/internal/core.{type RBNode, Black, RBNode, Red}

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

fn make_head_black(node: RBNode(member)) -> RBNode(member) {
  RBNode(node.value, node.left, node.right, Black)
}

fn ins(
  node: Option(RBNode(member)),
  new_member: member,
  comparator: fn(member, member) -> Int,
) -> RBNode(member) {
  case node {
    Some(RBNode(cur_val, left, right, color)) -> {
      case comparator(cur_val, new_member) {
        0 -> RBNode(cur_val, left, right, color)
        i if i > 0 ->
          balance(RBNode(
            cur_val,
            left,
            Some(ins(right, new_member, comparator)),
            color,
          ))
        _ ->
          balance(RBNode(
            cur_val,
            Some(ins(left, new_member, comparator)),
            right,
            color,
          ))
      }
    }
    None -> RBNode(new_member, None, None, Red)
  }
}

pub fn insert_impl(
  node: Option(RBNode(member)),
  new_member: member,
  comparator: fn(member, member) -> Int,
) -> RBNode(member) {
  node |> ins(new_member, comparator) |> make_head_black
}
