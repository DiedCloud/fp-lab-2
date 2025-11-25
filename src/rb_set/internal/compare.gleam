import gleam/option.{type Option, None, Some}
import rb_set/internal/core.{type RBNode, RBNode}

type Iterator(member) {
  Iterator(stack: List(RBNode(member)))
}

fn push_left(
  node: Option(RBNode(member)),
  stack: List(RBNode(member)),
) -> List(RBNode(member)) {
  case node {
    Some(RBNode(_, left, _, _) as n) -> push_left(left, [n, ..stack])
    _ -> stack
  }
}

fn next(it: Iterator(member)) -> #(Option(member), Iterator(member)) {
  case it.stack {
    [node, ..tail] -> #(Some(node.value), Iterator(push_left(node.right, tail)))
    _ -> #(None, it)
  }
}

fn new_iterator(head: Option(RBNode(member))) {
  Iterator(push_left(head, []))
}

fn iter_compare(first: Iterator(member), second: Iterator(member)) -> Bool {
  let #(a, new_first) = next(first)
  let #(b, new_second) = next(second)
  case a, b {
    Some(_), Some(_) ->
      case a == b {
        True -> iter_compare(new_first, new_second)
        False -> False
      }
    None, None -> True
    _, _ -> False
  }
}

pub fn compare_impl(
  first: Option(RBNode(member)),
  second: Option(RBNode(member)),
) -> Bool {
  let first_iterator = new_iterator(first)
  let second_iterator = new_iterator(second)
  iter_compare(first_iterator, second_iterator)
}
