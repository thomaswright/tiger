type interval = {
  start: Date.t,
  @as("end")
  end_: Date.t,
}

type duration = {
  years: int,
  months: int,
  days: int,
  hours: int,
  minutes: int,
  seconds: int,
}
// from https://github.com/shakacode/rescript-date-fns/blob/master/src/DateFns.res (MIT License)

type locale

// Common Helpers
@module("date-fns/closestIndexTo")
external closestIndexTo: (Date.t, array<Date.t>) => int = "default"
@module("date-fns/closestTo")
external closestTo: (Date.t, array<Date.t>) => Date.t = "default"
@module("date-fns/compareAsc") external compareAsc: (Date.t, Date.t) => int = "default"
@module("date-fns/compareDesc") external compareDesc: (Date.t, Date.t) => int = "default"

@module("date-fns/format") external format: (Date.t, string) => string = "default"
type formatOptions = {
  locale: option<locale>,
  weekStartsOn: option<int>,
  firstWeekContainsDate: option<int>,
  useAdditionalWeekYearTokens: option<bool>,
  useAdditionalDayOfYearTokens: option<bool>,
}
@module("date-fns/format")
external formatOpt: (Date.t, string, formatOptions) => string = "default"
@module("date-fns/formatDistance")
external formatDistance: (Date.t, Date.t) => string = "default"
type formatDistanceOptions = {
  includeSeconds: option<bool>,
  addSuffix: option<bool>,
  locale: option<locale>,
}
@module("date-fns/formatDistance")
external formatDistanceOpt: (Date.t, Date.t, formatDistanceOptions) => string = "default"
@module("date-fns/formatDistanceStrict")
external formatDistanceStrict: (Date.t, Date.t) => string = "default"
type formatDistanceStrictOptions = {
  addSuffix: option<bool>,
  unit: option<string>,
  roundingMethod: option<string>,
  locale: option<locale>,
}
@module("date-fns/formatDistanceStrict")
external formatDistanceStrictOpt: (Date.t, Date.t, formatDistanceStrictOptions) => string =
  "default"
@module("date-fns/formatDistanceToNow")
external formatDistanceToNow: Date.t => string = "default"
type formatDistanceToNowOptions = {
  includeSeconds: option<bool>,
  addSuffix: option<bool>,
  locale: option<locale>,
}
@module("date-fns/formatDistanceToNow")
external formatDistanceToNowOpt: (Date.t, formatDistanceToNowOptions) => string = "default"
@module("date-fns/formatISO") external formatISO: Date.t => string = "default"
type formatISOOptions = {
  format: option<string>,
  representation: option<string>,
}
@module("date-fns/formatISO")
external formatISOOpt: (Date.t, formatISOOptions) => string = "default"
@module("date-fns/formatISO9075") external formatISO9075: Date.t => string = "default"
type formatISO9075Options = {
  format: option<string>,
  representation: option<string>,
}
@module("date-fns/formatISO9075")
external formatISO9075Opt: (Date.t, formatISO9075Options) => string = "default"

