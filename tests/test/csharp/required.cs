public sealed record Person
{
    public required string Name { get; init; }
}

file static class Helper
{
    static nint Size(scoped ref int x) => 0;
    static int[] Nums(int[] rest) => [1, 2, ..rest];
}
