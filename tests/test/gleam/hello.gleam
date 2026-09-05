import gleam/io

pub type Point {
  Point(x: Int, y: Int)
}

pub fn main() -> Nil {
  let n = 1
  case n {
    0 -> io.println("zero")
    _ -> io.println("hi")
  }
}
