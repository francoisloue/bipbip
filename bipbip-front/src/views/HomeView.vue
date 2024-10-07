<script setup lang="ts">
import Week from '../components/Week.vue';
</script>

<template>
  <main>
    <header class="header">
      <p class="header__date">Lundi 07 Octobre 2024</p>
      <div class="dayCounter">
        <p>5</p>
        <img src="./../assets/img/medicament_logo.svg" alt="">
      </div>
    </header>

    <Week />

    <p>{{ $route.params.day }}</p>
  </main>
</template>

<style scoped>
.header {
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  padding: 1rem;
  align-items: center;
}

.header__date {
  font-weight: bold;
}

.dayCounter {
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: #D9D9D9;
  padding: 0.5rem 1rem;
  border-radius: 20px;
  gap: 10px;
}
</style>