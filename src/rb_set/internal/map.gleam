import gleam/option.{None, Some}
import rb_set/internal/core.{type RBNode, RBNode}

pub fn map_impl(
  node: RBNode(member),
  fun: fn(member) -> mapped,
) -> RBNode(mapped) {
  RBNode(
    fun(node.value),
    case node.left {
      Some(l) -> Some(map_impl(l, fun))
      None -> None
    },
    case node.right {
      Some(r) -> Some(map_impl(r, fun))
      None -> None
    },
    node.color,
  )
}
