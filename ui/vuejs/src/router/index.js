import { createRouter, createWebHistory } from "vue-router";

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: "/",
      component: () => import("@/views/HomeView.vue"),
    },
    {
      path: "/books",
      component: () => import("@/views/BooksView.vue"),
    },
    {
      path: "/:pathMatch(.*)*",
      component: () => import("@/views/404View.vue"),},
  ],
});

export default router;
