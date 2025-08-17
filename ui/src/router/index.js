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
    },
    {
      path: "/watch",
      name: "watch",
      component: () => import("@/views/WatchView.vue"),
    },
    {
      path: "/musicals",
      name: "musicals",
      component: () => import("@/views/MusicalsView.vue"),
    },
    {
      path: "/music",
      name: "music",
      component: () => import("@/views/MusicView.vue"),
    },
    {
      path: "/sentences",
      name: "sentences",
      component: () => import("@/views/SentencesView.vue"),
    },
    {
      path: "/:pathMatch(.*)*",
      name: "NotFound",
      component: () => import("@/views/404View.vue"),
    },
  ],
});

export default router;
