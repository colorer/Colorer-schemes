# cython: language_level=3

cimport numpy as np
from libc.math cimport sqrt

cdef double hypot(double x, double y) noexcept nogil:
    return sqrt(x * x + y * y)

cpdef int add(int a, int b):
    cdef int total = a + b
    return total
