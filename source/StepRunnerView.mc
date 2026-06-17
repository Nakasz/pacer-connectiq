// StepRunnerView.mc — Static step-by-step workout runner
// Shows current step name, duration, zone, and step counter
// ENTER = next step, BACK = return to preview

using Toybox.WatchUi;
using Toybox.Graphics as Gfx;
using Toybox.System;
using Toybox.Lang;

class StepRunnerView extends WatchUi.View {

    var _type;
    var _steps;
    var _numSteps;
    var _currentStep; // 0-based index

    function initialize(type, steps) {
        View.initialize();
        _type = type;
        _steps = steps;
        _numSteps = steps[0];
        _currentStep = 0;
    }

    function onUpdate(dc) {
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
        dc.clear();

        var w = dc.getWidth();
        var h = dc.getHeight();

        // ---- Header: workout type ----
        dc.setColor(0xD4A84B, Gfx.COLOR_TRANSPARENT);
        dc.drawText(w / 2, 12, Gfx.FONT_SYSTEM_TINY, _type.toUpper(), Gfx.TEXT_JUSTIFY_CENTER);

        // ---- Step counter ----
        var stepNum = _currentStep + 1;
        var stepStr = Lang.format("$1$ / $2$", [stepNum.format("%d"), _numSteps.format("%d")]);
        dc.setColor(0x888888, Gfx.COLOR_TRANSPARENT);
        dc.drawText(w / 2, 30, Gfx.FONT_SYSTEM_TINY, stepStr, Gfx.TEXT_JUSTIFY_CENTER);

        // ---- Divider ----
        dc.setColor(0x444444, Gfx.COLOR_TRANSPARENT);
        dc.drawLine(40, 48, w - 40, 48);

        if (_currentStep < _numSteps) {
            var idx = 1 + _currentStep * 3;
            var name = _steps[idx];
            var dur = _steps[idx + 1];
            var zone = _steps[idx + 2];

            // ---- Big step name ----
            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
            dc.drawText(w / 2, 70, Gfx.FONT_SYSTEM_MEDIUM, name, Gfx.TEXT_JUSTIFY_CENTER);

            // ---- Big duration display ----
            dc.setColor(0xD4A84B, Gfx.COLOR_TRANSPARENT);
            dc.drawText(w / 2, 110, Gfx.FONT_SYSTEM_LARGE, dur, Gfx.TEXT_JUSTIFY_CENTER);

            // ---- Zone label ----
            dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
            dc.drawText(w / 2, 150, Gfx.FONT_SYSTEM_SMALL, zone, Gfx.TEXT_JUSTIFY_CENTER);

            // ---- Divider before nav ----
            dc.setColor(0x333333, Gfx.COLOR_TRANSPARENT);
            dc.drawLine(40, 180, w - 40, 180);

            // ---- Navigation hint ----
            var isLastStep = (_currentStep == _numSteps - 1);

            dc.setColor(0x555555, Gfx.COLOR_TRANSPARENT);
            if (isLastStep) {
                dc.drawText(w / 2, h - 22, Gfx.FONT_SYSTEM_TINY, "START to finish  |  BACK to preview", Gfx.TEXT_JUSTIFY_CENTER);
            } else {
                dc.drawText(w / 2, h - 22, Gfx.FONT_SYSTEM_TINY, "START next step  |  BACK to preview", Gfx.TEXT_JUSTIFY_CENTER);
            }

        } else {
            // ---- All steps complete ----
            dc.setColor(0xD4A84B, Gfx.COLOR_TRANSPARENT);
            dc.drawText(w / 2, h / 2 - 20, Gfx.FONT_SYSTEM_LARGE, "Done!", Gfx.TEXT_JUSTIFY_CENTER);

            dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
            dc.drawText(w / 2, h / 2 + 20, Gfx.FONT_SYSTEM_SMALL, "Great work today", Gfx.TEXT_JUSTIFY_CENTER);

            dc.setColor(0x555555, Gfx.COLOR_TRANSPARENT);
            dc.drawText(w / 2, h - 22, Gfx.FONT_SYSTEM_TINY, "START to restart  |  BACK to preview", Gfx.TEXT_JUSTIFY_CENTER);
        }
    }

    // ---- Button input ----

    function onKey(keyEvent) {

        var key = keyEvent.getKey();

        if (key == WatchUi.KEY_ENTER) {
            if (_currentStep >= _numSteps) {
                // Done → restart
                _currentStep = 0;
            } else {
                _currentStep++;
            }
            WatchUi.requestUpdate();
            return true;
        }

        if (key == WatchUi.KEY_UP) {
            // Previous step (wrap)
            if (_currentStep > 0) {
                _currentStep--;
                WatchUi.requestUpdate();
            }
            return true;
        }

        if (key == WatchUi.KEY_ESC) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            return true;
        }

        return false;
    }

    // ---- Touch ----

    function onTap(clickEvent) {
        var coords = clickEvent.getCoordinates();
        var y = coords[1];
        var h = System.getDeviceSettings().screenHeight;

        // Bottom area = next step / finish
        if (y > h * 0.7) {
            if (_currentStep >= _numSteps) {
                _currentStep = 0;
            } else {
                _currentStep++;
            }
            WatchUi.requestUpdate();
            return true;
        }

        // Top area = pop back
        if (y < 60) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            return true;
        }

        return false;
    }
}
