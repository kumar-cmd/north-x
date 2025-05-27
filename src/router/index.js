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
