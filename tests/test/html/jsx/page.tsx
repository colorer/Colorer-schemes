export type Id = string;

export default function Page() {
  return <h1 className="title">Hello, Next.js!</h1>;
}

export async function load(id: string) {
  const data = await fetch(`/api/${id}`);
  return <Card title={data.name} />;
}
