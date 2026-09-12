// Gregorian -> Jalali (Persian) date conversion + formatting.
// No dependencies.
//
// Usage in QML/Quickshell:
//   Keep the ".pragma library" line below — it lets you `import "jalali.js" as Jalali`
//   from any QML file and call Jalali.format(new Date(), "d MMMM").
//
// Supported format tokens:
//   d     -> day, no leading zero        (e.g. 7)
//   dd    -> day, zero-padded            (e.g. 07)
//   M     -> month number, no leading 0  (e.g. 7)
//   MM    -> month number, zero-padded   (e.g. 07)
//   MMMM  -> full Persian month name     (e.g. مهر)
//   yyyy  -> 4-digit year                (e.g. 1404)
//   yy    -> 2-digit year                (e.g. 04)
// Any other characters in the format string (spaces, "/", "-", etc.)
// are passed through unchanged.

.pragma library

const MONTH_NAMES_FA = [
    "فروردین", "اردیبهشت", "خرداد", "تیر", "مرداد", "شهریور",
    "مهر", "آبان", "آذر", "دی", "بهمن", "اسفند"
];

const G_DAYS_IN_MONTH = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334];

// Returns [jy, jm, jd]
function gregorianToJalali(gy, gm, gd) {
    let jy = (gy <= 1600) ? 0 : 979;
    gy -= (gy <= 1600) ? 621 : 1600;
    const gy2 = (gm > 2) ? (gy + 1) : gy;

    let days = (365 * gy)
        + Math.floor((gy2 + 3) / 4)
        - Math.floor((gy2 + 99) / 100)
        + Math.floor((gy2 + 399) / 400)
        - 80 + gd + G_DAYS_IN_MONTH[gm - 1];

    jy += 33 * Math.floor(days / 12053);
    days %= 12053;

    jy += 4 * Math.floor(days / 1461);
    days %= 1461;

    if (days > 365) {
        jy += Math.floor((days - 1) / 365);
        days = (days - 1) % 365;
    }

    let jm, jd;
    if (days < 186) {
        jm = 1 + Math.floor(days / 31);
        jd = 1 + (days % 31);
    } else {
        jm = 7 + Math.floor((days - 186) / 30);
        jd = 1 + ((days - 186) % 30);
    }

    return [jy, jm, jd];
}

function pad2(n) {
    return n < 10 ? "0" + n : "" + n;
}

// format(date, formatString) -> string
// `date` defaults to now if omitted.
function format(date, fmt) {
    date = date || new Date();
    fmt = fmt || "yyyy/MM/dd";

    const [jy, jm, jd] = gregorianToJalali(
        date.getFullYear(),
        date.getMonth() + 1,
        date.getDate()
    );

    const tokens = {
        "MMMM": MONTH_NAMES_FA[jm - 1],
        "MM": pad2(jm),
        "M": String(jm),
        "yyyy": String(jy),
        "yy": String(jy).slice(-2),
        "dd": pad2(jd),
        "d": String(jd)
    };

    // Longest tokens first so "MMMM"/"MM" and "yyyy"/"yy" and "dd" don't
    // get partially matched by their shorter counterparts.
    return fmt.replace(/MMMM|MM|M|yyyy|yy|dd|d/g, match => tokens[match]);
}
