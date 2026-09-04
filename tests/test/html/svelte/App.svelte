<script>
  let name = 'world'
</script>

<h1>Hello {name}!</h1>

{#if name}
  <p>Welcome.</p>
{/if}

<style>
  h1 {
    color: purple;
  }
</style>
