type Point[T] = tuple[T, T]

def first[T](xs: list[T]) -> T:
    return xs[0]

try:
    first([])
except* ValueError:
    pass
