#!/bin/bash

# Exit immediately on error
set -e

echo "🚀 Creating Vue 3 + Vite + Vuetify project..."

# # Create Vite project
# npm create vite@latest fruit-search-app -- --template vue
# cd fruit-search-app

# # Install dependencies
# npm install
# npm install vuetify@next vue-router sass sass-loader@^12.0.0 axios

# Create directories
mkdir -p   plugins
mkdir -p   components

# Create Vuetify plugin
cat <<EOF >   plugins/vuetify.js
import 'vuetify/styles'
import { createVuetify } from 'vuetify'
import * as components from 'vuetify/components'
import * as directives from 'vuetify/directives'

export default createVuetify({
  components,
  directives,
})
EOF

# Create FruitSearch.vue component
cat <<EOF >   components/FruitSearch.vue
<template>
  <v-container class="mt-5">
    <v-text-field
      v-model="query"
      label="Search fruits"
      prepend-icon="mdi-magnify"
      @input="searchFruits"
      clearable
    ></v-text-field>

    <v-list>
      <v-list-item
        v-for="fruit in fruits"
        :key="fruit.id"
      >
        <v-list-item-content>
          <v-list-item-title>{{ fruit.fruits }}</v-list-item-title>
          <v-list-item-subtitle>Quantity: {{ fruit.number }}</v-list-item-subtitle>
        </v-list-item-content>
      </v-list-item>
    </v-list>

    <div v-if="loading" class="text-center mt-5">
      <v-progress-circular indeterminate color="primary"></v-progress-circular>
    </div>
  </v-container>
</template>

<script setup>
import { ref } from 'vue'
import axios from 'axios'

const query = ref('')
const fruits = ref([])
const loading = ref(false)

const searchFruits = async () => {
  if (query.value.length === 0) {
    fruits.value = []
    return
  }

  loading.value = true
  try {
    const res = await axios.get(\`https://xnorth.pythonanywhere.com/api/search?q=\${query.value}\`)
    fruits.value = res.data
  } catch (err) {
    console.error(err)
  } finally {
    loading.value = false
  }
}
</script>
EOF

# Replace main.js
cat <<EOF >   main.js
import { createApp } from 'vue'
import App from './App.vue'
import vuetify from './plugins/vuetify'

createApp(App).use(vuetify).mount('#app')
EOF

# Replace App.vue
cat <<EOF >   App.vue
<template>
  <v-app>
    <v-main>
      <FruitSearch />
    </v-main>
  </v-app>
</template>

<script setup>
import FruitSearch from './components/FruitSearch.vue'
</script>
EOF

echo "✅ Project setup complete!"
echo "👉 Run the project:"
echo "   cd fruit-search-app"
echo "   npm run dev"
