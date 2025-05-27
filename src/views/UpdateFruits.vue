<template>
  <v-container>
    <h1>Update Fruits</h1>
    <v-form @submit.prevent="addFruit">
      <v-text-field v-model="newFruit" label="Fruit Name" required></v-text-field>
      <v-text-field v-model="newNumber" label="Number" type="number" required></v-text-field>
      <v-btn type="submit" color="success">Add</v-btn>
    </v-form>

    <v-list>
      <v-list-item v-for="fruit in fruits" :key="fruit.id">
        <v-list-item-title>{{ fruit.fruits }} - {{ fruit.number }}</v-list-item-title>
        <v-btn icon @click="deleteFruit(fruit.id)"><v-icon>mdi-delete</v-icon></v-btn>
      </v-list-item>
    </v-list>
  </v-container>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'
import { useAuthStore } from '../store/auth'

const newFruit = ref('')
const newNumber = ref(1)
const fruits = ref([])
const auth = useAuthStore()

const loadFruits = async () => {
  const res = await axios.get('http://127.0.0.1:5000/api/fruits', {
    headers: { Authorization: `Bearer ${auth.token}` }
  })
  fruits.value = res.data
}

const addFruit = async () => {
  await axios.post('http://127.0.0.1:5000/api/fruits', {
    fruits: newFruit.value,
    number: newNumber.value
  }, {
    headers: { Authorization: `Bearer ${auth.token}` }
  })
  newFruit.value = ''
  newNumber.value = 1
  loadFruits()
}

const deleteFruit = async (id) => {
  await axios.delete(`http://127.0.0.1:5000/api/fruits/${id}`, {
    headers: { Authorization: `Bearer ${auth.token}` }
  })
  loadFruits()
}

onMounted(loadFruits)
</script>
