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
