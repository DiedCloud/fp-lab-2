import gleam/list
import gleam/option.{None}
import gleam/order.{type Order, Eq, Gt, Lt}
import rb_set.{RBSet}

fn compare(a: Int, b: Int) -> Int {
  b - a
}

fn compare_oreder(a: Int, b: Int) -> Order {
  case b - a {
    0 -> Eq
    i if i > 0 -> Gt
    _ -> Lt
  }
}

pub fn new_test() {
  let res = RBSet(None, compare)
  assert rb_set.compare(this: rb_set.new(compare), with: res)
}

pub fn from_list_test() {
  assert rb_set.from_list([], compare) == rb_set.new(compare)
  let res =
    rb_set.new(compare)
    |> rb_set.insert(1)
    |> rb_set.insert(2)
    |> rb_set.insert(3)
  assert rb_set.compare(this: rb_set.from_list([1, 2, 3], compare), with: res)
}

pub fn to_list_test() {
  let src_list = [1, 2, 3]
  let set_a = rb_set.from_list(src_list, compare)
  let res_list = rb_set.to_list(set_a)
  assert list.sort(src_list, compare_oreder)
    == list.sort(res_list, compare_oreder)
}

pub fn size_test() {
  let src_list = [1, 2, 3]
  let set_a = rb_set.from_list(src_list, compare)
  assert rb_set.size(set_a) == list.length(src_list)
}

pub fn is_empty_test() {
  assert rb_set.new(compare) |> rb_set.is_empty
  assert !{ rb_set.from_list([1, 2, 3], compare) |> rb_set.is_empty }
}

pub fn difference_test() {
  let set_a = rb_set.from_list([1, 2, 3], compare)
  let set_b = rb_set.from_list([3, 4, 5], compare)
  let res = rb_set.from_list([1, 2], compare)
  assert rb_set.compare(
    this: rb_set.difference(from: set_a, minus: set_b),
    with: res,
  )
}

pub fn compare_test() {
  let set_a = rb_set.from_list([1, 2, 3], compare)
  let set_b = rb_set.from_list([3, 4, 5], compare)
  let set_c = rb_set.from_list([3, 4, 5], compare)
  assert rb_set.compare(this: set_a, with: set_b) == False
  assert rb_set.compare(this: set_b, with: set_c) == True
}

pub fn contains_test() {
  let set = rb_set.from_list([1, 2, 3], compare)
  assert rb_set.contains(in: set, this: 2) == True
  assert rb_set.contains(in: set, this: 4) == False
}

pub fn insert_test() {
  let set = rb_set.from_list([1, 2, 3], compare)
  let res = rb_set.from_list([1, 2, 3, 4], compare)
  assert rb_set.insert(into: set, this: 3) |> rb_set.insert(this: 4) == res
}

pub fn delete_test() {
  let set = rb_set.from_list([1, 2, 3], compare)
  let res = rb_set.from_list([1, 2], compare)
  assert rb_set.compare(
    this: rb_set.delete(from: set, this: 3) |> rb_set.delete(this: 4),
    with: res,
  )
}

pub fn union_test() {
  let set_a = rb_set.from_list([1, 2, 3], compare)
  let set_b = rb_set.from_list([3, 4, 5], compare)
  let res = rb_set.from_list([1, 2, 3, 4, 5], compare)
  assert rb_set.compare(this: rb_set.union(of: set_a, and: set_b), with: res)
}

pub fn intersection_test() {
  let set_a = rb_set.from_list([1, 2, 3], compare)
  let set_b = rb_set.from_list([3, 4, 5], compare)
  let res = rb_set.from_list([3], compare)
  assert rb_set.compare(
    this: rb_set.intersection(of: set_a, and: set_b),
    with: res,
  )
}

pub fn map_test() {
  let set_a = rb_set.from_list([1, 2, 3], compare)
  let fun = fn(n) { n * 2 }
  let res = rb_set.from_list([2, 4, 6], compare)
  assert rb_set.compare(
    this: rb_set.map(set_a, with: fun, comparator: compare),
    with: res,
  )
}

pub fn filter_test() {
  let set_a = rb_set.from_list([1, 2, 3], compare)
  let predicate = fn(n) { n % 2 == 0 }
  let res = rb_set.from_list([2], compare)
  assert rb_set.compare(
    this: rb_set.filter(in: set_a, keeping: predicate),
    with: res,
  )
}

pub fn fold_test() {
  let set_a = rb_set.from_list([1, 2, 3], compare)
  let reducer = fn(acc, x) { acc + x }
  let res = 6
  assert rb_set.fold(over: set_a, from: 0, with: reducer) == res
}
