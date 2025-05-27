#!/bin/bash
# script.sh

# Create project structure
mkdir -p src/{assets,components,layouts,router,stores,services,views}

# Create main files
cat > src/main.js <<EOL
import { createApp } from 'vue'
import App from './App.vue'
import { createPinia } from 'pinia'
import vuetify from './plugins/vuetify'
import router from './router'
import '@mdi/font/css/materialdesignicons.css'

const app = createApp(App)
app.use(createPinia())
app.use(vuetify)
app.use(router)
app.mount('#app')
EOL

cat > src/plugins/vuetify.js <<EOL
import { createVuetify } from 'vuetify'
import * as components from 'vuetify/components'
import * as directives from 'vuetify/directives'

export default createVuetify({
  components,
  directives,
  theme: {
    defaultTheme: 'light',
    themes: {
      light: {
        colors: {
          primary: '#1976D2',
          secondary: '#424242',
          accent: '#82B1FF',
        }
      }
    }
  }
})
EOL

cat > src/router/index.js <<EOL
import { createRouter, createWebHistory } from 'vue-router'
import Home from '@/views/Home.vue'
import Dashboard from '@/views/Dashboard.vue'
import Login from '@/views/Login.vue'
import { useAuthStore } from '@/stores/auth'

const routes = [
  { path: '/', name: 'Home', component: Home },
  { path: '/login', name: 'Login', component: Login },
  { 
    path: '/dashboard', 
    name: 'Dashboard', 
    component: Dashboard,
    meta: { requiresAuth: true }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to, from, next) => {
  const authStore = useAuthStore()
  if (to.meta.requiresAuth && !authStore.user) {
    next('/login')
  } else {
    next()
  }
})

export default router
EOL

cat > src/stores/auth.js <<EOL
import { defineStore } from 'pinia'
import axios from 'axios'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: JSON.parse(localStorage.getItem('user')),
    returnUrl: null
  }),
  actions: {
    async login(email, password) {
      try {
        const response = await axios.post('https://xnorth.pythonanywhere.com/api/login', {
          email, password
        })
        
        this.user = { email, token: response.data.access_token }
        localStorage.setItem('user', JSON.stringify(this.user))
        this.router.push(this.returnUrl || '/dashboard')
      } catch (error) {
        console.error('Login failed:', error)
        throw error
      }
    },
    logout() {
      this.user = null
      localStorage.removeItem('user')
      this.router.push('/login')
    }
  }
})
EOL

cat > src/services/api.js <<EOL
import axios from 'axios'
import { useAuthStore } from '@/stores/auth'

const api = axios.create({
  baseURL: 'https://xnorth.pythonanywhere.com/api',
  headers: {
    'Content-Type': 'application/json'
  }
})

