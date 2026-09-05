export type Id = string | number;

export interface User {
  readonly id: Id;
  name?: string;
}

export function load(id: Id): Promise<User> {
  const data = fetch(`/api/${id}`) as Promise<User>;
  return data;
}

type Box<T> = { value: T };
declare const empty: never;

class Counter {
  accessor count = 0;
}