@module("date-fns/formatRFC3339") external formatRFC3339: Date.t => string = "default"
type formatRFC3339Options = {fractionDigits: option<int>}
@module("date-fns/formatRFC3339")
external formatRFC3339Options: (Date.t, formatRFC3339Options) => string = "default"
@module("date-fns/formatRFC7231") external formatRFC7231: Date.t => string = "default"
@module("date-fns/formatRelative")
external formatRelative: (Date.t, Date.t) => string = "default"
type formatRelativeOptions = {
  locale: option<locale>,
  weekStartsOn: option<int>,
}
@module("date-fns/formatRelative")
external formatRelativeOpt: (Date.t, Date.t, formatRelativeOptions) => string = "default"
@module("date-fns") external isAfter: (Date.t, Date.t) => bool = "isAfter"
@module("date-fns") external isBefore: (Date.t, Date.t) => bool = "isBefore"
@module("date-fns/isDate") external isDate: 'a => bool = "default"
@module("date-fns/isEqual") external isEqual: (Date.t, Date.t) => bool = "default"
@module("date-fns/isFuture") external isFuture: Date.t => bool = "default"
@module("date-fns/isPast") external isPast: Date.t => bool = "default"
@module("date-fns/isValid") external isValid: 'a => bool = "default"
@module("date-fns/lightFormat") external lightFormat: (Date.t, string) => string = "default"
@module("date-fns/max") external max: array<Date.t> => Date.t = "default"
@module("date-fns/min") external min: array<Date.t> => Date.t = "default"
@module("date-fns/parse") external parse: (string, string, Date.t) => Date.t = "default"
type parseOptions = {
  locale: option<locale>,
  weekStartsOn: option<int>,
  firstWeekContainsDate: option<int>,
  useAdditionalWeekYearTokens: option<bool>,
  useAdditionalDayOfYearTokens: option<bool>,
}
@module("date-fns/parse")
external parseOpt: (string, string, Date.t, parseOptions) => Date.t = "default"
@module("date-fns/parseISO") external parseISO: string => Date.t = "default"
type parseISOOptions = {additionalDigits: option<int>}
@module("date-fns/parseISO")
external parseISOOpt: (string, parseISOOptions) => Date.t = "default"
@module("date-fns/parseJSON") external parseJSONString: string => Date.t = "default"
@module("date-fns/parseJSON") external parseJSONFloat: float => Date.t = "default"
@module("date-fns/parseJSON") external parseJSONInt: int => Date.t = "default"
type setOptions = {
  year: option<int>,
  month: option<int>,
  date: option<int>,
  hours: option<int>,
  minutes: option<int>,
  seconds: option<int>,
  milliseconds: option<int>,
}
@module("date-fns/set") external set: (Date.t, setOptions) => Date.t = "default"
@module("date-fns/toDate") external toDateFloat: float => Date.t = "default"
@module("date-fns/toDate") external toDateInt: int => Date.t = "default"

// Interval Helpers
@module("date-fns/areIntervalsOverlapping")
external areIntervalsOverlapping: (Date.t, Date.t) => bool = "default"
@module("date-fns/eachDayOfInterval")
external eachDayOfInterval: interval => array<Date.t> = "default"
type eachDayOfIntervalOptions = {step: option<int>}
@module("date-fns/eachDayOfInterval")
external eachDayOfIntervalOpt: (interval, eachDayOfIntervalOptions) => array<Date.t> = "default"
@module("date-fns/eachWeekOfInterval")
external eachWeekOfInterval: interval => array<Date.t> = "default"
type eachWeekOfIntervalOptions = {
  locale: option<locale>,
  weekStartsOn: option<int>,
}
@module("date-fns/eachWeekOfInterval")
external eachWeekOfIntervalOpt: (interval, eachWeekOfIntervalOptions) => array<Date.t> = "default"
@module("date-fns/eachWeekendOfInterval")
external eachWeekendOfInterval: interval => array<Date.t> = "default"
@module("date-fns/getOverlappingDaysInIntervals")
external getOverlappingDaysInIntervals: (interval, interval) => int = "default"
@module("date-fns/getOverlappingDaysInIntervals")
external getOverlappingDaysInIntervalsf: (interval, interval) => float = "default"
@module("date-fns/isWithinInterval")
external isWithinInterval: (Date.t, interval) => bool = "default"

// Timestamp Helpers
@module("date-fns/fromUnixTime") external fromUnixTime: float => Date.t = "default"
@module("date-fns/getTime") external getTime: Date.t => float = "default"
@module("date-fns/getUnixTime") external getUnixTime: Date.t => float = "default"

// Millisecond Helpers
@module("date-fns/addMilliseconds")
external addMilliseconds: (Date.t, int) => Date.t = "default"
@module("date-fns/addMilliseconds")
external addMillisecondsf: (Date.t, float) => Date.t = "default"
@module("date-fns/differenceInMilliseconds")
external differenceInMilliseconds: (Date.t, Date.t) => int = "default"
@module("date-fns/differenceInMilliseconds")
external differenceInMillisecondsf: (Date.t, Date.t) => float = "default"
@module("date-fns/getMilliseconds") external getMilliseconds: Date.t => int = "default"
@module("date-fns/getMilliseconds") external getMillisecondsf: Date.t => float = "default"
@module("date-fns/setMilliseconds")
external setMilliseconds: (Date.t, int) => Date.t = "default"
@module("date-fns/setMilliseconds")
external setMillisecondsf: (Date.t, float) => Date.t = "default"
@module("date-fns/subMilliseconds")
external subMilliseconds: (Date.t, int) => Date.t = "default"
@module("date-fns/subMilliseconds")
external subMillisecondsf: (Date.t, float) => Date.t = "default"

