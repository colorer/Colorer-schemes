<?php
#[Deprecated]
#[Route('/users/{id}', methods: ['GET'])]
readonly class User {
    public function __construct(
        public readonly string $name,
    ) {}
}

enum Status : string {
    case Ok = 'ok';
}

function dump(int $v): never {
    exit($v);
}

$label = match ($status) {
    Status::Ok => 'fine',
    default => 'other',
};

$double = fn($x) => $x * 2;

# still a hash comment
echo $label;
?>
