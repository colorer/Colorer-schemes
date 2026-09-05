<script setup lang="ts">
import { ref } from 'vue'
type Point = number
const count = ref(0)
</script>

<template>
  <button v-if="ok" @click="count++" :title="name">{{ count }}</button>
  <input v-model="count"/>
</template>

<style>
button {
  color: #42b883;
}
</style>