// Second Helpers
@module("date-fns/addSeconds") external addSeconds: (Date.t, int) => Date.t = "default"
@module("date-fns/addSeconds") external addSecondsf: (Date.t, float) => Date.t = "default"
@module("date-fns/differenceInSeconds")
external differenceInSeconds: (Date.t, Date.t) => int = "default"
@module("date-fns/differenceInSeconds")
external differenceInSecondsf: (Date.t, Date.t) => float = "default"
@module("date-fns/endOfSecond") external endOfSecond: Date.t => Date.t = "default"
@module("date-fns/getSeconds") external getSeconds: Date.t => int = "default"
@module("date-fns/getSeconds") external getSecondsf: Date.t => float = "default"
@module("date-fns/isSameSecond") external isSameSecond: (Date.t, Date.t) => bool = "default"
@module("date-fns/isThisSecond") external isThisSecond: Date.t => bool = "default"
@module("date-fns/setSeconds") external setSeconds: (Date.t, int) => Date.t = "default"
@module("date-fns/setSeconds") external setSecondsf: (Date.t, float) => Date.t = "default"
@module("date-fns/startOfSecond") external startOfSecond: Date.t => Date.t = "default"
@module("date-fns/subSeconds") external subSeconds: (Date.t, int) => Date.t = "default"
@module("date-fns/subSeconds") external subSecondsf: (Date.t, float) => Date.t = "default"

// Minute Helpers
@module("date-fns/addMinutes") external addMinutes: (Date.t, int) => Date.t = "default"
@module("date-fns/addMinutes") external addMinutesf: (Date.t, float) => Date.t = "default"
@module("date-fns/differenceInMinutes")
external differenceInMinutes: (Date.t, Date.t) => int = "default"
@module("date-fns/differenceInMinutes")
external differenceInMinutesf: (Date.t, Date.t) => float = "default"
@module("date-fns/endOfMinute") external endOfMinute: Date.t => Date.t = "default"
@module("date-fns/getMinutes") external getMinutes: Date.t => int = "default"
@module("date-fns/getMinutes") external getMinutesf: Date.t => float = "default"
@module("date-fns/isSameMinute") external isSameMinute: (Date.t, Date.t) => bool = "default"
@module("date-fns/isThisMinute") external isThisMinute: Date.t => bool = "default"
@module("date-fns/roundToNearestMinutes")
external roundToNearestMinutes: Date.t => Date.t = "default"
type roundToNearestMinutesOptions = {nearestTo: option<int>}
@module("date-fns/roundToNearestMinutes")
external roundToNearestMinutesOpt: (Date.t, roundToNearestMinutesOptions) => Date.t = "default"
@module("date-fns/setMinutes") external setMinutes: (Date.t, int) => Date.t = "default"
@module("date-fns/startOfMinute") external startOfMinute: Date.t => Date.t = "default"
@module("date-fns/subMinutes") external subMinutes: (Date.t, int) => Date.t = "default"
@module("date-fns/subMinutes") external subMinutesf: (Date.t, float) => Date.t = "default"

// Hour Helpers
@module("date-fns/addHours") external addHours: (Date.t, int) => Date.t = "default"
@module("date-fns/addHours") external addHoursf: (Date.t, float) => Date.t = "default"
@module("date-fns/differenceInHours")
external differenceInHours: (Date.t, Date.t) => int = "default"
@module("date-fns/differenceInHours")
external differenceInHoursf: (Date.t, Date.t) => float = "default"
@module("date-fns/endOfHour") external endOfHour: Date.t => Date.t = "default"
@module("date-fns/getHours") external getHours: Date.t => int = "default"
@module("date-fns/getHours") external getHoursf: Date.t => float = "default"
@module("date-fns/isSameHour") external isSameHour: (Date.t, Date.t) => bool = "default"
@module("date-fns/isThisHour") external isThisHour: Date.t => bool = "default"
@module("date-fns/setHours") external setHours: (Date.t, int) => Date.t = "default"
@module("date-fns/setHours") external setHoursf: (Date.t, float) => Date.t = "default"
@module("date-fns/startOfHour") external startOfHour: Date.t => Date.t = "default"
@module("date-fns/subHours") external subHours: (Date.t, int) => Date.t = "default"
@module("date-fns/subHours") external subHoursf: (Date.t, float) => Date.t = "default"

