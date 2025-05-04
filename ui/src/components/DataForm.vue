<script setup>
import { computed, toRefs } from 'vue';

const props = defineProps({
  fields: { type: Array, required: true },
  modelValue: { type: Object, required: true },
  onSubmit: { type: Function, required: true },
  submitLabel: { type: String, default: 'Submit' },
  cancelLabel: { type: String, default: 'Cancel' },
  loading: { type: Boolean, default: false },
  error: { type: String, default: '' },
});
const emit = defineEmits(['update:modelValue', 'cancel']);

const localModel = computed({
  get: () => props.modelValue,
  set: (val) => emit('update:modelValue', val),
});

function handleInput(field, value) {
  localModel.value[field] = value;
  emit('update:modelValue', { ...localModel.value });
}

function handleSubmit(e) {
  e.preventDefault();
  props.onSubmit();
}
</script>
<template>
  <form @submit="handleSubmit" autocomplete="off">
    <div v-for="field in fields" :key="field.name" class="form-control grid mb-4">
      <label class="label justify-start" :for="field.name">
        <span class="label-text text-base-content font-semibold">
          {{ field.label }}<span v-if="field.required" class="text-error">*</span>
        </span>
      </label>
      <component
        :is="field.type === 'textarea' ? 'textarea' : 'input'"
        v-model="localModel[field.name]"
        :id="field.name"
        :type="field.type !== 'textarea' ? field.type : undefined"
        :placeholder="field.placeholder"
        :required="field.required"
        :rows="field.rows || (field.type === 'textarea' ? 3 : undefined)"
        class="input input-bordered bg-base-100 text-base-content textarea-bordered"
        :aria-required="field.required ? 'true' : 'false'"
        :aria-describedby="field.desc ? field.name + '-desc' : undefined"
      />
      <span v-if="field.desc" :id="field.name + '-desc'" class="text-xs text-base-content/60">{{ field.desc }}</span>
    </div>
    <div class="flex flex-wrap justify-end gap-2 mt-4">
      <button type="button" class="btn btn-ghost text-base-content" @click="$emit('cancel')" :disabled="loading">{{ cancelLabel }}</button>
      <button type="submit" class="btn btn-primary text-primary-content" :disabled="loading">
        <span v-if="loading" class="loading loading-spinner loading-xs mr-2"></span>
        {{ submitLabel }}
      </button>
    </div>
    <div v-if="error" class="alert alert-error mt-4 text-error-content">{{ error }}</div>
  </form>
</template>
