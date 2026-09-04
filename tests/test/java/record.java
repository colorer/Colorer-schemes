public record Point(int x, int y) {}

public sealed interface Shape permits Circle {}

public non-sealed class Circle implements Shape {
    String kind(Object o) {
        return switch (o) {
            case Point p when p.x() > 0 -> "pos";
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
