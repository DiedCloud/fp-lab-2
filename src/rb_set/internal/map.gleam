import gleam/option.{None, Some}
import rb_set/internal/core.{type RBNode, RBNode}

pub fn simple_mapper_apply(
  node: RBNode(member),
  fun: fn(member) -> mapped,
) -> RBNode(mapped) {
  RBNode(
    fun(node.value),
    case node.left {
      Some(l) -> Some(simple_mapper_apply(l, fun))
      None -> None
    },
    case node.right {
      Some(r) -> Some(simple_mapper_apply(r, fun))
      None -> None
    },
    node.color,
  )
}
