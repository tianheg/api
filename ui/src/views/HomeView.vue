<script setup>
import { useAuthStore } from "@/stores/auth";
import {
  TransitionPresets,
  useElementVisibility,
  useTransition,
} from "@vueuse/core";
import { computed, ref } from "vue";

const authStore = useAuthStore();
const isAuthenticated = computed(() => authStore.isAuthenticated());

// Animation for the title
const titleOpacity = ref(0);
const titleTranslateY = ref(20);
const titleEl = ref(null);

// Animate cards with a staggered effect
const card1 = ref(null);
const card2 = ref(null);
const card3 = ref(null);

const isCard1Visible = useElementVisibility(card1);
const isCard2Visible = useElementVisibility(card2);
const isCard3Visible = useElementVisibility(card3);

// Setup fade-in animation for the title
const titleOpacityTransition = useTransition(titleOpacity, {
  duration: 800,
  transition: TransitionPresets.easeOutCubic,
});

const titleTranslateYTransition = useTransition(titleTranslateY, {
  duration: 800,
  transition: TransitionPresets.easeOutCubic,
});

// Set initial values
setTimeout(() => {
  titleOpacity.value = 1;
  titleTranslateY.value = 0;
}, 100);
</script>

<template>
  <div class="container mx-auto px-4 py-8 bg-base-200">
    <h1 ref="titleEl" class="text-4xl font-bold text-center text-primary mb-8"
      :style="{
        opacity: titleOpacityTransition,
        transform: `translateY(${titleTranslateYTransition}px)`,
      }">
      Love life, love me
    </h1>
    <p class="py-6 text-center text-lg text-base-content"
      :style="{
        opacity: titleOpacityTransition,
        transform: `translateY(${titleTranslateYTransition}px)`,
        transitionDelay: '200ms',
      }">
      "The person who has lived the most is not the one with the most years but the one with the richest
      experiences."
      <br>― Jean-Jacques Rousseau
    </p>

    <template v-if="isAuthenticated">
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <RouterLink ref="card1" to="/books"
          class="card bg-base-100 shadow-lg hover:shadow-xl transition-shadow duration-300 border border-base-300"
          :style="{
            opacity: isCard1Visible ? 1 : 0,
            transform: isCard1Visible ? 'translateY(0)' : 'translateY(20px)',
            transition: 'all 0.5s ease-out',
          }">
          <div class="card-body items-center text-center">
            <h2 class="card-title text-xl mb-2 text-primary">Books</h2>
            <p class="text-base-content">Manage your book collection</p>
          </div>
        </RouterLink>

        <RouterLink ref="card2" to="/watch"
          class="card bg-base-100 shadow-lg hover:shadow-xl transition-shadow duration-300 border border-base-300"
          :style="{
            opacity: isCard2Visible ? 1 : 0,
            transform: isCard2Visible ? 'translateY(0)' : 'translateY(20px)',
            transition: 'all 0.5s ease-out 0.1s',
          }">
          <div class="card-body items-center text-center">
            <h2 class="card-title text-xl mb-2 text-primary">Watch</h2>
            <p class="text-base-content">Track what I'm watching</p>
          </div>
        </RouterLink>
      </div>
    </template>

    <template v-else>
      <div class="max-w-md mx-auto">
        <div class="text-center space-y-4 mb-10"
          :style="{
            opacity: titleOpacityTransition,
            transform: `translateY(${titleTranslateYTransition}px)`,
            transitionDelay: '300ms',
          }">
          <h2 class="text-2xl font-semibold text-primary">My Personal Archive</h2>
          <p class="text-base-content">
            Organize my books, watch in one place
          </p>
        </div>
      </div>
    </template>
  </div>
</template>