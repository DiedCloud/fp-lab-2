import gleam/option.{type Option}

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
