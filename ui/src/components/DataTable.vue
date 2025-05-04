<script setup>
import { computed } from 'vue';

const props = defineProps({
  columns: { type: Array, required: true },
  items: { type: Array, required: true },
  loading: { type: Boolean, default: false },
  actions: { type: Array, default: () => [] }, // [{label, icon, onClick(item)}]
  emptyText: { type: String, default: 'No data found.' },
  page: { type: Number, default: 1 },
  pageSize: { type: Number, default: 10 },
  total: { type: Number, default: 0 },
});
const emit = defineEmits(['update:page']);
const totalPages = computed(() => Math.max(1, Math.ceil(props.total / props.pageSize)));
function setPage(p) {
  if (p >= 1 && p <= totalPages.value && p !== props.page) emit('update:page', p);
}
const getPageButtons = computed(() => {
  const pages = [];
  const total = totalPages.value;
  const current = props.page;
  if (total <= 5) {
    for (let i = 1; i <= total; i++) pages.push(i);
  } else {
    pages.push(1);
    if (current > 3) pages.push('...');
    const start = Math.max(2, current - 1);
    const end = Math.min(total - 1, current + 1);
    for (let i = start; i <= end; i++) pages.push(i);
    if (current < total - 2) pages.push('...');
    pages.push(total);
  }
  return pages;
});
</script>
<template>
  <div class="overflow-x-auto">
    <table class="table table-zebra table-lg table-hover rounded-box shadow border border-base-300 w-full">
      <thead class="bg-base-200 text-base-content sticky top-0 z-10">
        <tr>
          <th v-for="col in columns" :key="col.key" class="text-left">{{ col.label }}</th>
          <th v-if="actions.length" class="text-left">Actions</th>
        </tr>
      </thead>
      <tbody class="bg-base-100 text-base-content">
        <tr v-if="!loading && !items.length">
          <td :colspan="columns.length + (actions.length ? 1 : 0)" class="text-center text-base-content/60">{{ emptyText }}</td>
        </tr>
        <tr v-for="item in items" :key="item.id" class="hover:bg-base-200 transition-colors">
          <td v-for="col in columns" :key="col.key">
            <slot :name="col.key" :item="item">
              {{ item[col.key] }}
            </slot>
          </td>
          <td v-if="actions.length">
            <div class="flex gap-2">
              <button v-for="action in actions" :key="action.label" :class="['btn btn-sm', action.label === 'Edit' ? 'btn-outline btn-info' : '', action.label === 'Delete' ? 'btn-error' : '', 'text-base-content']" @click="() => action.onClick(item)" :aria-label="action.label">
                <span v-if="action.icon" v-html="action.icon" class="mr-1"></span>{{ action.label }}
              </button>
            </div>
          </td>
        </tr>
      </tbody>
    </table>
    <div v-if="loading" class="flex justify-center my-8">
      <span class="loading loading-spinner loading-lg text-primary"></span>
    </div>
    <div v-if="total > pageSize" class="flex justify-center mt-4">
      <div class="join">
        <button class="btn btn-sm join-item" :disabled="props.page === 1" @click="setPage(props.page - 1)">&laquo;</button>
        <template v-for="p in getPageButtons" :key="p">
          <button v-if="p !== '...'" class="btn btn-sm join-item" :class="p === props.page ? 'btn-primary text-primary-content' : ''" @click="setPage(p)">{{ p }}</button>
          <span v-else class="btn btn-sm join-item btn-disabled cursor-default">...</span>
        </template>
        <button class="btn btn-sm join-item" :disabled="props.page === totalPages" @click="setPage(props.page + 1)">&raquo;</button>
      </div>
    </div>
  </div>
</template>
