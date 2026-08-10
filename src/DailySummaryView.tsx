import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { FormEvent, useLayoutEffect, useMemo, useRef, useState } from "react";
import { TbPlus } from "react-icons/tb";
import {
  createDailySummary,
  getDailySummaries,
  updateDailySummary,
} from "./api";
import { formatDateValue, parseDateValue } from "./date";
import type {
  CreateDailySummaryInput,
  DailySummariesResponse,
  DailySummary,
  UpdateDailySummaryInput,
} from "./shared/domain";

const queryKey = ["daily-summaries"] as const;

const dateFormatter = new Intl.DateTimeFormat(undefined, {
  weekday: "long",
  month: "long",
  day: "numeric",
  year: "numeric",
});

interface SummaryEditorProps {
  summary: DailySummary;
  isSaving: boolean;
  onSave: (summary: DailySummary, input: UpdateDailySummaryInput) => void;
}

function SummaryEditor({ summary, isSaving, onSave }: SummaryEditorProps) {
  const [heading, setHeading] = useState(summary.heading);
  const [body, setBody] = useState(summary.body);

  const dirty = heading !== summary.heading || body !== summary.body;
  const date = parseDateValue(summary.date);

  const save = (event: FormEvent) => {
    event.preventDefault();
    if (!dirty || isSaving) return;
    onSave(summary, { heading, body, version: summary.version });
  };

  return (
    <form
      className="rounded-lg border border-plain-300 bg-plain-50 p-4"
      onSubmit={save}
    >
      <div className="flex items-center gap-3">
        <time className="text-2xs font-medium text-plain-600" dateTime={summary.date}>
          {date ? dateFormatter.format(date) : summary.date}
        </time>
        <span className="ml-auto text-3xs text-plain-500">
          {isSaving ? "Saving…" : dirty ? "Unsaved" : "Saved"}
        </span>
      </div>
      <input
        id={`daily-summary-heading-${summary.id}`}
        className="mt-3 w-full border-0 bg-transparent px-0 py-1 text-lg font-semibold text-plain-900 placeholder:text-plain-400 focus:ring-0"
        value={heading}
        maxLength={500}
        placeholder="Heading"
        aria-label={`Heading for ${summary.date}`}
        onChange={(event) => setHeading(event.target.value)}
      />
      <textarea
        className="mt-2 min-h-32 w-full resize-y rounded-md border border-plain-300 bg-plain-white p-3 text-sm leading-6 text-plain-900 placeholder:text-plain-400 focus:border-plain-500 focus:ring-0"
        value={body}
        maxLength={20000}
        placeholder="What happened today?"
        aria-label={`Body for ${summary.date}`}
        onChange={(event) => setBody(event.target.value)}
      />
      <div className="mt-2 flex justify-end">
        <button
          className="rounded-md bg-plain-900 px-3 py-1.5 text-xs font-medium text-plain-white hover:bg-plain-800 disabled:cursor-default disabled:opacity-30"
          type="submit"
          disabled={!dirty || isSaving}
        >
          Save
        </button>
      </div>
    </form>
  );
}