// Day Helpers
@module("date-fns/addBusinessDays")
external addBusinessDays: (Date.t, int) => Date.t = "default"
@module("date-fns/addBusinessDays")
external addBusinessDaysf: (Date.t, float) => Date.t = "default"
@module("date-fns/addDays") external addDays: (Date.t, int) => Date.t = "default"
@module("date-fns/addDays") external addDaysf: (Date.t, float) => Date.t = "default"
@module("date-fns/differenceInBusinessDays")
external differenceInBusinessDays: (Date.t, Date.t) => int = "default"
@module("date-fns/differenceInBusinessDays")
external differenceInBusinessDaysf: (Date.t, Date.t) => float = "default"
@module("date-fns/differenceInCalendarDays")
external differenceInCalendarDays: (Date.t, Date.t) => int = "default"
@module("date-fns/differenceInCalendarDays")
external differenceInCalendarDaysf: (Date.t, Date.t) => float = "default"
@module("date-fns/differenceInDays")
external differenceInDays: (Date.t, Date.t) => int = "default"
@module("date-fns/differenceInDays")
external differenceInDaysf: (Date.t, Date.t) => float = "default"
@module("date-fns/endOfDay") external endOfDay: Date.t => Date.t = "default"
@module("date-fns/endOfToday") external endOfToday: unit => Date.t = "default"
@module("date-fns/endOfTomorrow") external endOfTomorrow: unit => Date.t = "default"
@module("date-fns/endOfYesterday") external endOfYesterday: unit => Date.t = "default"
@module("date-fns/getDate") external getDate: Date.t => int = "default"
@module("date-fns/getDate") external getDatef: Date.t => float = "default"
@module("date-fns/getDayOfYear") external getDayOfYear: Date.t => int = "default"
@module("date-fns/getDayOfYear") external getDayOfYearf: Date.t => float = "default"
@module("date-fns/isSameDay") external isSameDay: (Date.t, Date.t) => bool = "default"
@module("date-fns/isToday") external isToday: Date.t => bool = "default"
@module("date-fns/isTomorrow") external isTomorrow: Date.t => bool = "default"
@module("date-fns/isYesterday") external isYesterday: Date.t => bool = "default"
@module("date-fns/setDate") external setDate: (Date.t, int) => Date.t = "default"
@module("date-fns/setDate") external setDatef: (Date.t, float) => Date.t = "default"
@module("date-fns/setDayOfYear") external setDayOfYear: (Date.t, int) => Date.t = "default"
@module("date-fns/setDayOfYear") external setDayOfYearf: (Date.t, float) => Date.t = "default"
@module("date-fns/startOfDay") external startOfDay: Date.t => Date.t = "default"
@module("date-fns/startOfToday") external startOfToday: unit => Date.t = "default"
@module("date-fns/startOfTomorrow") external startOfTomorrow: unit => Date.t = "default"
@module("date-fns/startOfYesterday") external startOfYesterday: unit => Date.t = "default"
@module("date-fns/subBusinessDays")
external subBusinessDays: (Date.t, int) => Date.t = "default"
@module("date-fns/subBusinessDays")
external subBusinessDaysf: (Date.t, float) => Date.t = "default"
@module("date-fns/subDays") external subDays: (Date.t, int) => Date.t = "default"
@module("date-fns/subDays") external subDaysf: (Date.t, float) => Date.t = "default"

// Weekday Helpers
@module("date-fns/getDay") external getDay: Date.t => int = "default"
@module("date-fns/getDay") external getDayf: Date.t => float = "default"
@module("date-fns/getISODay") external getISODay: Date.t => int = "default"
@module("date-fns/getISODay") external getISODayf: Date.t => float = "default"
@module("date-fns/isFriday") external isFriday: Date.t => bool = "default"
@module("date-fns/isMonday") external isMonday: Date.t => bool = "default"
@module("date-fns/isSaturday") external isSaturday: Date.t => bool = "default"
@module("date-fns/isSunday") external isSunday: Date.t => bool = "default"
@module("date-fns/isThursday") external isThursday: Date.t => bool = "default"
@module("date-fns/isTuesday") external isTuesday: Date.t => bool = "default"
@module("date-fns/isWednesday") external isWednesday: Date.t => bool = "default"
@module("date-fns/isWeekend") external isWeekend: Date.t => bool = "default"
@module("date-fns/setDay") external setDay: (Date.t, int) => Date.t = "default"
@module("date-fns/setDay") external setDayf: (Date.t, float) => Date.t = "default"
type setDayOptions = {
  locale: option<locale>,
  weekStartsOn: option<int>,
}
@module("date-fns/setDay")
external setDayOpt: (Date.t, int, setDayOptions) => Date.t = "default"
@module("date-fns/setDay")
external setDayOptf: (Date.t, float, setDayOptions) => Date.t = "default"
@module("date-fns/setISODay") external setISODay: (Date.t, int) => Date.t = "default"
@module("date-fns/setISODay") external setISODayf: (Date.t, float) => Date.t = "default"

