import gleam/option.{None, Some}
import rb_set/internal/core.{type RBNode}

pub fn fold_impl(
  node: RBNode(member),
  acc: acc,
  reducer: fn(acc, member) -> acc,
) -> acc {
  let acc = reducer(acc, node.value)
  let acc = case node.left {
    Some(l) -> fold_impl(l, acc, reducer)
    None -> acc
  }
  let acc = case node.right {
    Some(r) -> fold_impl(r, acc, reducer)
    None -> acc
  }
  acc
}
