<script setup lang="ts">
import { ref, onMounted } from "vue";
import { api } from "../http/client";

const data = ref([]);
const loading = ref(true);
const error = ref<string | null>(null);

onMounted(async () => {
  try {
    const res = await api.get("/tasks");
    data.value = res.data;
  } catch (err) {
    error.value = "Falha ao carregar tasks";
  } finally {
    loading.value = false;
  }
});
</script>

<template>
  <div v-if="loading">Carregando...</div>
  <div v-else-if="error">{{ error }}</div>
  <pre v-else>{{ data }}</pre>
</template>

<style scoped>
</style>
