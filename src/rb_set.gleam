//// Set implementation based on Red-Black tree!
//// Not implented functions comparing to set from gleam stdlib: contains, symmetric_difference, drop, take, each, is_disjoint, is_subset

pub type RBSet(member)

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

pub fn union(
  of first: RBSet(member),
  and second: RBSet(member),
) -> RBSet(member) {
  echo first
  echo second
  todo
}

pub fn difference(
  from first: RBSet(member),
  minus second: RBSet(member),
) -> RBSet(member) {
  echo first
  echo second
  todo
}

pub fn intersection(
  of first: RBSet(member),
  and second: RBSet(member),
) -> RBSet(member) {
  echo first
  echo second
  todo
}

pub fn map(set: RBSet(member), with fun: fn(member) -> mapped) -> RBSet(mapped) {
  echo set
  echo fun
  todo
}

pub fn filter(
  in set: RBSet(member),
  keeping predicate: fn(member) -> Bool,
) -> RBSet(member) {
  echo set
  echo predicate
  todo
}

pub fn fold_left(
  over set: RBSet(member),
  from initial: acc,
  with reducer: fn(acc, member) -> acc,
) -> acc {
  echo set
  echo initial
  echo reducer
  todo
}

pub fn fold_right(
  over set: RBSet(member),
  from initial: acc,
  with reducer: fn(acc, member) -> acc,
) -> acc {
  echo set
  echo initial
  echo reducer
  todo
}

pub fn fold(
  over set: RBSet(member),
  from initial: acc,
  with reducer: fn(acc, member) -> acc,
) -> acc {
  fold_left(set, initial, reducer)
}

pub fn new() -> RBSet(member) {
  todo
}

pub fn from_list(members: List(member)) -> RBSet(member) {
  echo members
  todo
}

pub fn to_list(set: RBSet(member)) -> List(member) {
  echo set
  todo
}

pub fn size(set: RBSet(member)) -> Int {
  echo set
  todo
}

pub fn is_empty(set: RBSet(member)) -> Bool {
  size(set) == 0
}
