// StepRunnerView.mc — Static step-by-step workout runner
// View + BehaviorDelegate
// One step per screen, concrete HR/pace, safe area layout

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
        dc.drawText(w / 2, 16, Gfx.FONT_SYSTEM_MEDIUM, _type, Gfx.TEXT_JUSTIFY_CENTER);

        // ---- Step counter ----
        var stepStr = (_currentStep + 1).format("%d") + "/" + _numSteps.format("%d");
        dc.setColor(0x666666, Gfx.COLOR_TRANSPARENT);
        dc.drawText(w / 2, 44, Gfx.FONT_SYSTEM_XTINY, stepStr, Gfx.TEXT_JUSTIFY_CENTER);

        // ---- Divider ----
        dc.setColor(0x3A3A3A, Gfx.COLOR_TRANSPARENT);
        dc.drawLine(45, 62, w - 45, 62);

        if (_currentStep < _numSteps) {
            var idx  = 1 + _currentStep * 3;
            var name = _steps[idx];
            var dur  = _steps[idx + 1];
            var tgt  = _steps[idx + 2];

            // ---- Step name ----
            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
            dc.drawText(w / 2, 82, Gfx.FONT_SYSTEM_MEDIUM, name, Gfx.TEXT_JUSTIFY_CENTER);

            // ---- Duration ----
            dc.setColor(0xD4A84B, Gfx.COLOR_TRANSPARENT);
            dc.drawText(w / 2, 120, Gfx.FONT_SYSTEM_MEDIUM, dur, Gfx.TEXT_JUSTIFY_CENTER);

            // ---- Target label (HR or pace) ----
            dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
            dc.drawText(w / 2, 160, Gfx.FONT_SYSTEM_SMALL, tgt, Gfx.TEXT_JUSTIFY_CENTER);

            // ---- Navigation hint ----
            var isLastStep = (_currentStep == _numSteps - 1);

            dc.setColor(0x444444, Gfx.COLOR_TRANSPARENT);
            if (isLastStep) {
                dc.drawText(w / 2, h - 45, Gfx.FONT_SYSTEM_XTINY, "START finish  BACK", Gfx.TEXT_JUSTIFY_CENTER);
            } else {
                dc.drawText(w / 2, h - 45, Gfx.FONT_SYSTEM_XTINY, "START next  BACK", Gfx.TEXT_JUSTIFY_CENTER);
            }

        } else {
            // ---- All steps complete ----
            dc.setColor(0xD4A84B, Gfx.COLOR_TRANSPARENT);
            dc.drawText(w / 2, h / 2 - 24, Gfx.FONT_SYSTEM_MEDIUM, "Done!", Gfx.TEXT_JUSTIFY_CENTER);

            dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
            dc.drawText(w / 2, h / 2 + 8, Gfx.FONT_SYSTEM_SMALL, "Great work", Gfx.TEXT_JUSTIFY_CENTER);

            dc.setColor(0x444444, Gfx.COLOR_TRANSPARENT);
            dc.drawText(w / 2, h - 45, Gfx.FONT_SYSTEM_XTINY, "START restart  BACK", Gfx.TEXT_JUSTIFY_CENTER);
        }
    }
}

// ---- BehaviorDelegate for StepRunner ----

class StepRunnerDelegate extends WatchUi.BehaviorDelegate {

    var _view;

    function initialize(view) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onSelect() {
        System.println("onSelect (step " + _view._currentStep + ")");
        if (_view._currentStep >= _view._numSteps) {
            _view._currentStep = 0;
        } else {
            _view._currentStep++;
        }
        WatchUi.requestUpdate();
        return true;
    }

    function onPreviousPage() {
        System.println("onPreviousPage");
        if (_view._currentStep > 0) {
            _view._currentStep--;
            WatchUi.requestUpdate();
        }
        return true;
    }

    function onBack() {
        System.println("onBack");
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }
}