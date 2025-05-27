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
