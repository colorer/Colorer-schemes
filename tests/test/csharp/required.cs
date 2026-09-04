public sealed record Person
{
    public required string Name { get; init; }
}

file static class Helper
{
    static nint Size(scoped ref int x) => 0;
}
