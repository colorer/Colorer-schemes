export async function load(ids) {
    for (const id of ids) {
        const data = await fetch(id);
        console.log(data);
    }
}
