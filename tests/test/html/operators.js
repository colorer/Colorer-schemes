export async function load(id, items) {
  const data = items?.find((x) => x.id === id) ?? {};
  const n = 2 ** 10;
  const copy = { ...data, n };
  using handle = await open();
  const name = copy.#label ??= 'none';
  return copy?.name || name;
}
