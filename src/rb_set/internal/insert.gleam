import gleam/option.{type Option, None, Some}
import rb_set/internal/core.{type RBNode, Black, RBNode, Red}

pub fn insert_impl(
  node: Option(RBNode(member)),
  new_member: member,
  comparator: fn(member, member) -> Int,
) -> RBNode(member) {
  case node {
    Some(RBNode(cur_val, left, right, color)) -> {
      case comparator(cur_val, new_member) > 0 {
        True ->
          RBNode(
            cur_val,
            left,
            Some(insert_impl(right, new_member, comparator)),
            color,
          )
        False ->
          RBNode(
            cur_val,
            Some(insert_impl(left, new_member, comparator)),
            right,
            color,
          )
      }
    }
    None -> RBNode(new_member, None, None, Red)
  }
}

pub fn fix_insertion(node: RBNode(member)) -> RBNode(member) {
  todo
}
