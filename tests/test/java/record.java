public record Point(int x, int y) {}

public sealed interface Shape permits Circle {}

public non-sealed class Circle implements Shape {
    String kind(Object o) {
        return switch (o) {
            case Point(int x, int y) when x > 0 -> "pos";
            case Point _ -> "pt";
            default -> {
                var s = "other";
                yield s;
            }
        };
    }

    String text = """
        block
        """;
}
