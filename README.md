# Реализация множества на красно-чёрном дереве на Gleam

## Лабораторная работа #2

- **Вариант:** _rb-set_
- **Преподаватель:** Пенской Александр Владимирович
- **Выполнил:** `Фролов Кирилл Дмитриевич`, `367590`
- ИТМО, Санкт-Петербург, 2025

## Описание работы

Данная лабораторная работа направлена на ознакомление с
построением пользовательских типов данных, полиморфизмом, рекурсивными алгоритмами
и средствами тестирования (unit testing, property-based testing),
а также разделением интерфейса и особенностей реализации.

## Требования

1. Функции:
   - добавление и удаление элементов;
   - фильтрация;
   - отображение (map);
   - свертки (левая и правая);
   - структура должна быть моноидом.
2. Структуры данных должны быть неизменяемыми.
3. Библиотека должна быть протестирована в рамках unit testing.
4. Библиотека должна быть протестирована в рамках property-based тестирования
(как минимум 3 свойства, включая свойства моноида).
5. Структура должна быть полиморфной.
6. Требуется использовать идиоматичный для технологии стиль программирования.
Примечание: некоторые языки позволяют получить большую часть API через реализацию небольшого интерфейса.
Так как лабораторная работа про ФП, а не про экосистему языка -- необходимо реализовать их вручную
и по возможности -- обеспечить совместимость.
7. Обратите внимание:
   - API должно быть реализовано для заданного интерфейса и оно не должно "протекать".
   На уровне тестов -- в первую очередь нужно протестировать именно API (dict, set, bag).
   - Должна быть эффективная реализация функции сравнения (не наивное приведение к спискам, их сортировка
   с последующим сравнением), реализованная на уровне API, а не внутреннего представления.

## Структура проекта

- [src/rb_set.gleam](src/rb_set.gleam) — основной модуль, со всеми функциями api
- [src/rb_set/internal](src/rb_set/internal) — модули c реализацией.
Например, [core.gleam](src/rb_set/internal/core.gleam) содержит внутреннее представление структуры
- [test/](test) — директория с тестами для проверки решений

---

## Реализация

Тип данных, с которым будет работать пользователь - `RBSet`.
Его отличие важное от стандартного, отражающееся, в том числе, на api библиотеки - наличие comparator.
Он необходим, так как операторы `<` и `>` работают только с `Int`.
```gleam
pub type RBSet(member) {
  RBSet(head: Option(RBNode(member)), comparator: fn(member, member) -> Int)
}
```

Этот тип может быть `opque`, то есть без публичного конструктора. 
Но для unit-теста функции `new` специальное слово убрано.
```gleam
pub fn new_test() {
   let res = RBSet(None, compare)
   assert rb_set.compare(this: rb_set.new(compare), with: res)
}
```

[Внутренние типы данных:](src/rb_set/internal/core.gleam)
```gleam
pub type RBColor {
  Red
  Black
}

pub type RBNode(member) {
  RBNode(
    value: member,
    left: Option(RBNode(member)),
    right: Option(RBNode(member)),
    color: RBColor,
  )
}
```

