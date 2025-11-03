import gleam/bool.{negate}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order.{type Order, Eq, Gt, Lt}
import qcheck
import rb_set
import rb_set/internal/core.{type RBNode, Black, RBNode, Red}

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
  use init_list <- qcheck.given(qcheck.list_from(qcheck.uniform_int()))
  use added_elements <- qcheck.given(qcheck.list_from(qcheck.uniform_int()))

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
    [a, ..tail] -> reference_union(rb_set.delete(set, a), tail)
    _ -> set
  }
}

pub fn difference__test() {
  use init_list <- qcheck.given(qcheck.list_from(qcheck.uniform_int()))
  use dropped_elements <- qcheck.given(qcheck.list_from(qcheck.uniform_int()))

  let set = rb_set.from_list(init_list, compare)
  let set_to_drop = rb_set.from_list(dropped_elements, compare)

  let difference_res = rb_set.difference(set, set_to_drop)
  let reference_difference_res = reference_difference(set, dropped_elements)

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
  use list_a <- qcheck.given(qcheck.list_from(qcheck.uniform_int()))
  use list_b <- qcheck.given(qcheck.list_from(qcheck.uniform_int()))

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
  use list_a <- qcheck.given(qcheck.list_from(qcheck.uniform_int()))
  let predicate = todo

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
  use list_a <- qcheck.given(qcheck.list_from(qcheck.uniform_int()))
  // todo generate?
  let mapper = todo
  // todo generate?
  let mapped_compare = fn(a: Int, b: Int) -> Int { b - a }

  let set_a = rb_set.from_list(list_a, compare)

  let map_res = rb_set.map(set_a, mapper, mapped_compare)
  let reference_map_res = reference_map(set_a, mapper, mapped_compare)

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

pub fn from_list_to_list_test() {
  use list_a <- qcheck.given(qcheck.list_from(qcheck.uniform_int()))
  let set_a = rb_set.from_list(list_a, compare)
  let list_res = rb_set.to_list(set_a)
  assert list.sort(list_a, compare_oreder)
    == list.sort(list_res, compare_oreder)
}

fn rec_ins_rb_tree_with_check(
  set: rb_set.RBSet(member),
  ins_list: List(member),
  check_fn: fn(Option(RBNode(member))) -> Nil,
) -> rb_set.RBSet(member) {
  case ins_list {
    [a, ..tail] -> {
      let set = rb_set.insert(set, a)
      check_fn(set.head)
      rec_ins_rb_tree_with_check(set, tail, check_fn)
    }
    _ -> set
  }
}

fn rec_del_rb_tree_with_check(
  set: rb_set.RBSet(member),
  ins_list: List(member),
  check_fn: fn(Option(RBNode(member))) -> Nil,
) -> rb_set.RBSet(member) {
  case ins_list {
    [a, ..tail] -> {
      let set = rb_set.delete(set, a)
      check_fn(set.head)
      rec_del_rb_tree_with_check(set, tail, check_fn)
    }
    _ -> set
  }
}

fn check_rb_tree_no_two_red_nodes(node: Option(RBNode(member))) {
  case node {
    Some(RBNode(_, Some(left), Some(right), color)) -> {
      assert negate(color == Red && left.color == Red)
      assert negate(color == Red && right.color == Red)
      let _ = check_rb_tree_no_two_red_nodes(Some(left))
      check_rb_tree_no_two_red_nodes(Some(right))
    }
    Some(RBNode(_, Some(left), None, color)) -> {
      assert negate(color == Red && left.color == Red)
      check_rb_tree_no_two_red_nodes(Some(left))
    }
    Some(RBNode(_, None, Some(right), color)) -> {
      assert negate(color == Red && right.color == Red)
      check_rb_tree_no_two_red_nodes(Some(right))
    }
    Some(RBNode(_, None, None, _)) -> Nil
    None -> Nil
  }
}

pub fn rb_tree_no_two_red_nodes_test() {
  use list_a <- qcheck.given(qcheck.list_from(qcheck.uniform_int()))
  let set_a = rb_set.from_list(list_a, compare)
  use ins_list <- qcheck.given(qcheck.list_from(qcheck.uniform_int()))
  use del_list <- qcheck.given(qcheck.list_from(qcheck.uniform_int()))
  let set_a =
    rec_ins_rb_tree_with_check(set_a, ins_list, check_rb_tree_no_two_red_nodes)
  rec_del_rb_tree_with_check(set_a, del_list, check_rb_tree_no_two_red_nodes)
  Nil
}

fn check_rb_tree_all_leaf_black(node: Option(RBNode(member))) {
  case node {
    Some(RBNode(_, Some(left), Some(right), _)) -> {
      let _ = check_rb_tree_no_two_red_nodes(Some(left))
      check_rb_tree_no_two_red_nodes(Some(right))
    }
    Some(RBNode(_, Some(left), None, _)) -> {
      check_rb_tree_no_two_red_nodes(Some(left))
    }
    Some(RBNode(_, None, Some(right), _)) -> {
      check_rb_tree_no_two_red_nodes(Some(right))
    }
    Some(RBNode(_, None, None, color)) -> {
      assert color == Black
    }
    None -> Nil
  }
}

pub fn rb_tree_all_leaf_black_test() {
  use list_a <- qcheck.given(qcheck.list_from(qcheck.uniform_int()))
  let set_a = rb_set.from_list(list_a, compare)
  use ins_list <- qcheck.given(qcheck.list_from(qcheck.uniform_int()))
  use del_list <- qcheck.given(qcheck.list_from(qcheck.uniform_int()))
  let set_a =
    rec_ins_rb_tree_with_check(set_a, ins_list, check_rb_tree_all_leaf_black)
  rec_del_rb_tree_with_check(set_a, del_list, check_rb_tree_all_leaf_black)
  Nil
}

fn check_rb_tree_black_path_lenth(node: Option(RBNode(member))) {
  todo
  case node {
    Some(RBNode(_, Some(left), Some(right), _)) -> {
      let _ = check_rb_tree_no_two_red_nodes(Some(left))
      check_rb_tree_no_two_red_nodes(Some(right))
    }
    Some(RBNode(_, Some(left), None, _)) -> {
      check_rb_tree_no_two_red_nodes(Some(left))
    }
    Some(RBNode(_, None, Some(right), _)) -> {
      check_rb_tree_no_two_red_nodes(Some(right))
    }
    Some(RBNode(_, None, None, color)) -> {
      assert color == Black
    }
    None -> Nil
  }
}

pub fn rb_tree_black_path_lenth_test() {
  use list_a <- qcheck.given(qcheck.list_from(qcheck.uniform_int()))
  let set_a = rb_set.from_list(list_a, compare)
  use ins_list <- qcheck.given(qcheck.list_from(qcheck.uniform_int()))
  use del_list <- qcheck.given(qcheck.list_from(qcheck.uniform_int()))
  let set_a =
    rec_ins_rb_tree_with_check(set_a, ins_list, check_rb_tree_black_path_lenth)
  rec_del_rb_tree_with_check(set_a, del_list, check_rb_tree_black_path_lenth)
  Nil
}
