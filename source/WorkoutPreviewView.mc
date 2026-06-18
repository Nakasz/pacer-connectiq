// WorkoutPreviewView.mc — Static workout preview with step breakdown
// View + BehaviorDelegate
// Shortened step names, concrete HR/pace targets, safe area layout

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

        // All targets: HR range (bpm) or pace range (/km) — no zone notation
        if (type.equals("Easy")) {
            _steps = [ 1, "Easy", "40 min", "HR 120-150" ];
        } else if (type.equals("Tempo")) {
            _steps = [
                3,
                "Warm",  "12 min", "HR 120-145",
                "Tempo", "25 min", "4:50-5:05/km",
                "Cool",  "10 min", "HR 120-145"
            ];
        } else if (type.equals("Threshold")) {
            _steps = [
                5,
                "Warm",  "12 min", "HR 120-145",
                "Thresh","8 min",  "4:35-4:50/km",
                "Rec",   "2 min",  "HR 120-145",
                "Thresh","8 min",  "4:35-4:50/km",
                "Cool",  "10 min", "HR 120-145"
            ];
        } else if (type.equals("Long Run")) {
            _steps = [ 1, "Long", "75 min", "HR 125-155" ];
        } else if (type.equals("VO2max")) {
            _steps = [
                4,
                "Warm", "15 min", "HR 120-145",
                "VO2",  "90 sec", "4:05-4:20/km",
                "Rec",  "60 sec", "HR 120-145",
                "Cool", "10 min", "HR 120-145"
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
        var safeRight = w - 40;    // safe right edge
        var safeLeft  = 35;        // safe left edge
        var safeTop   = 20;
        var safeBot   = h - 52;    // leave room for hint
        var rowH      = 26;        // compact row height

        // ---- Title ----
        dc.setColor(0xD4A84B, Gfx.COLOR_TRANSPARENT);
        dc.drawText(w / 2, safeTop, Gfx.FONT_SYSTEM_MEDIUM, _type, Gfx.TEXT_JUSTIFY_CENTER);

        // ---- Divider ----
        dc.setColor(0x3A3A3A, Gfx.COLOR_TRANSPARENT);
        dc.drawLine(safeLeft, 52, safeRight, 52);

        // ---- Step rows ----
        var numSteps = _steps[0];
        var rowY = 62;

        if (numSteps == 0) {
            dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
            dc.drawText(w / 2, rowY, Gfx.FONT_SYSTEM_SMALL, "No workout", Gfx.TEXT_JUSTIFY_CENTER);
            return;
        }

        for (var i = 0; i < numSteps; i++) {
            if (rowY > safeBot) { break; }  // stop if out of safe area

            var idx  = 1 + i * 3;
            var name = _steps[idx];
            var dur  = _steps[idx + 1];
            var tgt  = _steps[idx + 2];
            var stepNum = (i + 1).format("%02d");

            // Step number — dim
            dc.setColor(0x555555, Gfx.COLOR_TRANSPARENT);
            dc.drawText(safeLeft, rowY, Gfx.FONT_SYSTEM_TINY, stepNum, Gfx.TEXT_JUSTIFY_LEFT);

            // Step name
            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
            dc.drawText(safeLeft + 28, rowY, Gfx.FONT_SYSTEM_SMALL, name, Gfx.TEXT_JUSTIFY_LEFT);

            // Duration — below name
            dc.setColor(0x777777, Gfx.COLOR_TRANSPARENT);
            dc.drawText(safeLeft + 28, rowY + 14, Gfx.FONT_SYSTEM_TINY, dur, Gfx.TEXT_JUSTIFY_LEFT);

            // Target — right side, amber
            dc.setColor(0xD4A84B, Gfx.COLOR_TRANSPARENT);
            dc.drawText(safeRight, rowY, Gfx.FONT_SYSTEM_TINY, tgt, Gfx.TEXT_JUSTIFY_RIGHT);

            // Separator line
            if (i < numSteps - 1) {
                dc.setColor(0x2A2A2A, Gfx.COLOR_TRANSPARENT);
                dc.drawLine(safeLeft, rowY + rowH - 2, safeRight, rowY + rowH - 2);
            }

            rowY += rowH;
        }

        // ---- Hint ----
        dc.setColor(0x444444, Gfx.COLOR_TRANSPARENT);
        dc.drawText(w / 2, h - 45, Gfx.FONT_SYSTEM_XTINY, "START run  BACK menu", Gfx.TEXT_JUSTIFY_CENTER);
    }
}

// ---- BehaviorDelegate for WorkoutPreview ----

class WorkoutPreviewDelegate extends WatchUi.BehaviorDelegate {

    var _view;

    function initialize(view) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onSelect() {
        System.println("onSelect");
        var stepView = new StepRunnerView(_view._type, _view._steps);
        WatchUi.pushView(
            stepView,
            new StepRunnerDelegate(stepView),
            WatchUi.SLIDE_IMMEDIATE
        );
        return true;
    }

    function onBack() {
        System.println("onBack");
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }
}