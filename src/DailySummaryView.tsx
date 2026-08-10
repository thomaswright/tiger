import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  useCallback,
  useEffect,
  useLayoutEffect,
  useMemo,
  useRef,
  useState,
} from "react";
import { TbPlus } from "react-icons/tb";
import {
  createDailySummary,
  getDailySummaries,
  updateDailySummary,
} from "./api";
import DateSelect from "./DateSelect";
import { formatDateValue, parseDateValue } from "./date";
import type {
  CreateDailySummaryInput,
  DailySummariesResponse,
  DailySummary,
  UpdateDailySummaryInput,
} from "./shared/domain";

const queryKey = ["daily-summaries"] as const;
const autosaveDelay = 700;

const dateFormatter = new Intl.DateTimeFormat(undefined, {
  weekday: "long",
  month: "long",
  day: "numeric",
  year: "numeric",
});

interface SummaryEditorProps {
  summary: DailySummary;
  isSaving: boolean;
  onSave: (variables: UpdateSummaryVariables) => void;
}

interface UpdateSummaryVariables {
  summaryId: string;
  input: UpdateDailySummaryInput;
}

function SummaryEditor({ summary, isSaving, onSave }: SummaryEditorProps) {
  const [body, setBody] = useState(summary.body);
  const saveTimer = useRef<number | null>(null);
  const lastAttemptedBody = useRef<string | null>(null);

  const dirty = body !== summary.body;
  const date = parseDateValue(summary.date);

  const save = useCallback(() => {
    if (!dirty || isSaving) return;
    lastAttemptedBody.current = body;
    onSave({
      summaryId: summary.id,
      input: { body, version: summary.version },
    });
  }, [body, dirty, isSaving, onSave, summary.id, summary.version]);

  useEffect(() => {
    if (!dirty || isSaving || body === lastAttemptedBody.current) {
      return;
    }

    const timer = window.setTimeout(save, autosaveDelay);
    saveTimer.current = timer;
    return () => {
      window.clearTimeout(timer);
      if (saveTimer.current === timer) saveTimer.current = null;
    };
  }, [body, dirty, isSaving, save]);

  const saveOnBlur = () => {
    if (saveTimer.current !== null) {
      window.clearTimeout(saveTimer.current);
      saveTimer.current = null;
    }
    save();
  };

  return (
    <article className="">
      <div className="flex items-center gap-3">
        <time
          className=" text-2xs font-medium text-plain-600"
          dateTime={summary.date}
        >
          {date ? dateFormatter.format(date) : summary.date}
        </time>
      </div>
      <textarea
        id={`daily-summary-body-${summary.id}`}
        className="mt-3 min-h-32 w-full resize-y border-l-2 border-0 border-plain-300 bg-plain-white py-0  px-3 text-sm leading-6 text-plain-900 placeholder:text-plain-400 focus:border-plain-500 focus:ring-0"
        value={body}
        maxLength={20000}
        placeholder="daily summary"
        aria-label={`Body for ${summary.date}`}
        onChange={(event) => setBody(event.target.value)}
        onBlur={saveOnBlur}
      />
    </article>
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
      const previous =
        queryClient.getQueryData<DailySummariesResponse>(queryKey);
      const now = new Date().toISOString();
      const optimisticSummary: DailySummary = {
        id: input.id,
        date: input.date,
        body: input.body,
        version: 1,
        createdAt: now,
        updatedAt: now,
      };
      queryClient.setQueryData<DailySummariesResponse>(queryKey, {
        dailySummaries: [
          ...(previous?.dailySummaries ?? []),
          optimisticSummary,
        ].sort((left, right) => right.date.localeCompare(left.date)),
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
    mutationFn: ({ summaryId, input }: UpdateSummaryVariables) =>
      updateDailySummary(summaryId, input),
    onMutate: async ({ summaryId, input }) => {
      await queryClient.cancelQueries({ queryKey });
      const previous =
        queryClient.getQueryData<DailySummariesResponse>(queryKey);
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
    const input = document.getElementById(`daily-summary-body-${summaryId}`);
    if (!(input instanceof HTMLTextAreaElement)) return;
    input.focus();
    focusSummaryId.current = null;
  }, [summaries]);

  const error =
    summariesQuery.error ?? createMutation.error ?? updateMutation.error;

  return (
    <section
      id="daily-summary-panel"
      className="mt-6"
      role="tabpanel"
      aria-labelledby="daily-summary-tab"
    >
      <div className="flex items-center gap-2">
        <h2 className="pl-3 text-sm font-semibold text-plain-700">
          Daily summaries
        </h2>
        <div className="ml-auto flex items-center gap-2">
          <DateSelect
            value={date || null}
            ariaLabel="New daily summary date"
            onChange={(value) => setDate(value ?? "")}
          />
          <button
            className="flex h-7 w-7 items-center justify-center rounded text-plain-900 hover:bg-plain-200 disabled:opacity-20"
            type="button"
            disabled={!date || dateAlreadyExists || createMutation.isPending}
            title={
              dateAlreadyExists
                ? "A summary already exists for this date"
                : "Add daily summary"
            }
            aria-label="Add daily summary"
            onClick={() =>
              createMutation.mutate({
                id: crypto.randomUUID(),
                date,
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
              key={summary.id}
              summary={summary}
              isSaving={
                updateMutation.isPending &&
                updateMutation.variables?.summaryId === summary.id
              }
              onSave={updateMutation.mutate}
            />
          ))}
        </div>
      )}
    </section>
  );
}
