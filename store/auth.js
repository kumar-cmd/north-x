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
