//// Set implementation based on Red-Black tree!
//// Not implented functions comparing to set from gleam stdlib: contains, symmetric_difference, drop, take, each, is_disjoint, is_subset

import gleam/list
import gleam/option.{type Option, None, Some}

type RBColor {
  Red
  Black
}

type RBNode(member) {
  RBNode(
    value: member,
    left: Option(RBNode(member)),
    right: Option(RBNode(member)),
    color: RBColor,
  )
}

pub opaque type RBSet(member) {
  RBSet(head: Option(RBNode(member)), comparator: fn(member, member) -> Int)
}

pub fn insert(into set: RBSet(member), this member: member) -> RBSet(member) {
  echo set
  echo member
  todo
}

pub fn delete(from set: RBSet(member), this member: member) -> RBSet(member) {
  echo set
  echo member
  todo
}

fn contains_impl(node: RBNode(member), member: member) {
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

pub fn contains(in set: RBSet(member), this member: member) -> Bool {
  case set.head {
    Some(head) -> contains_impl(head, member)
    None -> False
  }
}

pub fn union(
  of first: RBSet(member),
  and second: RBSet(member),
) -> RBSet(member) {
  echo first
  echo second
  fold(first, second, fn(acc: RBSet(member), member) { insert(acc, member) })
}

pub fn difference(
  from first: RBSet(member),
  minus second: RBSet(member),
) -> RBSet(member) {
  echo first
  echo second
  let to_del_list = to_list(second)
  list.fold(to_del_list, first, fn(acc: RBSet(member), m: member) {
    delete(acc, m)
  })
}

pub fn intersection(
  of first: RBSet(member),
  and second: RBSet(member),
) -> RBSet(member) {
  echo first
  echo second
  let acc = new(first.comparator)
  let acc =
    fold(first, acc, fn(acc: RBSet(member), member) {
      case contains(second, member) {
        True -> insert(acc, member)
        False -> acc
      }
    })
  let acc =
    fold(second, acc, fn(acc: RBSet(member), member) {
      case contains(first, member) {
        True -> insert(acc, member)
        False -> acc
      }
    })
  acc
}

fn map_impl(node: RBNode(member), fun: fn(member) -> mapped) -> RBNode(mapped) {
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

pub fn map(
  set: RBSet(member),
  with fun: fn(member) -> mapped,
  comparator comparator: fn(mapped, mapped) -> Int,
) -> RBSet(mapped) {
  echo set
  echo fun
  case set.head {
    Some(head) -> RBSet(Some(map_impl(head, fun)), comparator)
    None -> RBSet(None, comparator)
  }
}

fn filter_impl(
  node: RBNode(member),
  predicate: fn(member) -> Bool,
  acc: RBSet(member),
) -> RBSet(member) {
  case predicate(node.value) {
    True -> {
      let acc = insert(into: acc, this: node.value)
      let acc = case node.left {
        Some(l) -> filter_impl(l, predicate, acc)
        None -> acc
      }
      let acc = case node.right {
        Some(r) -> filter_impl(r, predicate, acc)
        None -> acc
      }
      acc
    }
    False -> acc
  }
}

pub fn filter(
  in set: RBSet(member),
  keeping predicate: fn(member) -> Bool,
) -> RBSet(member) {
  echo set
  echo predicate
  case set.head {
    Some(head) -> filter_impl(head, predicate, new(set.comparator))
    None -> set
  }
}

fn fold_impl(
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

pub fn fold(
  over set: RBSet(member),
  from initial: acc,
  with reducer: fn(acc, member) -> acc,
) -> acc {
  case set.head {
    Some(head) -> fold_impl(head, initial, reducer)
    None -> initial
  }
}

pub fn new(comparator: fn(member, member) -> Int) -> RBSet(member) {
  RBSet(None, comparator)
}

fn from_list_impl(members: List(member), acc: RBSet(member)) {
  case members {
    [a, ..] -> insert(acc, a)
    [] -> acc
  }
}

pub fn from_list(
  members: List(member),
  comparator: fn(member, member) -> Int,
) -> RBSet(member) {
  echo members
  from_list_impl(members, new(comparator))
}

pub fn to_list(set: RBSet(member)) -> List(member) {
  echo set
  fold(set, [], fn(acc: List(member), m: member) { [m, ..acc] })
}

pub fn size(set: RBSet(member)) -> Int {
  echo set
  fold(set, 0, fn(acc: Int, _m) { acc + 1 })
}

pub fn is_empty(set: RBSet(member)) -> Bool {
  set.head == None
}