// Week Helpers
type weekOptions = {
  locale: option<locale>,
  weekStartsOn: option<int>,
}
@module("date-fns/addWeeks") external addWeeks: (Date.t, int) => Date.t = "default"
@module("date-fns/addWeeks") external addWeeksf: (Date.t, float) => Date.t = "default"
@module("date-fns/differenceInCalendarWeeks")
external differenceInCalendarWeeks: (Date.t, Date.t) => int = "default"
@module("date-fns/differenceInCalendarWeeks")
external differenceInCalendarWeeksOpt: (Date.t, Date.t, weekOptions) => int = "default"
@module("date-fns/differenceInCalendarWeeks")
external differenceInCalendarWeeksf: (Date.t, Date.t) => float = "default"
@module("date-fns/differenceInCalendarWeeks")
external differenceInCalendarWeeksOptf: (Date.t, Date.t, weekOptions) => float = "default"
@module("date-fns/differenceInWeeks")
external differenceInWeeks: (Date.t, Date.t) => int = "default"
@module("date-fns/differenceInWeeks")
external differenceInWeeksf: (Date.t, Date.t) => float = "default"
@module("date-fns/endOfWeek") external endOfWeek: Date.t => Date.t = "default"
@module("date-fns/endOfWeek")
external endOfWeekOpt: (Date.t, weekOptions) => Date.t = "default"
@module("date-fns/getWeek") external getWeek: Date.t => int = "default"
@module("date-fns/getWeek") external getWeekf: Date.t => float = "default"
type getWeekOptions = {
  locale: option<locale>,
  weekStartsOn: option<int>,
  firstWeekContainsDate: option<int>,
}
@module("date-fns/getWeek") external getWeekOpt: (Date.t, getWeekOptions) => int = "default"
@module("date-fns/getWeek") external getWeekOptf: (Date.t, getWeekOptions) => float = "default"
@module("date-fns/getWeekOfMonth") external getWeekOfMonth: Date.t => int = "default"
@module("date-fns/getWeekOfMonth") external getWeekOfMonthf: Date.t => float = "default"
@module("date-fns/getWeekOfMonth")
external getWeekOfMonthOpt: (Date.t, weekOptions) => int = "default"
@module("date-fns/getWeekOfMonth")
external getWeekOfMonthOptf: (Date.t, weekOptions) => float = "default"
@module("date-fns/getWeeksInMonth") external getWeeksInMonth: Date.t => int = "default"
@module("date-fns/getWeeksInMonth") external getWeeksInMonthf: Date.t => float = "default"
@module("date-fns/getWeeksInMonth")
external getWeeksInMonthOpt: (Date.t, weekOptions) => int = "default"
@module("date-fns/getWeeksInMonth")
external getWeeksInMonthOptf: (Date.t, weekOptions) => float = "default"
@module("date-fns/isSameWeek") external isSameWeek: (Date.t, Date.t) => bool = "default"
@module("date-fns/isSameWeek")
external isSameWeekOpt: (Date.t, Date.t, weekOptions) => bool = "default"
@module("date-fns/isThisWeek") external isThisWeek: Date.t => bool = "default"
@module("date-fns/isThisWeek") external isThisWeekOpt: (Date.t, weekOptions) => bool = "default"
@module("date-fns/lastDayOfWeek") external lastDayOfWeek: Date.t = "default"
@module("date-fns/lastDayOfWeek") external lastDayOfWeekOpt: (Date.t, weekOptions) = "default"
@module("date-fns/setWeek") external setWeek: (Date.t, int) => Date.t = "default"
@module("date-fns/setWeek") external setWeekf: (Date.t, float) => Date.t = "default"
type setWeekOptions = {
  locale: option<locale>,
  weekStartsOn: option<int>,
  firstWeekContainsDate: option<int>,
}
@module("date-fns/setWeek")
external setWeekOpt: (Date.t, int, setWeekOptions) => Date.t = "default"
@module("date-fns/setWeek")
external setWeekOptf: (Date.t, float, setWeekOptions) => Date.t = "default"
@module("date-fns/startOfWeek") external startOfWeek: Date.t => Date.t = "default"
@module("date-fns/startOfWeek")
external startOfWeekOpt: (Date.t, weekOptions) => Date.t = "default"
@module("date-fns/subWeeks") external subWeeks: (Date.t, int) => Date.t = "default"
@module("date-fns/subWeeks") external subWeeksf: (Date.t, float) => Date.t = "default"

