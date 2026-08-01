import { useState } from "react";
import { formatDateValue } from "./date";

interface CalendarProps {
  value: Date | null;
  onChange: (value: Date | null) => void;
}

const WEEKDAYS = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
const monthFormatter = new Intl.DateTimeFormat(undefined, {
  month: "long",
  year: "numeric",
});
const dayFormatter = new Intl.DateTimeFormat(undefined, {
  weekday: "long",
  month: "long",
  day: "numeric",
  year: "numeric",
});
const startOfMonth = (date: Date) =>
  new Date(date.getFullYear(), date.getMonth(), 1);
const addMonths = (date: Date, amount: number) =>
  new Date(date.getFullYear(), date.getMonth() + amount, 1);
const isSameDay = (first: Date, second: Date) =>
  first.getFullYear() === second.getFullYear() &&
  first.getMonth() === second.getMonth() &&
  first.getDate() === second.getDate();

export default function Calendar({ value, onChange }: CalendarProps) {
  const today = new Date();
  const [visibleMonth, setVisibleMonth] = useState(() =>
    startOfMonth(value ?? today),
  );
  const days = Array.from(
    {
      length: new Date(
        visibleMonth.getFullYear(),
        visibleMonth.getMonth() + 1,
        0,
      ).getDate(),
    },
    (_, index) =>
      new Date(visibleMonth.getFullYear(), visibleMonth.getMonth(), index + 1),
  );
  const leadingBlanks = visibleMonth.getDay();

  return (
    <div
      className="w-64 rounded-lg border border-[var(--t3)] bg-[var(--t0)] p-3 text-[var(--t10)] shadow-lg"
      aria-label="Choose a due date"
    >
      <div className="flex items-center justify-between">
        <button
          className="h-8 w-8 rounded hover:bg-[var(--t2)]"
          onClick={() => setVisibleMonth((month) => addMonths(month, -1))}
          aria-label="Previous month"
          type="button"
        >
          ←
        </button>
        <div className="text-xs font-semibold" aria-live="polite">
          {monthFormatter.format(visibleMonth)}
        </div>
        <button
          className="h-8 w-8 rounded hover:bg-[var(--t2)]"
          onClick={() => setVisibleMonth((month) => addMonths(month, 1))}
          aria-label="Next month"
          type="button"
        >
          →
        </button>
      </div>

      <div className="mt-2 grid grid-cols-7" role="row">
        {WEEKDAYS.map((weekday) => (
          <div
            className="flex h-6 items-center justify-center text-2xs font-medium text-[var(--t6)]"
            key={weekday}
            role="columnheader"
          >
            {weekday.slice(0, 1)}
          </div>
        ))}
      </div>

      <div className="grid grid-cols-7" role="grid">
        {Array.from({ length: leadingBlanks }, (_, index) => (
          <div key={`blank-${index}`} aria-hidden="true" />
        ))}
        {days.map((day) => {
          const selected = value ? isSameDay(day, value) : false;
          const isToday = isSameDay(day, today);
          return (
            <button
              className={`flex h-8 items-center justify-center rounded text-xs hover:bg-blue-100 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-blue-500 ${
                selected
                  ? "bg-blue-600 font-semibold text-white hover:bg-blue-600"
                  : isToday
                    ? "font-bold text-red-600"
                    : ""
              }`}
              key={formatDateValue(day)}
              onClick={() => onChange(day)}
              aria-label={dayFormatter.format(day)}
              aria-pressed={selected}
              role="gridcell"
              type="button"
            >
              {day.getDate()}
            </button>
          );
        })}
      </div>

      <div className="mt-3 flex items-center justify-between border-t border-[var(--t2)] pt-2">
        <button
          className="rounded px-2 py-1 text-xs text-[var(--t7)] hover:bg-[var(--t2)]"
          onClick={() => onChange(today)}
          type="button"
        >
          Today
        </button>
        <button
          className="rounded px-2 py-1 text-xs text-[var(--t7)] hover:bg-[var(--t2)] disabled:opacity-40"
          disabled={!value}
          onClick={() => onChange(null)}
          type="button"
        >
          Clear date
        </button>
      </div>
    </div>
  );
}
