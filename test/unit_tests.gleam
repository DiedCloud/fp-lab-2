import gleam/list
import rb_set

pub fn insert_test() {
  let set = rb_set.from_list([1, 2, 3])
  let res = rb_set.from_list([1, 2, 3, 4])
  assert rb_set.insert(into: set, this: 3) |> rb_set.insert(this: 4) == res
}

pub fn delete_test() {
  let set = rb_set.from_list([1, 2, 3])
  let res = rb_set.from_list([1, 2])
  assert rb_set.delete(from: set, this: 3) |> rb_set.delete(this: 4) == res
}

pub fn union_test() {
  let set_a = rb_set.from_list([1, 2, 3])
  let set_b = rb_set.from_list([3, 4, 5])
  let res = rb_set.from_list([1, 2, 3, 4, 5])
  assert rb_set.union(of: set_a, and: set_b) == res
}

pub fn difference_test() {
  let set_a = rb_set.from_list([1, 2, 3])
  let set_b = rb_set.from_list([3, 4, 5])
  let res = rb_set.from_list([1, 2])
  assert rb_set.difference(from: set_a, minus: set_b) == res
}

pub fn intersection_test() {
  let set_a = rb_set.from_list([1, 2, 3])
  let set_b = rb_set.from_list([3, 4, 5])
  let res = rb_set.from_list([3])
  assert rb_set.intersection(of: set_a, and: set_b) == res
}

pub fn map_test() {
  let set_a = rb_set.from_list([1, 2, 3])
  let fun = fn(n) { n * 2 }
  let res = rb_set.from_list([2, 4, 6])
  assert rb_set.map(set_a, with: fun) == res
}

pub fn filter_test() {
  let set_a = rb_set.from_list([1, 2, 3])
  let predicate = fn(n) { n % 2 == 0 }
  let res = rb_set.from_list([2])
  assert rb_set.filter(in: set_a, keeping: predicate) == res
}

pub fn fold_left_test() {
  let set_a = rb_set.from_list([1, 2, 3])
  let reducer = fn(acc, x) { acc + x }
  let res = 6
  assert rb_set.fold_left(over: set_a, from: 0, with: reducer) == res
}

pub fn fold_right_test() {
  let set_a = rb_set.from_list([1, 2, 3])
  let reducer = fn(acc, x) { acc + x }
  let res = 6
  assert rb_set.fold_left(over: set_a, from: 0, with: reducer) == res
}

pub fn new_test() {
  // todo проверить не через from_list, который сам использует new
  let res = rb_set.from_list([])
  assert rb_set.new() == res
}

pub fn from_list_test() {
  assert rb_set.from_list([]) == rb_set.new()
  let res =
    rb_set.new()
    |> rb_set.insert(1)
    |> rb_set.insert(2)
    |> rb_set.insert(3)
  assert rb_set.from_list([1, 2, 3]) == res
}

pub fn to_list_test() {
  let src_list = [1, 2, 3]
  let set_a = rb_set.from_list(src_list)
  let res_list = rb_set.to_list(set_a)
  assert src_list == res_list
}

pub fn size_test() {
  let src_list = [1, 2, 3]
  let set_a = rb_set.from_list(src_list)
  assert rb_set.size(set_a) == list.length(src_list)
}

pub fn is_empty_test() {
  assert rb_set.new() |> rb_set.is_empty
  assert !{ rb_set.from_list([1, 2, 3]) |> rb_set.is_empty }
}
