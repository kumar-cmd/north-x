#!/bin/bash

# Exit on error
set -e

# APP_NAME="fruit-search-app"

# echo "🔧 Creating Vue 3 + Vite + Vuetify project..."
# npm create vite@latest $APP_NAME -- --template vue
# cd $APP_NAME

# echo "📦 Installing dependencies..."
# npm install
# npm install vuetify@next axios @mdi/font vue-router
# npm install sass sass-loader@^13.0.0 -D

# Create Vuetify plugin
mkdir -p src/plugins
cat <<EOF > src/plugins/vuetify.js
import 'vuetify/styles'
import { createVuetify } from 'vuetify'
import { aliases, mdi } from 'vuetify/iconsets/mdi'

export default createVuetify({
  icons: {
    defaultSet: 'mdi',
    aliases,
    sets: { mdi }
  }
})
EOF

# Set up main.js
cat <<EOF > src/main.js
import { createApp } from 'vue'
import App from './App.vue'
import vuetify from './plugins/vuetify'
import '@mdi/font/css/materialdesignicons.css'

createApp(App).use(vuetify).mount('#app')
EOF

# Create search UI in App.vue
cat <<EOF > src/App.vue
<template>
  <v-app>
    <v-main>
      <v-container>
        <v-text-field
          v-model="search"
          label="Search Fruit"
          @keyup.enter="fetchFruits"
          append-icon="mdi-magnify"
          @click:append="fetchFruits"
        ></v-text-field>

        <v-list two-line>
          <v-list-item
            v-for="fruit in results"
            :key="fruit.id"
          >
            <v-list-item-content>
              <v-list-item-title>{{ fruit.fruits }}</v-list-item-title>
              <v-list-item-subtitle>Quantity: {{ fruit.number }}</v-list-item-subtitle>
            </v-list-item-content>
          </v-list-item>
        </v-list>
      </v-container>
    </v-main>
  </v-app>
</template>

<script setup>
import { ref } from 'vue'
import axios from 'axios'

const search = ref('')
const results = ref([])

const fetchFruits = async () => {
  try {
    const token = localStorage.getItem('token') // Must be set after login
    const response = await axios.get(
      \`https://xnorth.pythonanywhere.com/api/search?q=\${search.value}\`,
      {
        headers: {
          Authorization: \`Bearer \${token}\`
        }
      }
    )
    results.value = response.data
  } catch (error) {
    alert('Failed to search fruits.')
  }
}
</script>
EOF

# Done
echo "✅ Search-only Vue app ready in ./$APP_NAME"
echo "👉 To run it:"
echo "cd $APP_NAME && npm run dev"
