<script setup>
import { computed, onMounted, nextTick, watch } from 'vue';

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

const internalModel = computed({
  get: () => props.modelValue || {},
  set: (value) => emit('update:modelValue', value),
});

// Auto-resize textarea to fit content
function autoResizeTextarea(eventOrElement) {
  const textarea = eventOrElement?.target || eventOrElement;
  if (!textarea) return;
  textarea.style.height = 'auto';
  textarea.style.height = `${textarea.scrollHeight}px`;
  textarea.style.overflowY = 'hidden';
}

// Function to handle input changes
function handleFieldUpdate(fieldName, value) {
  const updatedModel = { ...internalModel.value, [fieldName]: value };
  internalModel.value = updatedModel;
}

function handleSubmit(e) {
  e.preventDefault();
  props.onSubmit();
}

function handleKeydown(e) {
  if ((e.ctrlKey || e.metaKey) && e.key === 'Enter') {
    e.preventDefault();
    props.onSubmit();
  }
}

// Combined input handler to update model and auto-resize textarea if needed
function onInput(field, event) {
  handleFieldUpdate(field.name, event.target.value);
  if (field.type === 'textarea') {
    autoResizeTextarea(event);
  }
}

// Watch for modelValue changes to auto-resize textarea fields
watch(
  () => props.modelValue,
  (newVal) => {
    nextTick(() => {
      props.fields.forEach(field => {
        if (field.type === 'textarea') {
          const textarea = document.getElementById(field.name);
          if (textarea) autoResizeTextarea(textarea);
        }
      });
    });
  },
  { deep: true }
);

onMounted(() => {
  nextTick(() => {
    // Auto-resize all textareas on mount (for pre-filled values)
    props.fields.forEach(field => {
      if (field.type === 'textarea') {
        const textarea = document.getElementById(field.name);
        if (textarea) autoResizeTextarea(textarea);
      }
    });
  });
});
</script>
<template>
  <form @submit="handleSubmit" @keydown="handleKeydown" autocomplete="off">
    <div v-for="field in fields" :key="field.name" class="form-control grid mb-4">
      <label class="label justify-start" :for="field.name">
        <span class="label-text text-base-content font-semibold">
          {{ field.label }}<span v-if="field.required" class="text-error">*</span>
        </span>
      </label>
      <component
        :is="field.type === 'textarea' ? 'textarea' : 'input'"
        :id="field.name"
        :type="field.type !== 'textarea' ? field.type : undefined"
        :placeholder="field.placeholder"
        v-model="internalModel[field.name]"
        @input="onInput(field, $event)"
        :class="field.type === 'textarea'
          ? 'textarea textarea-bordered bg-base-100 text-base-content'
          : 'input input-bordered bg-base-100 text-base-content'"
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
