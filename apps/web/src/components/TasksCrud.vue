<script setup lang="ts">
import { onMounted, ref } from "vue";
import { api } from "../http/client";

type TaskStatus = "pending" | "doing" | "done";

type Task = {
  id: number;
  title: string;
  description: string | null;
  status: TaskStatus;
  due_date: string | null;
};

const tasks = ref<Task[]>([]);
const loading = ref(true);
const saving = ref(false);
const error = ref<string | null>(null);
const errors = ref<string[]>([]);
const filters = ref({
  status: "",
  due_date: "",
});

const form = ref({
  title: "",
  description: "",
  status: "pending" as TaskStatus,
  due_date: "",
});

const editingId = ref<number | null>(null);
const editForm = ref({
  title: "",
  description: "",
  status: "pending" as TaskStatus,
  due_date: "",
});

const fetchTasks = async () => {
  error.value = null;

  try {
    const res = await api.get<Task[]>("/tasks", {
      params: {
        status: filters.value.status || undefined,
        due_date: filters.value.due_date || undefined,
      },
    });
    tasks.value = res.data;
  } catch (err) {
    error.value = "Falha ao carregar tasks";
  } finally {
    loading.value = false;
  }
};

const resetErrors = () => {
  error.value = null;
  errors.value = [];
};

const createTask = async () => {
  resetErrors();
  saving.value = true;

  try {
    const res = await api.post<Task>("/tasks", { task: form.value });
    tasks.value = [res.data, ...tasks.value];
    form.value = { title: "", description: "", status: "pending", due_date: "" };
  } catch (err: any) {
    if (err?.response?.status === 422) {
      errors.value = err.response.data?.errors ?? ["Falha ao validar task"];
    } else {
      error.value = "Falha ao criar task";
    }
  } finally {
    saving.value = false;
  }
};

const startEdit = (task: Task) => {
  editingId.value = task.id;
  editForm.value = {
    title: task.title,
    description: task.description ?? "",
    status: task.status,
    due_date: task.due_date ?? "",
  };
  resetErrors();
};

const cancelEdit = () => {
  editingId.value = null;
  editForm.value = { title: "", description: "", status: "pending", due_date: "" };
  resetErrors();
};

const updateTask = async () => {
  if (!editingId.value) return;
  resetErrors();
  saving.value = true;

  try {
    const res = await api.patch<Task>(`/tasks/${editingId.value}`, {
      task: editForm.value,
    });
    tasks.value = tasks.value.map((task) =>
      task.id === res.data.id ? res.data : task,
    );
    cancelEdit();
  } catch (err: any) {
    if (err?.response?.status === 422) {
      errors.value = err.response.data?.errors ?? ["Falha ao validar task"];
    } else {
      error.value = "Falha ao atualizar task";
    }
  } finally {
    saving.value = false;
  }
};

const deleteTask = async (taskId: number) => {
  resetErrors();

  try {
    await api.delete(`/tasks/${taskId}`);
    tasks.value = tasks.value.filter((task) => task.id !== taskId);
  } catch (err) {
    error.value = "Falha ao remover task";
  }
};

onMounted(fetchTasks);
</script>

