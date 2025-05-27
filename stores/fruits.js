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
