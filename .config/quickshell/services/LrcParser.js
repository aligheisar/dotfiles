// LRC / timed-lyrics parser for Quickshell
// Time unit: microseconds (matches MPRIS position * 1e6)

.pragma library

/**
 * Parse LRC text into sorted array of { timeUs: number, text: string }
 * Supports [mm:ss.xx], [mm:ss:xx], [mm:ss.xxx], multiple timestamps per line,
 * and [offset:±ms] tags.
 */
function parse(lrcText) {
    if (!lrcText || typeof lrcText !== "string")
        return [];

    const lines = lrcText.split(/\r?\n/);
    const result = [];
    let globalOffsetMs = 0;

    // [offset:±123] or [offset:±123ms]
    const offsetRe = /\[offset:\s*([+-]?\d+)\s*(?:ms)?\]/i;
    // one or more [mm:ss.xx] / [mm:ss:xx] / [mm:ss.xxx]
    const timeRe = /\[(\d{1,2}):(\d{1,2})(?:[.:](\d{1,3}))?\]/g;

    for (let i = 0; i < lines.length; i++) {
        let line = lines[i].trim();
        if (!line)
            continue;

        const om = offsetRe.exec(line);
        if (om) {
            globalOffsetMs += parseInt(om[1], 10);
            continue;
        }

        const times = [];
        let m;
        timeRe.lastIndex = 0;
        while ((m = timeRe.exec(line)) !== null) {
            const min = parseInt(m[1], 10);
            const sec = parseInt(m[2], 10);
            let frac = m[3] ? m[3] : "0";
            // normalise fractional part to milliseconds
            if (frac.length === 1) frac += "00";
            else if (frac.length === 2) frac += "0";
            else if (frac.length > 3) frac = frac.slice(0, 3);
            const ms = parseInt(frac, 10);
            const timeMs = (min * 60 + sec) * 1000 + ms + globalOffsetMs;
            times.push(Math.max(0, timeMs) * 1000); // → microseconds
        }

        if (times.length === 0)
            continue;

        // strip all timestamp tags, keep remaining text
        const text = line.replace(/\[\d{1,2}:\d{1,2}(?:[.:]\d{1,3})?\]/g, "").trim();
        if (!text)
            continue;

        for (let t = 0; t < times.length; t++) {
            result.push({ timeUs: times[t], text: text });
        }
    }

    result.sort((a, b) => a.timeUs - b.timeUs);
    return result;
}

/**
 * Binary-search style: find the last line whose timeUs <= positionUs.
 * Returns { index, current, next, progress } where progress ∈ [0,1]
 * between current and next (or 0 if no next).
 */
function getInfo(lyrics, positionUs) {
    if (!lyrics || lyrics.length === 0)
        return { index: -1, current: null, next: null, progress: 0 };

    let lo = 0, hi = lyrics.length - 1, best = -1;
    while (lo <= hi) {
        const mid = (lo + hi) >> 1;
        if (lyrics[mid].timeUs <= positionUs) {
            best = mid;
            lo = mid + 1;
        } else {
            hi = mid - 1;
        }
    }

    if (best < 0)
        return { index: -1, current: null, next: lyrics[0] || null, progress: 0 };

    const current = lyrics[best];
    const next = best + 1 < lyrics.length ? lyrics[best + 1] : null;
    let progress = 0;
    if (next && next.timeUs > current.timeUs) {
        progress = (positionUs - current.timeUs) / (next.timeUs - current.timeUs);
        progress = Math.max(0, Math.min(1, progress));
    }
    return { index: best, current: current, next: next, progress: progress };
}

/**
 * Split bilingual lines of the form "main / translation" or "main｜translation".
 */
function splitTranslation(text) {
    if (!text) return { main: "", translation: "" };
    const seps = [" / ", "｜", " | ", "／"];
    for (let i = 0; i < seps.length; i++) {
        const idx = text.indexOf(seps[i]);
        if (idx > 0) {
            return {
                main: text.slice(0, idx).trim(),
                translation: text.slice(idx + seps[i].length).trim()
            };
        }
    }
    return { main: text, translation: "" };
}

