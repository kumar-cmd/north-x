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
    config.headers.Authorization = `Bearer ${authStore.user.token}`
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
    update: (id, data) => api.put(`/fruits/${id}`, data),
    delete: (id) => api.delete(`/fruits/${id}`),
    search: (query) => api.get('/search', { params: { q: query } })
  }
}
