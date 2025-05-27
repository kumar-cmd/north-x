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
