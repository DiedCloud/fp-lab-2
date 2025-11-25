import gleam/int
import gleam/list
import gleam/order.{type Order, Eq, Gt, Lt}
import qcheck
import rb_set

fn compare(a: Int, b: Int) -> Int {
  b - a
}

pub fn set_from(
  element_generator: qcheck.Generator(List(Int)),
) -> qcheck.Generator(rb_set.RBSet(Int)) {
  use init_list <- qcheck.map(element_generator)
  rb_set.from_list(init_list, compare)
}

fn reference_union(set: rb_set.RBSet(member), list: List(member)) {
  case list {
    [a, ..tail] -> reference_union(rb_set.insert(set, a), tail)
    _ -> set
  }
}

pub fn union__test() {
  let config = qcheck.default_config() |> qcheck.with_test_count(100)

  use set <- qcheck.run(
    config,
    qcheck.uniform_int() |> qcheck.list_from |> set_from,
  )
  use set_to_add <- qcheck.run(
    config,
    qcheck.uniform_int() |> qcheck.list_from |> set_from,
  )

  let union_res = rb_set.union(set, set_to_add)
  let reference_union_res = reference_union(set, set_to_add |> rb_set.to_list)

  assert rb_set.compare(union_res, reference_union_res)
}

pub fn union_association__test() {
  let config = qcheck.default_config() |> qcheck.with_test_count(10)

  use a <- qcheck.run(
    config,
    qcheck.uniform_int() |> qcheck.list_from |> set_from,
  )
  use b <- qcheck.run(
    config,
    qcheck.uniform_int() |> qcheck.list_from |> set_from,
  )
  use c <- qcheck.run(
    config,
    qcheck.uniform_int() |> qcheck.list_from |> set_from,
  )

  let ab = rb_set.union(a, b)
  let bc = rb_set.union(b, c)

  assert rb_set.compare(rb_set.union(ab, c), rb_set.union(a, bc))
}

pub fn union_with_neutral__test() {
  use set <- qcheck.given(qcheck.uniform_int() |> qcheck.list_from |> set_from)

  // нейтральный элмент - пустое множество
  let set_to_add = rb_set.new(compare)

  let union_res = rb_set.union(set, set_to_add)
  let reference_union_res = reference_union(set, [])

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

  use set <- qcheck.run(
    config,
    qcheck.uniform_int() |> qcheck.list_from |> set_from,
  )
  use set_to_drop <- qcheck.run(
    config,
    qcheck.uniform_int() |> qcheck.list_from |> set_from,
  )

  let difference_res = rb_set.difference(set, set_to_drop)
  let reference_difference_res =
    reference_difference(set, set_to_drop |> rb_set.to_list)

  assert rb_set.compare(difference_res, reference_difference_res)
}

pub fn difference_with_neutral__test() {
  use set <- qcheck.given(qcheck.uniform_int() |> qcheck.list_from |> set_from)

  // нейтральный элмент - пустое множество
  let set_to_drop = rb_set.new(compare)

  let difference_res = rb_set.difference(set, set_to_drop)
  let reference_difference_res = reference_difference(set, [])

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

  use set_a <- qcheck.run(
    config,
    qcheck.uniform_int() |> qcheck.list_from |> set_from,
  )
  use set_b <- qcheck.run(
    config,
    qcheck.uniform_int() |> qcheck.list_from |> set_from,
  )

  let intersection_res = rb_set.intersection(set_a, set_b)
  let reference_intersection_res =
    reference_intersection(
      rb_set.new(compare),
      set_a |> rb_set.to_list,
      set_b |> rb_set.to_list,
    )

  assert rb_set.compare(intersection_res, reference_intersection_res)
}

pub fn intersection_association__test() {
  let config = qcheck.default_config() |> qcheck.with_test_count(10)

  use a <- qcheck.run(
    config,
    qcheck.uniform_int() |> qcheck.list_from |> set_from,
  )
  use b <- qcheck.run(
    config,
    qcheck.uniform_int() |> qcheck.list_from |> set_from,
  )
  use c <- qcheck.run(
    config,
    qcheck.uniform_int() |> qcheck.list_from |> set_from,
  )

  let ab = rb_set.intersection(a, b)
  let bc = rb_set.intersection(b, c)

  assert rb_set.compare(rb_set.intersection(ab, c), rb_set.intersection(a, bc))
}

pub fn intersection_with_neutral__test() {
  use set <- qcheck.given(qcheck.uniform_int() |> qcheck.list_from |> set_from)

  let intersection_res = rb_set.intersection(set, set)
  // нейтральный элмент для пересечения - то же самое множество
  let reference_intersection_res =
    reference_intersection(
      rb_set.new(compare),
      set |> rb_set.to_list,
      set |> rb_set.to_list,
    )

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

  use set_a <- qcheck.run(
    config,
    qcheck.uniform_int() |> qcheck.list_from |> set_from,
  )

  use upper_bound <- qcheck.given(qcheck.uniform_int())
  let predicate = fn(a: Int) -> Bool { a % 2 == 0 && a <= upper_bound }

  let filter_res = rb_set.filter(set_a, predicate)
  let reference_filter_res = reference_filter(set_a, predicate, compare)

  assert rb_set.compare(filter_res, reference_filter_res)
}

pub fn filter_association__test() {
  let config = qcheck.default_config() |> qcheck.with_test_count(1)

  use set_a <- qcheck.run(
    config,
    qcheck.uniform_int() |> qcheck.list_from |> set_from,
  )

  use upper_bound_1 <- qcheck.given(qcheck.uniform_int())
  use upper_bound_2 <- qcheck.given(qcheck.uniform_int())
  let predicate_1 = fn(a: Int) -> Bool { a % 2 == 0 && a <= upper_bound_1 }
  let predicate_2 = fn(a: Int) -> Bool { a % 3 == 0 && a <= upper_bound_2 }

  let a12 = set_a |> rb_set.filter(predicate_1) |> rb_set.filter(predicate_2)
  let a21 = set_a |> rb_set.filter(predicate_2) |> rb_set.filter(predicate_1)

  assert rb_set.compare(a12, a21)
}

pub fn filter_with_neutral__test() {
  use set_a <- qcheck.given(
    qcheck.uniform_int() |> qcheck.list_from |> set_from,
  )
  let predicate = fn(_a: member) { True }

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

  use set_a <- qcheck.run(
    config,
    qcheck.uniform_int() |> qcheck.list_from |> set_from,
  )

  use upper_bound <- qcheck.run(config, qcheck.uniform_int())
  use multiplier <- qcheck.run(config, qcheck.uniform_int())
  use sub <- qcheck.run(config, qcheck.uniform_int())

  let mapper = fn(a: Int) -> Int {
    int.clamp(a * multiplier - sub, 0, upper_bound)
  }

  let map_res = rb_set.map(set_a, mapper, compare)
  let reference_map_res = reference_map(set_a, mapper, compare)

  assert rb_set.compare(map_res, reference_map_res)
}

pub fn map_with_neutral__test() {
  use set_a <- qcheck.given(
    qcheck.uniform_int() |> qcheck.list_from |> set_from,
  )
  let mapper = fn(a: member) { a }

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
