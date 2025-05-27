#!/bin/bash

# Exit on any error
set -e

# # Create Vue 3 + Vite + Vuetify project
# npm create vite@latest vue-fruit-frontend -- --template vue
# cd vue-fruit-frontend

# # Install dependencies
# npm install
# npm install vue-router@4 pinia axios vuetify@3.5.10 @vuetify/icons-material --save

# Vuetify setup
mkdir -p  plugins
cat >  plugins/vuetify.js <<'EOF'
import "vuetify/styles";
import { createVuetify } from "vuetify";
import { aliases, md } from "vuetify/iconsets/md";
import * as components from "vuetify/components";
import * as directives from "vuetify/directives";

export default createVuetify({
  components,
  directives,
  icons: {
    defaultSet: "md",
    aliases,
    sets: {
      md,
    },
  },
});
EOF

# Pinia store setup for auth
mkdir -p  store
cat >  store/auth.js <<'EOF'
import { defineStore } from 'pinia'
import axios from 'axios'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    token: localStorage.getItem('token') || null,
    user: null,
  }),
  actions: {
    async login(email, password) {
      try {
        const res = await axios.post('http://127.0.0.1:5000/api/login', { email, password })
        this.token = res.data.access_token
        localStorage.setItem('token', this.token)
        return true
      } catch (err) {
        return false
      }
    },
    logout() {
      this.token = null
      localStorage.removeItem('token')
    },
    isLoggedIn() {
      return !!this.token
    }
  }
})
EOF

# Vue Router setup
mkdir -p  router
cat >  router/index.js <<'EOF'
import { createRouter, createWebHistory } from 'vue-router'
import LoginView from '../views/LoginView.vue'
import DashboardView from '../views/DashboardView.vue'
import UpdateFruits from '../views/UpdateFruits.vue'
import { useAuthStore } from '../store/auth'

const routes = [
  { path: '/', name: 'Login', component: LoginView },
  { path: '/dashboard', name: 'Dashboard', component: DashboardView },
  { path: '/update', name: 'Update', component: UpdateFruits }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to, from, next) => {
  const auth = useAuthStore()
  if (to.name !== 'Login' && !auth.isLoggedIn()) next({ name: 'Login' })
  else next()
})

export default router
EOF

# App.vue
cat >  App.vue <<'EOF'
<template>
  <v-app>
    <v-main>
      <router-view />
    </v-main>
  </v-app>
</template>

<script setup>
</script>
EOF

# main.js
cat >  main.js <<'EOF'
import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './router'
import vuetify from './plugins/vuetify'

import '@mdi/font/css/materialdesignicons.css'
import 'vuetify/styles'

const app = createApp(App)
app.use(createPinia())
app.use(router)
app.use(vuetify)
app.mount('#app')
EOF

# Views
mkdir -p  views

# LoginView.vue
cat >  views/LoginView.vue <<'EOF'
<template>
  <v-container>
    <v-form @submit.prevent="submit">
      <v-text-field v-model="email" label="Email" required></v-text-field>
      <v-text-field v-model="password" label="Password" type="password" required></v-text-field>
      <v-btn type="submit" color="primary">Login</v-btn>
    </v-form>
  </v-container>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../store/auth'

const email = ref('')
const password = ref('')
const router = useRouter()
const auth = useAuthStore()

const submit = async () => {
  const success = await auth.login(email.value, password.value)
  if (success) router.push('/dashboard')
  else alert('Login failed')
}
</script>
EOF

# DashboardView.vue
cat >  views/DashboardView.vue <<'EOF'
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
EOF

# UpdateFruits.vue
cat >  views/UpdateFruits.vue <<'EOF'
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
EOF

# Final message
echo "✅ Vue 3 + Vuetify + JWT Auth setup complete. Run 'npm run dev' to start the frontend."
