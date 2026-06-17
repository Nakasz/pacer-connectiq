// WorkoutPreviewView.mc — Static workout preview with step breakdown
// View + BehaviorDelegate
// All target labels use concrete HR/pace, no zone notation

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

        // Target labels: HR range (bpm) or pace range (/km)
        if (type.equals("Easy")) {
            _steps = [ 1, "Easy Run", "40 min", "HR 120-150" ];
        } else if (type.equals("Tempo")) {
            _steps = [
                3,
                "Warmup",   "12 min", "HR 130-150",
                "Tempo",    "25 min", "4:50-5:05/km",
                "Cooldown", "10 min", "HR 130-150"
            ];
        } else if (type.equals("Threshold")) {
            _steps = [
                5,
                "Warmup",   "12 min", "HR 130-150",
                "Thresh",   "8 min",  "4:35-4:50/km",
                "Recov",    "2 min",  "HR 130-150",
                "Thresh",   "8 min",  "4:35-4:50/km",
                "Cooldown", "10 min", "HR 130-150"
            ];
        } else if (type.equals("Long Run")) {
            _steps = [ 1, "Long Run", "75 min", "5:20-5:50/km" ];
        } else if (type.equals("VO2max")) {
            _steps = [
                4,
                "Warmup",   "15 min", "HR 120-140",
                "6x VO2max","90 sec", "4:20-4:35/km",
                "6x Recov", "60 sec", "HR 120-140",
                "Cooldown", "10 min", "HR 120-140"
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
        dc.drawText(w / 2, 18, Gfx.FONT_SYSTEM_MEDIUM, _type, Gfx.TEXT_JUSTIFY_CENTER);

        // ---- Divider ----
        dc.setColor(0x444444, Gfx.COLOR_TRANSPARENT);
        dc.drawLine(30, 48, w - 30, 48);

        // ---- Step breakdown ----
        var numSteps = _steps[0];
        var y = 56;
        var lineH = 24;

        if (numSteps == 0) {
            dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
            dc.drawText(w / 2, y, Gfx.FONT_SYSTEM_SMALL, "No workout data", Gfx.TEXT_JUSTIFY_CENTER);
        }

        for (var i = 0; i < numSteps; i++) {
            var idx = 1 + i * 3;
            var name = _steps[idx];
            var dur  = _steps[idx + 1];
            var tgt  = _steps[idx + 2];

            var stepNum = (i + 1).format("%02d");
            dc.setColor(0x666666, Gfx.COLOR_TRANSPARENT);
            dc.drawText(30, y, Gfx.FONT_SYSTEM_TINY, stepNum, Gfx.TEXT_JUSTIFY_LEFT);

            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
            dc.drawText(60, y, Gfx.FONT_SYSTEM_SMALL, name, Gfx.TEXT_JUSTIFY_LEFT);

            dc.setColor(0xAAAAAA, Gfx.COLOR_TRANSPARENT);
            dc.drawText(60, y + 13, Gfx.FONT_SYSTEM_TINY, dur, Gfx.TEXT_JUSTIFY_LEFT);

            // Target right-aligned
            dc.setColor(0xD4A84B, Gfx.COLOR_TRANSPARENT);
            dc.drawText(w - 30, y, Gfx.FONT_SYSTEM_TINY, tgt, Gfx.TEXT_JUSTIFY_RIGHT);

            y += lineH + 2;

            if (i < numSteps - 1) {
                dc.setColor(0x2A2A2A, Gfx.COLOR_TRANSPARENT);
                dc.drawLine(30, y - 1, w - 30, y - 1);
            }
        }

        // ---- Hint ----
        dc.setColor(0x444444, Gfx.COLOR_TRANSPARENT);
        dc.drawText(w / 2, h - 62, Gfx.FONT_SYSTEM_XTINY, "START run  BACK menu", Gfx.TEXT_JUSTIFY_CENTER);
    }

    function onTap(clickEvent) {
        var coords = clickEvent.getCoordinates();
        var y = coords[1];
        var x = coords[0];
        var h = System.getDeviceSettings().screenHeight;

        if (y > h * 0.6) {
            return true;
        }

        if (x < 100 && y < 50) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            return true;
        }

        return false;
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

    function onTap(clickEvent) {
        var coords = clickEvent.getCoordinates();
        var y = coords[1];
        var x = coords[0];
        var h = System.getDeviceSettings().screenHeight;

        if (y > h * 0.6) {
            System.println("onSelect (tap)");
            var stepView = new StepRunnerView(_view._type, _view._steps);
            WatchUi.pushView(
                stepView,
                new StepRunnerDelegate(stepView),
                WatchUi.SLIDE_IMMEDIATE
            );
            return true;
        }

        if (x < 100 && y < 50) {
            System.println("onBack (tap)");
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            return true;
        }

        return false;
    }
}