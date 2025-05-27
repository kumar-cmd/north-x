<template>
  <v-container class="mt-5">
    <v-text-field
      v-model="query"
      label="Search fruits"
      prepend-icon="mdi-magnify"
      @input="searchFruits"
      clearable
    ></v-text-field>

    <v-list>
      <v-list-item
        v-for="fruit in fruits"
        :key="fruit.id"
      >
        <v-list-item-content>
          <v-list-item-title>{{ fruit.fruits }}</v-list-item-title>
          <v-list-item-subtitle>Quantity: {{ fruit.number }}</v-list-item-subtitle>
        </v-list-item-content>
      </v-list-item>
    </v-list>

    <div v-if="loading" class="text-center mt-5">
      <v-progress-circular indeterminate color="primary"></v-progress-circular>
    </div>
  </v-container>
</template>

<script setup>
import { ref } from 'vue'
import axios from 'axios'

const query = ref('')
const fruits = ref([])
const loading = ref(false)

const searchFruits = async () => {
  if (query.value.length === 0) {
    fruits.value = []
    return
  }

  loading.value = true
  try {
    const res = await axios.get(`https://xnorth.pythonanywhere.com/api/search?q=${query.value}`)
    fruits.value = res.data
  } catch (err) {
    console.error(err)
  } finally {
    loading.value = false
  }
}
</script>