// ISO Week Helpers
@module("date-fns/differenceInCalendarISOWeeks")
external differenceInCalendarISOWeeks: (Date.t, Date.t) => int = "default"
@module("date-fns/differenceInCalendarISOWeeks")
external differenceInCalendarISOWeeksf: (Date.t, Date.t) => float = "default"
@module("date-fns/endOfISOWeek") external endOfISOWeek: Date.t => Date.t = "default"
@module("date-fns/getISOWeek") external getISOWeek: Date.t => int = "default"
@module("date-fns/getISOWeek") external getISOWeekf: Date.t => float = "default"
@module("date-fns/isSameISOWeek") external isSameISOWeek: (Date.t, Date.t) => bool = "default"
@module("date-fns/isThisISOWeek") external isThisISOWeek: Date.t => bool = "default"
@module("date-fns/lastDayOfISOWeek") external lastDayOfISOWeek: Date.t => Date.t = "default"
@module("date-fns/setISOWeek") external setISOWeek: (Date.t, int) => Date.t = "default"
@module("date-fns/setISOWeek") external setISOWeekf: (Date.t, float) => Date.t = "default"
@module("date-fns/startOfISOWeek") external startOfISOWeek: Date.t => Date.t = "default"

// Month Helpers
@module("date-fns/addMonths") external addMonths: (Date.t, int) => Date.t = "default"
@module("date-fns/addMonths") external addMonthsf: (Date.t, float) => Date.t = "default"
@module("date-fns/differenceInCalendarMonths")
external differenceInCalendarMonths: (Date.t, Date.t) => int = "default"
@module("date-fns/differenceInCalendarMonths")
external differenceInCalendarMonthsf: (Date.t, Date.t) => float = "default"
@module("date-fns/differenceInMonths")
external differenceInMonths: (Date.t, Date.t) => int = "default"
@module("date-fns/differenceInMonths")
external differenceInMonthsf: (Date.t, Date.t) => float = "default"
@module("date-fns/eachWeekendOfMonth")
external eachWeekendOfMonth: Date.t => array<Date.t> = "default"
@module("date-fns/endOfMonth") external endOfMonth: Date.t => Date.t = "default"
@module("date-fns/getDaysInMonth") external getDaysInMonth: Date.t => int = "default"
@module("date-fns/getDaysInMonth") external getDaysInMonthf: Date.t => float = "default"
@module("date-fns/getMonth") external getMonth: Date.t => int = "default"
@module("date-fns/getMonth") external getMonthf: Date.t => float = "default"
@module("date-fns/isFirstDayOfMonth") external isFirstDayOfMonth: Date.t => bool = "default"
@module("date-fns/isLastDayOfMonth") external isLastDayOfMonth: Date.t => bool = "default"
@module("date-fns/isSameMonth") external isSameMonth: (Date.t, Date.t) => bool = "default"
@module("date-fns/isThisMonth") external isThisMonth: Date.t => bool = "default"
@module("date-fns/lastDayOfMonth") external lastDayOfMonth: Date.t => Date.t = "default"
@module("date-fns/setMonth") external setMonth: (Date.t, int) => Date.t = "default"
@module("date-fns/setMonth") external setMonthf: (Date.t, float) => Date.t = "default"
@module("date-fns/startOfMonth") external startOfMonth: Date.t => Date.t = "default"
@module("date-fns/subMonths") external subMonths: (Date.t, int) => Date.t = "default"
@module("date-fns/subMonths") external subMonthsf: (Date.t, float) => Date.t = "default"