api.interceptors.request.use(config => {
  const authStore = useAuthStore()
  if (authStore.user?.token) {
    config.headers.Authorization = \`Bearer \${authStore.user.token}\`
  }
  return config
})

api.interceptors.response.use(
  response => response,
  error => {
    if (error.response?.status === 401) {
      useAuthStore().logout()
    }
    return Promise.reject(error)
  }
)

export default {
  fruits: {
    get: () => api.get('/fruits'),
    create: (data) => api.post('/fruits', data),
    update: (id, data) => api.put(\`/fruits/\${id}\`, data),
    delete: (id) => api.delete(\`/fruits/\${id}\`),
    search: (query) => api.get('/search', { params: { q: query } })
  }
}
EOL

cat > src/views/Login.vue <<EOL
<template>
  <v-container class="fill-height">
    <v-row justify="center">
      <v-col cols="12" sm="8" md="6">
        <v-card class="elevation-12">
          <v-toolbar color="primary" dark flat>
            <v-toolbar-title>Login Form</v-toolbar-title>
          </v-toolbar>
          <v-card-text>
            <v-form @submit.prevent="handleLogin">
              <v-text-field
                v-model="email"
                label="Email"
                prepend-icon="mdi-email"
                type="email"
                required
              ></v-text-field>
              <v-text-field
                v-model="password"
                label="Password"
                prepend-icon="mdi-lock"
                type="password"
                required
              ></v-text-field>
              <v-btn type="submit" color="primary" block>Login</v-btn>
            </v-form>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import { useAuthStore } from '@/stores/auth'

export default {
  data: () => ({
    email: '',
    password: ''
  }),
  methods: {
    async handleLogin() {
      try {
        await useAuthStore().login(this.email, this.password)
      } catch (error) {
        console.error('Login error:', error)
      }
    }
  }
}
</script>
EOL

cat > src/views/Dashboard.vue <<EOL
<template>
  <v-container>
    <v-data-table
      :headers="headers"
      :items="fruits"
      :loading="loading"
      class="elevation-1"
    >
      <template v-slot:top>
        <v-toolbar flat>
          <v-toolbar-title>Fruits Management</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-btn color="primary" dark @click="showCreateDialog = true">
            New Fruit
          </v-btn>
        </v-toolbar>
      </template>

      <template v-slot:item.actions="{ item }">
        <v-icon small @click="editItem(item)">mdi-pencil</v-icon>
        <v-icon small @click="deleteItem(item)" class="ml-2">mdi-delete</v-icon>
      </template>
    </v-data-table>

    <v-dialog v-model="showCreateDialog" max-width="500">
      <v-card>
        <v-card-title>Create New Fruit</v-card-title>
        <v-card-text>
          <v-form @submit.prevent="createFruit">
            <v-text-field v-model="newFruit.name" label="Fruit Name"></v-text-field>
            <v-text-field v-model="newFruit.quantity" label="Quantity" type="number"></v-text-field>
            <v-btn type="submit" color="primary">Create</v-btn>
          </v-form>
        </v-card-text>
      </v-card>
    </v-dialog>
  </v-container>
</template>

<script>
import { useFruitsStore } from '@/stores/fruits'

export default {
  data: () => ({
    headers: [
      { text: 'Fruit Name', value: 'fruits' },
      { text: 'Quantity', value: 'number' },
      { text: 'Actions', value: 'actions', sortable: false }
    ],
    showCreateDialog: false,
    newFruit: {
      name: '',
      quantity: 0
    }
  }),
  computed: {
    fruits() {
      return useFruitsStore().fruits
    },
    loading() {
      return useFruitsStore().loading
    }
  },
  mounted() {
    useFruitsStore().fetchFruits()
  },
  methods: {
    createFruit() {
      useFruitsStore().createFruit({
        fruits: this.newFruit.name,
        number: this.newFruit.quantity
      })
      this.showCreateDialog = false
    },
    editItem(item) {
      // Implement edit functionality
    },
    deleteItem(item) {
      useFruitsStore().deleteFruit(item.id)
    }
  }
}
</script>
EOL

cat > src/stores/fruits.js <<EOL
import { defineStore } from 'pinia'
import api from '@/services/api'

export const useFruitsStore = defineStore('fruits', {
  state: () => ({
    fruits: [],
    loading: false,
    error: null
  }),
  actions: {
    async fetchFruits() {
      this.loading = true
      try {
        const response = await api.fruits.get()
        this.fruits = response.data
      } catch (error) {
        this.error = error
      } finally {
        this.loading = false
      }
    },
    async createFruit(data) {
      try {
        await api.fruits.create(data)
        await this.fetchFruits()
      } catch (error) {
        console.error('Create error:', error)
      }
    },
    async deleteFruit(id) {
      try {
        await api.fruits.delete(id)
        await this.fetchFruits()
      } catch (error) {
        console.error('Delete error:', error)
      }
    }
  }
})
EOL

cat > vite.config.js <<EOL
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': '/src'
    }
  }
})
EOL

# Create App.vue
cat > src/App.vue <<EOL
<template>
  <v-app>
    <v-app-bar app color="primary" dark>
      <v-toolbar-title>Fruits App</v-toolbar-title>
      <v-spacer></v-spacer>
      <v-btn v-if="!user" to="/login" text>Login</v-btn>
      <v-btn v-else @click="logout" text>Logout</v-btn>
    </v-app-bar>

    <v-main>
      <router-view></router-view>
    </v-main>
  </v-app>
</template>

<script>
import { useAuthStore } from '@/stores/auth'

export default {
  computed: {
    user() {
      return useAuthStore().user
    }
  },
  methods: {
    logout() {
      useAuthStore().logout()
    }
  }
}
</script>
EOL

# Install dependencies
npm install vue@3 vue-router@4 pinia vuetify@next axios @mdi/font @vueuse/core
