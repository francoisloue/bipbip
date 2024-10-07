<script setup>
import { ref, computed } from 'vue'
import { useRoute } from 'vue-router';

const route = useRoute();

const currentUrl = computed(() => route.path);
console.log(currentUrl);
</script>

<template>
  <div class="week">
    <router-link to="/day/lundi" class="day" :class="{ 'active': currentUrl === '/day/lundi' }">L</router-link>
    <router-link to="/day/mardi" class="day" :class="{ 'active': currentUrl === '/day/mardi' }">M</router-link>
    <router-link to="/day/mercredi" class="day" :class="{ 'active': currentUrl === '/day/mercredi' }">M</router-link>
    <router-link to="/day/jeudi" class="day" :class="{ 'active': currentUrl === '/day/jeudi' }">J</router-link>
    <router-link to="/day/vendredi" class="day" :class="{ 'active': currentUrl === '/day/vendredi' }">V</router-link>
    <router-link to="/day/samedi" class="day" :class="{ 'active': currentUrl === '/day/samedi' }">S</router-link>
    <router-link to="/day/dimanche" class="day" :class="{ 'active': currentUrl === '/day/dimanche' }">D</router-link>
  </div>
</template>

<style scoped>
.week {
  display: flex;
  float: row;
  justify-content: space-around;
  width: 100%;
  height: 70px;
  background-color: #6999FF;
  align-items: center;
}

.day {
  background-color: white;
  border-radius: 100%;
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
}

.active {
  background-color: #6999FF;
  color: white;
  border: 2px solid white;
}
</style>
