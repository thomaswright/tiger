import { Fragment, useEffect, useRef, useState } from "react";
import { formatDateValue } from "./date";

interface CalendarProps {
  value: Date | null;
  onChange: (value: Date | null) => void;
}

const DEFAULT_START_OFFSET = -1;
const DEFAULT_END_OFFSET = 3;
const WINDOW_SHIFT = 4;

const rangeFormatter = new Intl.DateTimeFormat(undefined, {
  month: "short",
  year: "numeric",
});
const monthFormatter = new Intl.DateTimeFormat(undefined, { month: "short" });
const accessibleDateFormatter = new Intl.DateTimeFormat(undefined, {
  weekday: "long",
  month: "long",
  day: "numeric",
  year: "numeric",
});

const startOfMonth = (date: Date) =>
  new Date(date.getFullYear(), date.getMonth(), 1);
const endOfMonth = (date: Date) =>
  new Date(date.getFullYear(), date.getMonth() + 1, 0);
const addMonths = (date: Date, amount: number) =>
  new Date(date.getFullYear(), date.getMonth() + amount, 1);
const isSameDay = (first: Date, second: Date) =>
  first.getFullYear() === second.getFullYear() &&
  first.getMonth() === second.getMonth() &&
  first.getDate() === second.getDate();
const getDaysInMonth = (date: Date) => endOfMonth(date).getDate();

const getDays = (start: Date, end: Date) => {
  const days: Date[] = [];
  for (
    let cursor = new Date(start);
    cursor <= end;
    cursor = new Date(cursor.getFullYear(), cursor.getMonth(), cursor.getDate() + 1)
  ) {
    days.push(cursor);
  }
  return days;
};

const getWeeks = (days: Date[]) => {
  const weeks: Array<Array<Date | null>> = [];
  let week: Array<Date | null> = Array.from({ length: 7 }, () => null);
  for (const day of days) {
    week[day.getDay()] = day;
    if (day.getDay() === 6) {
      weeks.push(week);
      week = Array.from({ length: 7 }, () => null);
    }
  }
  if (week.some(Boolean)) weeks.push(week);
  return weeks;
};

export default function Calendar({ value, onChange }: CalendarProps) {
  const today = new Date();
  const centerDate = value ?? today;
  const [[startOffset, endOffset], setOffsets] = useState<[number, number]>([
    DEFAULT_START_OFFSET,
    DEFAULT_END_OFFSET,
  ]);
  const scrollTarget = useRef(formatDateValue(centerDate));
  const scrollContainer = useRef<HTMLDivElement>(null);
  const start = startOfMonth(addMonths(centerDate, startOffset));
  const end = endOfMonth(addMonths(centerDate, endOffset));
  const weeks = getWeeks(getDays(start, end));

  useEffect(() => {
    const frame = requestAnimationFrame(() => {
      const target = scrollContainer.current?.querySelector<HTMLElement>(
        `[data-calendar-date="${scrollTarget.current}"]`,
      );
      target?.scrollIntoView({ behavior: "smooth", block: "start" });
    });
    return () => cancelAnimationFrame(frame);
  }, []);

  const shiftWindow = (direction: -1 | 1) => {
    setOffsets(([currentStart, currentEnd]) => [
      currentStart + WINDOW_SHIFT * direction,
      currentEnd + WINDOW_SHIFT * direction,
    ]);
  };

  const rangeControls = () => (
    <div className="flex w-full items-center justify-around py-1 text-2xs font-bold">
      <button
        className="flex h-6 w-6 items-center justify-center rounded hover:bg-[var(--t2)]"
        onClick={() => shiftWindow(-1)}
        aria-label="Show earlier months"
        type="button"
      >
        ←
      </button>
      <span aria-live="polite">
        {rangeFormatter.format(start)} – {rangeFormatter.format(end)}
      </span>
      <button
        className="flex h-6 w-6 items-center justify-center rounded hover:bg-[var(--t2)]"
        onClick={() => shiftWindow(1)}
        aria-label="Show later months"
        type="button"
      >
        →
      </button>
    </div>
  );

  return (
    <div
      ref={scrollContainer}
      className="h-64 w-64 overflow-y-scroll rounded border border-[var(--t2)] bg-[var(--t0)] p-3 text-[var(--t10)]"
      aria-label="Choose a due date"
    >
      {rangeControls()}
      <div className="py-2" role="grid">
        {weeks.map((week) => {
          const firstDay = week.find((day): day is Date => day !== null);
          return (
            <div
              className="relative grid grid-cols-7 pl-4"
              key={firstDay ? formatDateValue(firstDay) : "empty-week"}
              role="row"
            >
              {week.map((day, index) => {
                if (!day) {
                  return <div key={`blank-${index}`} aria-hidden="true" />;
                }

                const dayOfMonth = day.getDate();
                const daysInMonth = getDaysInMonth(day);
                const selected = value ? isSameDay(day, value) : false;
                const monthBoundaryClasses = [
                  dayOfMonth <= 7 ? "border-t border-t-[var(--t8)]" : "",
                  dayOfMonth > daysInMonth - 7
                    ? "border-b border-b-[var(--t8)]"
                    : "border-b",
                  dayOfMonth === 1 && day.getDay() > 0
                    ? "border-l border-l-[var(--t8)]"
                    : day.getDay() === 0
                      ? "border-l"
                      : "",
                  dayOfMonth === daysInMonth && day.getDay() < 6
                    ? "border-r-[var(--t8)]"
                    : "",
                ].join(" ");

                return (
                  <Fragment key={formatDateValue(day)}>
                    <button
                      data-calendar-date={formatDateValue(day)}
                      className={`flex h-7 items-center justify-center border-r border-[var(--t3)] text-2xs hover:bg-blue-200 focus-visible:z-10 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-blue-500 dark:hover:bg-blue-800 ${
                        isSameDay(day, today) ? "font-bold text-red-500" : ""
                      } ${
                        selected ? "bg-blue-200 dark:bg-blue-800" : ""
                      } ${monthBoundaryClasses}`}
                      onClick={() => onChange(day)}
                      aria-label={accessibleDateFormatter.format(day)}
                      aria-pressed={selected}
                      role="gridcell"
                      type="button"
                    >
                      {dayOfMonth}
                    </button>
                    {dayOfMonth === 15 && (
                      <div
                        className="absolute left-1 top-0 flex -translate-x-1/2 translate-y-1/2 -rotate-90 gap-1 text-center text-2xs font-bold"
                        aria-hidden="true"
                      >
                        <span>{monthFormatter.format(day)}</span>
                      </div>
                    )}
                  </Fragment>
                );
              })}
            </div>
          );
        })}
      </div>
      {rangeControls()}
      <div className="flex items-center justify-center pt-1">
        <button
          className="rounded px-2 py-1 text-2xs hover:bg-[var(--t2)] disabled:opacity-40"
          disabled={!value}
          onClick={() => onChange(null)}
          type="button"
        >
          Clear Date
        </button>
      </div>
    </div>
  );
}
