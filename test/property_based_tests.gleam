import gleam/int
import gleam/list
import gleam/order.{type Order, Eq, Gt, Lt}
import qcheck
import rb_set

fn compare(a: Int, b: Int) -> Int {
  b - a
}

fn reference_union(set: rb_set.RBSet(member), list: List(member)) {
  case list {
    [a, ..tail] -> reference_union(rb_set.insert(set, a), tail)
    _ -> set
  }
}

pub fn union__test() {
  let config = qcheck.default_config() |> qcheck.with_test_count(100)

  use init_list <- qcheck.run(config, qcheck.list_from(qcheck.uniform_int()))
  use added_elements <- qcheck.run(
    config,
    qcheck.list_from(qcheck.uniform_int()),
  )

  let set = rb_set.from_list(init_list, compare)
  let set_to_add = rb_set.from_list(added_elements, compare)

  let union_res = rb_set.union(set, set_to_add)
  let reference_union_res = reference_union(set, added_elements)

  assert rb_set.compare(union_res, reference_union_res)
}

pub fn union_with_neutral__test() {
  use init_list <- qcheck.given(qcheck.list_from(qcheck.uniform_int()))
  let added_elements = []

  let set = rb_set.from_list(init_list, compare)
  // нейтральный элмент - пустое множество
  let set_to_add = rb_set.new(compare)

  let union_res = rb_set.union(set, set_to_add)
  let reference_union_res = reference_union(set, added_elements)

  assert rb_set.compare(union_res, reference_union_res)
}

fn reference_difference(set: rb_set.RBSet(member), list: List(member)) {
  case list {
    [a, ..tail] -> reference_difference(rb_set.delete(set, a), tail)
    _ -> set
  }
}

pub fn difference__test() {
  let config = qcheck.default_config() |> qcheck.with_test_count(10)

  use init_list <- qcheck.run(config, qcheck.list_from(qcheck.uniform_int()))
  use drop_list <- qcheck.run(config, qcheck.list_from(qcheck.uniform_int()))

  let set = rb_set.from_list(init_list, compare)
  let set_to_drop = rb_set.from_list(drop_list, compare)

  let difference_res = rb_set.difference(set, set_to_drop)
  let reference_difference_res = reference_difference(set, drop_list)

  assert rb_set.compare(difference_res, reference_difference_res)
}

pub fn difference_with_neutral__test() {
  use init_list <- qcheck.given(qcheck.list_from(qcheck.uniform_int()))
  let dropped_elements = []

  let set = rb_set.from_list(init_list, compare)
  // нейтральный элмент - пустое множество
  let set_to_drop = rb_set.new(compare)

  let difference_res = rb_set.difference(set, set_to_drop)
  let reference_difference_res = reference_difference(set, dropped_elements)

  assert rb_set.compare(difference_res, reference_difference_res)
}

fn reference_intersection(
  set: rb_set.RBSet(member),
  list_a: List(member),
  list_b: List(member),
) {
  case list_a {
    [a, ..tail] ->
      case list.contains(list_b, a) {
        True -> reference_intersection(rb_set.insert(set, a), tail, list_b)
        False -> reference_intersection(set, tail, list_b)
      }
    _ -> set
  }
}

pub fn intersection__test() {
  let config = qcheck.default_config() |> qcheck.with_test_count(100)

  use list_a <- qcheck.run(config, qcheck.list_from(qcheck.uniform_int()))
  use list_b <- qcheck.run(config, qcheck.list_from(qcheck.uniform_int()))

  let set_a = rb_set.from_list(list_a, compare)
  let set_b = rb_set.from_list(list_b, compare)

  let intersection_res = rb_set.intersection(set_a, set_b)
  let reference_intersection_res =
    reference_intersection(rb_set.new(compare), list_a, list_b)

  assert rb_set.compare(intersection_res, reference_intersection_res)
}

