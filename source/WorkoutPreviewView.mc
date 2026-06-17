// WorkoutPreviewView.mc — Static workout preview with step breakdown
// Shows workout name, duration, and step list

using Toybox.WatchUi;
using Toybox.Graphics as Gfx;
using Toybox.System;
using Toybox.Lang;

class WorkoutPreviewView extends WatchUi.View {

    var _type;
    var _steps;

    function initialize(type) {
        View.initialize();
        _type = type;

        // Static sample workout data per type
        if (type.equals("Easy")) {
            _steps = [ 3, "Easy Run", "40 min", "4:30–5:00/km" ];
        } else if (type.equals("Tempo")) {
            _steps = [
                3,
                "Warmup",        "12 min", "Zone 1–2",
                "Tempo",         "25 min", "Zone 3–4",
                "Cooldown",      "10 min", "Zone 1–2"
            ];
        } else if (type.equals("Threshold")) {
            _steps = [
                5,
                "Warmup",        "12 min", "Zone 1–2",
                "Threshold",     "8 min",  "Zone 4",
                "Recovery",      "2 min",  "Zone 1–2",
                "Threshold",     "8 min",  "Zone 4",
                "Cooldown",      "10 min", "Zone 1–2"
            ];
        } else if (type.equals("Long Run")) {
            _steps = [ 1, "Long Run", "75 min", "Zone 2–3" ];
        } else if (type.equals("VO2max")) {
            _steps = [
                4,
                "Warmup",        "15 min",  "Zone 1",
                "6x VO2max",     "90 sec",  "Zone 4–5",
                "6x Recovery",   "60 sec",  "Zone 1–2",
                "Cooldown",      "10 min",  "Zone 1"
            ];
        } else {
            _steps = [ 0 ];
        }
    }

    function onUpdate(dc) {
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
        dc.clear();

        var w = dc.getWidth();
        var h = dc.getHeight();

        // ---- Title ----
        dc.setColor(0xD4A84B, Gfx.COLOR_TRANSPARENT);
        dc.drawText(w / 2, 20, Gfx.FONT_SYSTEM_LARGE, _type, Gfx.TEXT_JUSTIFY_CENTER);

        // ---- Divider ----
        dc.setColor(0x444444, Gfx.COLOR_TRANSPARENT);
        dc.drawLine(30, 52, w - 30, 52);

        // ---- Step breakdown ----
        var numSteps = _steps[0];
        var y = 68;
        var lineH = 26;

        if (numSteps == 0) {
            dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
            dc.drawText(w / 2, y, Gfx.FONT_SYSTEM_SMALL, "No workout data", Gfx.TEXT_JUSTIFY_CENTER);
        }

        for (var i = 0; i < numSteps; i++) {
            var idx = 1 + i * 3;
            var name = _steps[idx];
            var dur = _steps[idx + 1];
            var zone = _steps[idx + 2];

            // Step number + name
            var stepNum = Lang.format("$1$", [(i + 1).format("%02d")]);
            dc.setColor(0x888888, Gfx.COLOR_TRANSPARENT);
            dc.drawText(30, y, Gfx.FONT_SYSTEM_TINY, stepNum, Gfx.TEXT_JUSTIFY_LEFT);

            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
            dc.drawText(65, y, Gfx.FONT_SYSTEM_SMALL, name, Gfx.TEXT_JUSTIFY_LEFT);

            // Duration + zone on same line
            dc.setColor(0xAAAAAA, Gfx.COLOR_TRANSPARENT);
            var detail = dur + "  " + zone;
            dc.drawText(65, y + 14, Gfx.FONT_SYSTEM_TINY, detail, Gfx.TEXT_JUSTIFY_LEFT);

            y += lineH + 2;

            // Line between steps
            if (i < numSteps - 1) {
                dc.setColor(0x333333, Gfx.COLOR_TRANSPARENT);
                dc.drawLine(30, y - 1, w - 30, y - 1);
            }
        }

        // ---- START hint ----
        dc.setColor(0x555555, Gfx.COLOR_TRANSPARENT);
        dc.drawText(w / 2, h - 22, Gfx.FONT_SYSTEM_TINY, "START to run  |  BACK to menu", Gfx.TEXT_JUSTIFY_CENTER);
    }

    // ---- Button input ----

    function onKey(keyEvent) {
        if (keyEvent.getType() != WatchUi.KEY_EVENT_PRESS) {
            return false;
        }

        if (keyEvent.getKey() == WatchUi.KEY_ENTER) {
            WatchUi.pushView(
                new StepRunnerView(_type, _steps),
                null,
                WatchUi.SLIDE_IMMEDIATE
            );
            return true;
        }

        if (keyEvent.getKey() == WatchUi.KEY_ESC) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            return true;
        }

        return false;
    }

    // ---- Touch input (tap START area) ----
    function onTap(clickEvent) {
        var coords = clickEvent.getCoordinates();
        var y = coords[1];
        var h = System.getDeviceSettings().screenHeight;

        // Tapping bottom third starts
        if (y > h * 0.6) {
            WatchUi.pushView(
                new StepRunnerView(_type, _steps),
                null,
                WatchUi.SLIDE_IMMEDIATE
            );
            return true;
        }

        // Tapping top-left area pops back
        var x = coords[0];
        if (x < 100 && y < 50) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            return true;
        }

        return false;
    }
}