export default function DailySummaryView() {
  const queryClient = useQueryClient();
  const [date, setDate] = useState(() => formatDateValue(new Date()));
  const focusSummaryId = useRef<string | null>(null);

  const summariesQuery = useQuery({
    queryKey,
    queryFn: getDailySummaries,
  });

  const createMutation = useMutation({
    mutationFn: (input: CreateDailySummaryInput) => createDailySummary(input),
    onMutate: async (input) => {
      focusSummaryId.current = input.id;
      await queryClient.cancelQueries({ queryKey });
      const previous = queryClient.getQueryData<DailySummariesResponse>(queryKey);
      const now = new Date().toISOString();
      const optimisticSummary: DailySummary = {
        id: input.id,
        date: input.date,
        heading: input.heading,
        body: input.body,
        version: 1,
        createdAt: now,
        updatedAt: now,
      };
      queryClient.setQueryData<DailySummariesResponse>(queryKey, {
        dailySummaries: [...(previous?.dailySummaries ?? []), optimisticSummary].sort(
          (left, right) => right.date.localeCompare(left.date),
        ),
      });
      return { previous };
    },
    onError: (_error, input, context) => {
      queryClient.setQueryData(queryKey, context?.previous);
      if (focusSummaryId.current === input.id) focusSummaryId.current = null;
    },
    onSuccess: (savedSummary) => {
      queryClient.setQueryData<DailySummariesResponse>(queryKey, (current) => ({
        dailySummaries: (current?.dailySummaries ?? []).map((summary) =>
          summary.id === savedSummary.id ? savedSummary : summary,
        ),
      }));
    },
    onSettled: () => {
      void queryClient.invalidateQueries({ queryKey });
    },
  });

  const updateMutation = useMutation({
    mutationFn: ({
      summaryId,
      input,
    }: {
      summaryId: string;
      input: UpdateDailySummaryInput;
    }) => updateDailySummary(summaryId, input),
    onMutate: async ({ summaryId, input }) => {
      await queryClient.cancelQueries({ queryKey });
      const previous = queryClient.getQueryData<DailySummariesResponse>(queryKey);
      queryClient.setQueryData<DailySummariesResponse>(queryKey, {
        dailySummaries: (previous?.dailySummaries ?? []).map((summary) =>
          summary.id === summaryId
            ? {
                ...summary,
                ...input,
                version: summary.version + 1,
                updatedAt: new Date().toISOString(),
              }
            : summary,
        ),
      });
      return { previous };
    },
    onError: (_error, _variables, context) => {
      queryClient.setQueryData(queryKey, context?.previous);
    },
    onSuccess: (savedSummary) => {
      queryClient.setQueryData<DailySummariesResponse>(queryKey, (current) => ({
        dailySummaries: (current?.dailySummaries ?? []).map((summary) =>
          summary.id === savedSummary.id ? savedSummary : summary,
        ),
      }));
    },
    onSettled: () => {
      void queryClient.invalidateQueries({ queryKey });
    },
  });

  const summaries = useMemo(
    () => summariesQuery.data?.dailySummaries ?? [],
    [summariesQuery.data?.dailySummaries],
  );
  const dateAlreadyExists = summaries.some((summary) => summary.date === date);

  useLayoutEffect(() => {
    const summaryId = focusSummaryId.current;
    if (!summaryId || !summaries.some((summary) => summary.id === summaryId)) {
      return;
    }
    const input = document.getElementById(`daily-summary-heading-${summaryId}`);
    if (!(input instanceof HTMLInputElement)) return;
    input.focus();
    focusSummaryId.current = null;
  }, [summaries]);

  const error = summariesQuery.error ?? createMutation.error ?? updateMutation.error;

  return (
    <section
      id="daily-summary-panel"
      className="mt-6"
      role="tabpanel"
      aria-labelledby="daily-summary-tab"
    >
      <div className="flex items-center gap-2">
        <h2 className="text-sm font-semibold text-plain-700">Daily summaries</h2>
        <div className="ml-auto flex items-center gap-2">
          <input
            className="h-7 rounded-md border-plain-300 bg-plain-white py-1 text-2xs text-plain-800 focus:border-plain-500 focus:ring-0"
            type="date"
            value={date}
            aria-label="New daily summary date"
            onChange={(event) => setDate(event.target.value)}
          />
          <button
            className="flex h-7 w-7 items-center justify-center rounded text-plain-900 hover:bg-plain-200 disabled:opacity-20"
            type="button"
            disabled={!date || dateAlreadyExists || createMutation.isPending}
            title={dateAlreadyExists ? "A summary already exists for this date" : "Add daily summary"}
            aria-label="Add daily summary"
            onClick={() =>
              createMutation.mutate({
                id: crypto.randomUUID(),
                date,
                heading: "",
                body: "",
              })
            }
          >
            <TbPlus aria-hidden="true" className="h-4 w-4" />
          </button>
        </div>
      </div>

      {error && (
        <p className="mt-3 rounded border border-red-300 bg-red-50 p-3 text-xs text-red-800">
          {error.message}
        </p>
      )}

      {summariesQuery.isPending ? (
        <p className="mt-6 text-sm text-plain-500">Loading summaries…</p>
      ) : summaries.length === 0 ? (
        <p className="mt-6 text-center text-sm text-plain-500">
          No daily summaries yet.
        </p>
      ) : (
        <div className="mt-4 space-y-3">
          {summaries.map((summary) => (
            <SummaryEditor
              key={`${summary.id}:${summary.version}`}
              summary={summary}
              isSaving={
                updateMutation.isPending &&
                updateMutation.variables?.summaryId === summary.id
              }
              onSave={(current, input) =>
                updateMutation.mutate({ summaryId: current.id, input })
              }
            />
          ))}
        </div>
      )}
    </section>
  );
}
