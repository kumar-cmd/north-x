<template>
  <v-container>
    <h1>Fruits Dashboard</h1>
    <v-btn color="primary" @click="goToUpdate">Manage Fruits</v-btn>
    <v-list>
      <v-list-item v-for="fruit in fruits" :key="fruit.id">
        <v-list-item-title>{{ fruit.fruits }} - {{ fruit.number }}</v-list-item-title>
      </v-list-item>
    </v-list>
  </v-container>
</template>

<script setup>
import axios from 'axios'
import { ref, onMounted } from 'vue'
import { useAuthStore } from '../store/auth'
import { useRouter } from 'vue-router'

const fruits = ref([])
const auth = useAuthStore()
const router = useRouter()

const goToUpdate = () => router.push('/update')

onMounted(async () => {
  const res = await axios.get('http://127.0.0.1:5000/api/fruits', {
    headers: { Authorization: `Bearer ${auth.token}` }
  })
  fruits.value = res.data
})
</script>
