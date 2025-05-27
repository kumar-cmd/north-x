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
