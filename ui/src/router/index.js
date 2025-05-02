import { useAuthStore } from "@/stores/auth";
import { createRouter, createWebHistory } from "vue-router";

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: "/",
      name: "home",
      component: () => import("@/views/HomeView.vue"),
    },
    {
      path: "/feeds",
      name: "feeds",
      component: () => import("@/views/FeedsView.vue"),
      meta: { requiresAuth: true },
    },
    {
      path: "/watch",
      name: "watch",
      component: () => import("@/views/WatchView.vue"),
      meta: { requiresAuth: true },
    },
    {
      path: "/musicals",
      name: "musicals",
      component: () => import("@/views/MusicalsView.vue"),
      meta: { requiresAuth: true },
    },
    {
      path: "/music",
      name: "music",
      component: () => import("@/views/MusicView.vue"),
      meta: { requiresAuth: true },
    },
    {
      path: "/sentences",
      name: "sentences",
      component: () => import("@/views/SentencesView.vue"),
      meta: { requiresAuth: true },
    },
    // Authentication routes
    {
      path: "/login",
      name: "login",
      component: () => import("@/views/LoginView.vue"),
      meta: { guestOnly: true },
    },
    {
      path: "/verify",
      name: "verify",
      component: () => import("@/views/VerifyView.vue"),
      meta: { guestOnly: true },
    },
    {
      path: "/:pathMatch(.*)*",
      name: "NotFound",
      component: () => import("@/views/404View.vue"),
    },
  ],
});

// Navigation guards
router.beforeEach((to, from, next) => {
  const authStore = useAuthStore();

  // Routes that require authentication
  if (to.matched.some((record) => record.meta.requiresAuth)) {
    if (!authStore.isAuthenticated()) {
      next({ name: "login", query: { redirect: to.fullPath } });
    } else {
      next();
    }
  }
  // Routes that are only accessible for guests
  else if (to.matched.some((record) => record.meta.guestOnly)) {
    if (authStore.isAuthenticated()) {
      next({ name: "home" });
    } else {
      next();
    }
  } else {
    next();
  }
});

export default router;
