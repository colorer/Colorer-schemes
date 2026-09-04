f <- \(x) x + 1
mtcars |>
  subset(cyl == 4) %>%
  head()