// Quarter Helpers
@module("date-fns/addQuarters") external addQuarters: (Date.t, int) => Date.t = "default"
@module("date-fns/addQuarters") external addQuartersf: (Date.t, float) => Date.t = "default"
@module("date-fns/differenceInCalendarQuarters")
external differenceInCalendarQuarters: (Date.t, Date.t) => int = "default"
@module("date-fns/differenceInCalendarQuarters")
external differenceInCalendarQuartersf: (Date.t, Date.t) => float = "default"
@module("date-fns/differenceInQuarters")
external differenceInQuarters: (Date.t, Date.t) => int = "default"
@module("date-fns/differenceInQuarters")
external differenceInQuartersf: (Date.t, Date.t) => float = "default"
@module("date-fns/endOfQuarter") external endOfQuarter: Date.t => Date.t = "default"
@module("date-fns/getQuarter") external getQuarter: Date.t => int = "default"
@module("date-fns/getQuarter") external getQuarterf: Date.t => float = "default"
@module("date-fns/isSameQuarter") external isSameQuarter: (Date.t, Date.t) => bool = "default"
@module("date-fns/isThisQuarter") external isThisQuarter: Date.t => bool = "default"
@module("date-fns/lastDayOfQuarter") external lastDayOfQuarter: Date.t => Date.t = "default"
type lastDayOfQuarterOptions = {additionalDigits: option<int>}
@module("date-fns/lastDayOfQuarter")
external lastDayOfQuarterOpt: (Date.t, lastDayOfQuarterOptions) => Date.t = "default"
@module("date-fns/setQuarter") external setQuarter: (Date.t, int) => Date.t = "default"
@module("date-fns/setQuarter") external setQuarterf: (Date.t, float) => Date.t = "default"
@module("date-fns/startOfQuarter") external startOfQuarter: Date.t => Date.t = "default"
@module("date-fns/subQuarters") external subQuarters: (Date.t, int) => Date.t = "default"
@module("date-fns/subQuarters") external subQuartersf: (Date.t, float) => Date.t = "default"

// Year Helpers
@module("date-fns/addYears") external addYears: (Date.t, int) => Date.t = "default"
@module("date-fns/addYears") external addYearsf: (Date.t, float) => Date.t = "default"
@module("date-fns/differenceInCalendarYears")
external differenceInCalendarYears: (Date.t, Date.t) => int = "default"
@module("date-fns/differenceInCalendarYears")
external differenceInCalendarYearsf: (Date.t, Date.t) => float = "default"
@module("date-fns/differenceInYears")
external differenceInYears: (Date.t, Date.t) => int = "default"
@module("date-fns/differenceInYears")
external differenceInYearsf: (Date.t, Date.t) => float = "default"
@module("date-fns/eachWeekendOfYear")
external eachWeekendOfYear: Date.t => array<Date.t> = "default"
@module("date-fns/endOfYear") external endOfYear: Date.t => Date.t = "default"
@module("date-fns/getDaysInYear") external getDaysInYear: Date.t => int = "default"
@module("date-fns/getDaysInYear") external getDaysInYearf: Date.t => float = "default"
@module("date-fns/getYear") external getYear: Date.t => int = "default"
@module("date-fns/getYear") external getYearf: Date.t => float = "default"
@module("date-fns/isLeapYear") external isLeapYear: Date.t => bool = "default"
@module("date-fns/isSameYear") external isSameYear: (Date.t, Date.t) => bool = "default"
@module("date-fns/isThisYear") external isThisYear: Date.t => bool = "default"
@module("date-fns/lastDayOfYear") external lastDayOfYear: Date.t => Date.t = "default"
@module("date-fns/setYear") external setYear: (Date.t, int) => Date.t = "default"
@module("date-fns/setYear") external setYearf: (Date.t, float) => Date.t = "default"
@module("date-fns/startOfYear") external startOfYear: Date.t => Date.t = "default"
@module("date-fns/subYears") external subYears: (Date.t, int) => Date.t = "default"
@module("date-fns/subYears") external subYearsf: (Date.t, float) => Date.t = "default"