[Реализация вставки:](src/rb_set/internal/insert.gleam)
```gleam
fn balance(node: RBNode(member)) -> RBNode(member) {
  case node {
    RBNode(z, Some(RBNode(y, Some(RBNode(x, a, b, Red)), c, Red)), d, Black) ->
      RBNode(y, Some(RBNode(x, a, b, Black)), Some(RBNode(z, c, d, Black)), Red)
    RBNode(z, Some(RBNode(x, a, Some(RBNode(y, b, c, Red)), Red)), d, Black) ->
      RBNode(y, Some(RBNode(x, a, b, Black)), Some(RBNode(z, c, d, Black)), Red)
    RBNode(x, a, Some(RBNode(z, Some(RBNode(y, b, c, Red)), d, Red)), Black) ->
      RBNode(y, Some(RBNode(x, a, b, Black)), Some(RBNode(z, c, d, Black)), Red)
    RBNode(x, a, Some(RBNode(y, b, Some(RBNode(z, c, d, Red)), Red)), Black) ->
      RBNode(y, Some(RBNode(x, a, b, Black)), Some(RBNode(z, c, d, Black)), Red)
    _ -> node
  }
}

fn make_head_black(node: RBNode(member)) -> RBNode(member) {
  RBNode(node.value, node.left, node.right, Black)
}

fn ins(
  node: Option(RBNode(member)),
  new_member: member,
  comparator: fn(member, member) -> Int,
) -> RBNode(member) {
  case node {
    Some(RBNode(cur_val, left, right, color)) -> {
      case comparator(cur_val, new_member) {
        0 -> RBNode(cur_val, left, right, color)
        i if i > 0 ->
          balance(RBNode(
            cur_val,
            left,
            Some(ins(right, new_member, comparator)),
            color,
          ))
        _ ->
          balance(RBNode(
            cur_val,
            Some(ins(left, new_member, comparator)),
            right,
            color,
          ))
      }
    }
    None -> RBNode(new_member, None, None, Red)
  }
}

pub fn insert_impl(
  node: Option(RBNode(member)),
  new_member: member,
  comparator: fn(member, member) -> Int,
) -> RBNode(member) {
  node |> ins(new_member, comparator) |> make_head_black
}
```

[Реализация удаления](src/rb_set/internal/insert.gleam) довольно большая, предлагается ознакомиться с ней в файле модуля

Функции `union`, `difference`, `intersection`, `to_list` реализуются через свёртку - `fold`. Сама `fold`:

```gleam
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
```

`from_list`:
```gleam
fn from_list_impl(members: List(member), acc: RBSet(member)) -> RBSet(member) {
  case members {
    [a, ..tail] -> from_list_impl(tail, insert(acc, a))
    [] -> acc
  }
}

pub fn from_list(
  members: List(member),
  comparator: fn(member, member) -> Int,
) -> RBSet(member) {
  from_list_impl(members, new(comparator))
}
```

`map`:
```gleam
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

pub fn map(
  set: RBSet(member),
  with fun: fn(member) -> mapped,
  comparator comparator: fn(mapped, mapped) -> Int,
) -> RBSet(mapped) {
  case set.head {
    Some(head) ->
      head
      |> simple_mapper_apply(fun)
      |> Some()
      |> RBSet(comparator)
      |> fold(new(comparator), fn(acc: RBSet(mapped), mapped: mapped) {
        insert(acc, mapped)
      })
    None -> RBSet(None, comparator)
  }
}
```

`filter`:
```gleam
fn filter_impl(
  node: RBNode(member),
  predicate: fn(member) -> Bool,
  acc: RBSet(member),
) -> RBSet(member) {
  let acc = case predicate(node.value) {
    True -> insert(into: acc, this: node.value)
    False -> acc
  }
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

pub fn filter(
  in set: RBSet(member),
  keeping predicate: fn(member) -> Bool,
) -> RBSet(member) {
  case set.head {
    Some(head) -> filter_impl(head, predicate, new(set.comparator))
    None -> set
  }
}
```


## Запуск тестов

Для запуска тестов с использованием gleam:
```bash
gleam test
```

Результат запуска тестов:
```
PS G:\Files\Itmo\FP\fp-lab-2> gleam test
  Compiling rb_set
   Compiled in 0.43s
    Running rb_set_test.main
..........................
26 tests, no failures
```

## Заключение

В ходе выполнения работы была написана реализация множества, функции api которого вдохновлены уже существующей в Gleam реализацией множества.
Сама реализация потребовала переосмысления алгоритма работы с красно-чёрным деревом, ведь неизменяемость данных накладывает немалые ограничения.
Реализация протестирована в рамках unit testing и property based testing, что также было интересной задачей.

## Зависимости

Для сборки и запуска проекта использовались:

- gleam 1.12.0
- Erlang OTP 28.1
