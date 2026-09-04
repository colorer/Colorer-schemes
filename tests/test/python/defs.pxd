cdef class Point:
    cdef public double x
    cdef public double y
    cdef double length(self) noexcept