// ISO Week-Numbering Year Helpers
@module("date-fns/addISOWeekYears")
external addISOWeekYears: (Date.t, int) => Date.t = "default"
@module("date-fns/addISOWeekYears")
external addISOWeekYearsf: (Date.t, float) => Date.t = "default"
@module("date-fns/differenceInCalendarISOWeekYears")
external differenceInCalendarISOWeekYears: (Date.t, Date.t) => int = "default"
@module("date-fns/differenceInCalendarISOWeekYears")
external differenceInCalendarISOWeekYearsf: (Date.t, Date.t) => float =
  "differenceInCalendarISOWeekYearsf"
@module("date-fns/differenceInISOWeekYears")
external differenceInISOWeekYears: (Date.t, Date.t) => int = "default"
@module("date-fns/differenceInISOWeekYears")
external differenceInISOWeekYearsf: (Date.t, Date.t) => float = "default"
@module("date-fns/endOfISOWeekYear") external endOfISOWeekYear: Date.t => Date.t = "default"
@module("date-fns/getISOWeekYear") external getISOWeekYear: Date.t => int = "default"
@module("date-fns/getISOWeekYear") external getISOWeekYearf: Date.t => float = "default"
@module("date-fns/getISOWeeksInYear") external getISOWeeksInYear: Date.t => int = "default"
@module("date-fns/getISOWeeksInYear") external getISOWeeksInYearf: Date.t => float = "default"
@module("date-fns/isSameISOWeekYear")
external isSameISOWeekYear: (Date.t, Date.t) => bool = "default"
@module("date-fns/lastDayOfISOWeekYear")
external lastDayOfISOWeekYear: Date.t => Date.t = "default"
@module("date-fns/setISOWeekYear")
external setISOWeekYear: (Date.t, int) => Date.t = "default"
@module("date-fns/setISOWeekYear")
external setISOWeekYearf: (Date.t, float) => Date.t = "default"
@module("date-fns/startOfISOWeekYear")
external startOfISOWeekYear: Date.t => Date.t = "default"
@module("date-fns/subISOWeekYears")
external subISOWeekYears: (Date.t, int) => Date.t = "default"
@module("date-fns/subISOWeekYears")
external subISOWeekYearsf: (Date.t, float) => Date.t = "default"

// Decade Helpers
@module("date-fns/endOfDecade") external endOfDecade: Date.t => Date.t = "default"
type endOfDecadeOptions = {additionalDigits: option<int>}
@module("date-fns/endOfDecade")
external endOfDecadeOpt: (Date.t, endOfDecadeOptions) => Date.t = "default"
@module("date-fns/getDecade") external getDecade: Date.t => int = "default"
@module("date-fns/getDecade") external getDecadef: Date.t => float = "default"
@module("date-fns/lastDayOfDecade") external lastDayOfDecade: Date.t => Date.t = "default"
@module("date-fns/startOfDecade") external startOfDecade: Date.t => Date.t = "default"

// Week-Numbering Year Helpers
type weekYearOptions = {
  locale: option<locale>,
  weekStartsOn: option<int>,
  firstWeekContainsDate: option<int>,
}
@module("date-fns/getWeekYear") external getWeekYear: Date.t => int = "default"
@module("date-fns/getWeekYear")
external getWeekYearOpt: (Date.t, weekYearOptions) => int = "default"
@module("date-fns/getWeekYear") external getWeekYearf: Date.t => float = "default"
@module("date-fns/getWeekYear")
external getWeekYearOptf: (Date.t, weekYearOptions) => float = "default"
@module("date-fns/setWeekYear") external setWeekYear: (Date.t, int) => Date.t = "default"
@module("date-fns/setWeekYear")
external setWeekYearOpt: (Date.t, int, weekYearOptions) => Date.t = "default"
@module("date-fns/setWeekYear") external setWeekYearf: (Date.t, float) => Date.t = "default"
@module("date-fns/setWeekYear")
external setWeekYearOptf: (Date.t, float, weekYearOptions) => Date.t = "default"
@module("date-fns/startOfWeekYear") external startOfWeekYear: Date.t => Date.t = "default"
@module("date-fns/startOfWeekYear")
external startOfWeekYearOpt: (Date.t, weekYearOptions) => Date.t = "default"

let isAfterOrEqual = (x, y) => isAfter(x, y) || isEqual(x, y)

let isBeforeOrEqual = (x, y) => isBefore(x, y) || isEqual(x, y)