<template>
  <section class="space-y-8">
    <header class="space-y-3">
      <p class="text-xs uppercase tracking-[0.35em] text-slate-500">Tasks</p>
      <div class="space-y-2">
        <h1 class="text-3xl font-semibold text-slate-100">Painel de tarefas</h1>
        <p class="max-w-xl text-sm text-slate-400">
          Organização simples para acompanhar pendencias e entregas.
        </p>
      </div>
    </header>

    <div class="grid gap-8 lg:grid-cols-[0.9fr_1.1fr]">
      <div class="rounded-2xl border border-slate-800/70 bg-slate-950/60 p-6">
        <div class="flex items-center justify-between">
          <h2 class="text-base font-semibold text-slate-100">Nova task</h2>
          <span class="text-xs text-slate-500">Campos com * sao obrigatórios</span>
        </div>
        <div class="mt-5 grid gap-4">
          <label class="text-sm">
            <span class="text-slate-300">Titulo *</span>
            <input
              v-model.trim="form.title"
              class="mt-2 w-full rounded-xl border border-slate-800 bg-slate-900/40 px-4 py-3 text-sm text-slate-100 outline-none ring-1 ring-transparent transition focus:border-slate-500 focus:ring-slate-500"
              placeholder="Ex.: Preparar deploy"
              type="text"
            />
          </label>
          <label class="text-sm">
            <span class="text-slate-300">Descrição</span>
            <textarea
              v-model.trim="form.description"
              class="mt-2 w-full rounded-xl border border-slate-800 bg-slate-900/40 px-4 py-3 text-sm text-slate-100 outline-none ring-1 ring-transparent transition focus:border-slate-500 focus:ring-slate-500"
              rows="3"
              placeholder="Detalhes da tarefa"
            />
          </label>
          <div class="grid gap-4 md:grid-cols-2">
            <label class="text-sm">
              <span class="text-slate-300">Status *</span>
              <select
                v-model="form.status"
                class="mt-2 w-full rounded-xl border border-slate-800 bg-slate-900/40 px-4 py-3 text-sm text-slate-100 outline-none ring-1 ring-transparent transition focus:border-slate-500 focus:ring-slate-500"
              >
                <option value="pending">pending</option>
                <option value="doing">doing</option>
                <option value="done">done</option>
              </select>
            </label>
            <label class="text-sm">
              <span class="text-slate-300">Vencimento</span>
              <input
                v-model="form.due_date"
                class="mt-2 w-full rounded-xl border border-slate-800 bg-slate-900/40 px-4 py-3 text-sm text-slate-100 outline-none ring-1 ring-transparent transition focus:border-slate-500 focus:ring-slate-500"
                type="date"
              />
            </label>
          </div>
        </div>
        <div class="mt-5 flex flex-wrap items-center gap-3">
          <button
            class="rounded-full bg-slate-100 px-5 py-2 text-sm font-semibold text-slate-900 transition hover:bg-white disabled:opacity-60"
            :disabled="saving"
            @click="createTask"
          >
            {{ saving ? "Salvando..." : "Criar task" }}
          </button>
          <span v-if="error" class="text-sm text-rose-300">{{ error }}</span>
        </div>
        <ul v-if="errors.length" class="mt-3 space-y-1 text-sm text-rose-300">
          <li v-for="msg in errors" :key="msg">{{ msg }}</li>
        </ul>
      </div>

      <div class="rounded-2xl border border-slate-800/70 bg-slate-950/40 p-6">
        <div class="flex flex-wrap items-center justify-between gap-3">
          <div>
            <h2 class="text-base font-semibold text-slate-100">Lista</h2>
            <p class="text-xs text-slate-500">Filtre por status ou vencimento.</p>
          </div>
          <button
            class="rounded-full border border-slate-700 px-4 py-2 text-xs text-slate-300 transition hover:border-slate-500"
            @click="fetchTasks"
          >
            Atualizar
          </button>
        </div>

        <div class="mt-4 grid gap-3 md:grid-cols-2">
          <label class="text-sm">
            <span class="text-slate-300">Status</span>
            <select
              v-model="filters.status"
              class="mt-2 w-full rounded-xl border border-slate-800 bg-slate-900/40 px-4 py-2 text-sm text-slate-100 outline-none ring-1 ring-transparent transition focus:border-slate-500 focus:ring-slate-500"
            >
              <option value="">Todos</option>
              <option value="pending">pending</option>
              <option value="doing">doing</option>
              <option value="done">done</option>
            </select>
          </label>
          <label class="text-sm">
            <span class="text-slate-300">Vencimento</span>
            <input
              v-model="filters.due_date"
              class="mt-2 w-full rounded-xl border border-slate-800 bg-slate-900/40 px-4 py-2 text-sm text-slate-100 outline-none ring-1 ring-transparent transition focus:border-slate-500 focus:ring-slate-500"
              type="date"
            />
          </label>
        </div>
        <div class="mt-3 flex flex-wrap gap-2">
          <button
            class="rounded-full bg-slate-100 px-4 py-1 text-xs font-semibold text-slate-900"
            @click="fetchTasks"
          >
            Aplicar filtros
          </button>
          <button
            class="rounded-full border border-slate-700 px-4 py-1 text-xs text-slate-300"
            @click="filters = { status: '', due_date: '' }; fetchTasks()"
          >
            Limpar
          </button>
        </div>

        <div v-if="loading" class="mt-4 text-sm text-slate-400">Carregando...</div>
        <div
          v-else-if="tasks.length === 0"
          class="mt-4 rounded-2xl border border-dashed border-slate-800 p-6 text-sm text-slate-400"
        >
          Nenhuma task encontrada. Crie a primeira no formulário ao lado.
        </div>

        <div v-else class="mt-4 space-y-4">
          <article
            v-for="task in tasks"
            :key="task.id"
            class="rounded-2xl border border-slate-800 bg-slate-900/40 p-4 transition hover:border-slate-700"
          >
            <div class="flex flex-wrap items-start justify-between gap-3">
              <div>
                <h3 class="text-base font-semibold text-slate-100">{{ task.title }}</h3>
                <p v-if="task.description" class="mt-1 text-sm text-slate-400">
                  {{ task.description }}
                </p>
                <p class="mt-2 text-xs text-slate-500">
                  Vencimento: {{ task.due_date || "-" }}
                </p>
              </div>
              <span
                class="rounded-full px-3 py-1 text-xs font-semibold"
                :class="{
                  'bg-amber-400/10 text-amber-200': task.status === 'pending',
                  'bg-sky-400/10 text-sky-200': task.status === 'doing',
                  'bg-emerald-400/10 text-emerald-200': task.status === 'done',
                }"
              >
                {{ task.status }}
              </span>
            </div>

            <div v-if="editingId === task.id" class="mt-4 grid gap-4 md:grid-cols-2">
              <label class="text-sm">
                <span class="text-slate-300">Titulo</span>
                <input
                  v-model.trim="editForm.title"
                  class="mt-2 w-full rounded-xl border border-slate-800 bg-slate-900/40 px-4 py-2 text-sm text-slate-100 outline-none ring-1 ring-transparent transition focus:border-slate-500 focus:ring-slate-500"
                  type="text"
                />
              </label>
              <label class="text-sm">
                <span class="text-slate-300">Status</span>
                <select
                  v-model="editForm.status"
                  class="mt-2 w-full rounded-xl border border-slate-800 bg-slate-900/40 px-4 py-2 text-sm text-slate-100 outline-none ring-1 ring-transparent transition focus:border-slate-500 focus:ring-slate-500"
                >
                  <option value="pending">pending</option>
                  <option value="doing">doing</option>
                  <option value="done">done</option>
                </select>
              </label>
              <label class="text-sm">
                <span class="text-slate-300">Descrição</span>
                <textarea
                  v-model.trim="editForm.description"
                  class="mt-2 w-full rounded-xl border border-slate-800 bg-slate-900/40 px-4 py-2 text-sm text-slate-100 outline-none ring-1 ring-transparent transition focus:border-slate-500 focus:ring-slate-500"
                  rows="2"
                />
              </label>
              <label class="text-sm">
                <span class="text-slate-300">Vencimento</span>
                <input
                  v-model="editForm.due_date"
                  class="mt-2 w-full rounded-xl border border-slate-800 bg-slate-900/40 px-4 py-2 text-sm text-slate-100 outline-none ring-1 ring-transparent transition focus:border-slate-500 focus:ring-slate-500"
                  type="date"
                />
              </label>
            </div>

            <div class="mt-4 flex flex-wrap gap-2">
              <button
                v-if="editingId !== task.id"
                class="rounded-full border border-slate-700 px-3 py-1 text-xs text-slate-300 transition hover:border-slate-500"
                @click="startEdit(task)"
              >
                Editar
              </button>
              <button
                v-if="editingId === task.id"
                class="rounded-full bg-slate-100 px-3 py-1 text-xs font-semibold text-slate-900"
                :disabled="saving"
                @click="updateTask"
              >
                Salvar
              </button>
              <button
                v-if="editingId === task.id"
                class="rounded-full border border-slate-700 px-3 py-1 text-xs text-slate-300"
                @click="cancelEdit"
              >
                Cancelar
              </button>
              <button
                class="rounded-full border border-rose-500/40 px-3 py-1 text-xs text-rose-300 transition hover:border-rose-400/60"
                @click="deleteTask(task.id)"
              >
                Remover
              </button>
            </div>
          </article>
        </div>
      </div>
    </div>
  </section>
</template>