pub fn intersection_with_neutral__test() {
  use list_a <- qcheck.given(qcheck.list_from(qcheck.uniform_int()))
  let set_a = rb_set.from_list(list_a, compare)

  let intersection_res = rb_set.intersection(set_a, set_a)
  // нейтральный элмент для пересечения - то же самое множество
  let reference_intersection_res =
    reference_intersection(rb_set.new(compare), list_a, list_a)

  assert rb_set.compare(intersection_res, reference_intersection_res)
}

fn reference_filter(
  set: rb_set.RBSet(member),
  predicate: fn(member) -> Bool,
  comparator: fn(member, member) -> Int,
) {
  set
  |> rb_set.to_list
  |> list.filter(predicate)
  |> rb_set.from_list(comparator)
}

pub fn filter__test() {
  let config = qcheck.default_config() |> qcheck.with_test_count(100)

  use list_a <- qcheck.run(config, qcheck.list_from(qcheck.uniform_int()))

  use upper_bound <- qcheck.given(qcheck.uniform_int())
  let predicate = fn(a: Int) -> Bool { a % 2 == 0 && a <= upper_bound }

  let set_a = rb_set.from_list(list_a, compare)

  let filter_res = rb_set.filter(set_a, predicate)
  let reference_filter_res = reference_filter(set_a, predicate, compare)

  assert rb_set.compare(filter_res, reference_filter_res)
}

pub fn filter_with_neutral__test() {
  use list_a <- qcheck.given(qcheck.list_from(qcheck.uniform_int()))
  let predicate = fn(_a: member) { True }

  let set_a = rb_set.from_list(list_a, compare)

  let filter_res = rb_set.filter(set_a, predicate)
  let reference_filter_res = reference_filter(set_a, predicate, compare)

  assert rb_set.compare(filter_res, reference_filter_res)
}

fn reference_map(
  set: rb_set.RBSet(member),
  mapper: fn(member) -> mapped,
  comparator: fn(mapped, mapped) -> Int,
) {
  set |> rb_set.to_list |> list.map(mapper) |> rb_set.from_list(comparator)
}

pub fn map__test() {
  let config = qcheck.default_config() |> qcheck.with_test_count(20)

  use list_a <- qcheck.run(config, qcheck.list_from(qcheck.uniform_int()))

  use upper_bound <- qcheck.run(config, qcheck.uniform_int())
  use multiplier <- qcheck.run(config, qcheck.uniform_int())
  use sub <- qcheck.run(config, qcheck.uniform_int())

  let mapper = fn(a: Int) -> Int {
    int.clamp(a * multiplier - sub, 0, upper_bound)
  }

  let set_a = rb_set.from_list(list_a, compare)

  let map_res = rb_set.map(set_a, mapper, compare)
  let reference_map_res = reference_map(set_a, mapper, compare)

  assert rb_set.compare(map_res, reference_map_res)
}

pub fn map_with_neutral__test() {
  use list_a <- qcheck.given(qcheck.list_from(qcheck.uniform_int()))
  let mapper = fn(a: member) { a }

  let set_a = rb_set.from_list(list_a, compare)

  let map_res = rb_set.map(set_a, mapper, compare)
  let reference_map_res = reference_map(set_a, mapper, compare)

  assert rb_set.compare(map_res, reference_map_res)
}

fn compare_oreder(a: Int, b: Int) -> Order {
  case b - a {
    0 -> Eq
    i if i > 0 -> Gt
    _ -> Lt
  }
}

pub fn from_list_to_list__test() {
  let config = qcheck.default_config() |> qcheck.with_test_count(100)
  use list_a <- qcheck.run(config, qcheck.list_from(qcheck.uniform_int()))
  let set_a = rb_set.from_list(list_a, compare)
  let list_res = rb_set.to_list(set_a)
  assert list.sort(list_a, compare_oreder)
    == list.sort(list_res, compare_oreder)
}
