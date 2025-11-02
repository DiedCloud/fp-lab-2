import gleam/option.{None, Some}
import rb_set/internal/core.{type RBNode}

pub fn contains_impl(node: RBNode(member), member: member) {
  case node.value == member {
    False -> {
      let v1 = case node.left {
        Some(l) -> contains_impl(l, member)
        None -> False
      }
      let v2 = case node.right {
        Some(r) -> contains_impl(r, member)
        None -> False
      }
      v1 || v2
    }
    True -> True
  }
}
