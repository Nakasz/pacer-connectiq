// WorkoutTypeMenu.mc — Confirmation after type selection
// View + BehaviorDelegate — buttons handled by WorkoutTypeDelegate

using Toybox.WatchUi;
using Toybox.Graphics as Gfx;
using Toybox.System;

class WorkoutTypeMenu extends WatchUi.View {

    var _type;
    var _description;
    var _selectedOption; // 0 = Yes(View), 1 = No(Back)

    function initialize(type) {
        View.initialize();
        _type = type;
        _selectedOption = 0;

        if (type.equals("Easy")) {
            _description = "Low intensity aerobic";
        } else if (type.equals("Tempo")) {
            _description = "Sustained moderate effort";
        } else if (type.equals("Threshold")) {
            _description = "Lactate threshold work";
        } else if (type.equals("Long Run")) {
            _description = "Distance building run";
        } else if (type.equals("VO2max")) {
            _description = "High intensity intervals";
        } else {
            _description = "";
        }
    }

    function onUpdate(dc) {
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
        dc.clear();

        var w = dc.getWidth();
        var h = dc.getHeight();

        // ---- Workout type ----
        dc.setColor(0xD4A84B, Gfx.COLOR_TRANSPARENT);
        dc.drawText(w / 2, 50, Gfx.FONT_SYSTEM_LARGE, _type, Gfx.TEXT_JUSTIFY_CENTER);

        // ---- Description ----
        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.drawText(w / 2, 90, Gfx.FONT_SYSTEM_SMALL, _description, Gfx.TEXT_JUSTIFY_CENTER);

        // ---- Divider ----
        dc.setColor(0x444444, Gfx.COLOR_TRANSPARENT);
        dc.drawLine(40, 120, w - 40, 120);

        // ---- Prompt ----
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(w / 2, 135, Gfx.FONT_SYSTEM_SMALL, "View workout?", Gfx.TEXT_JUSTIFY_CENTER);

        // ---- Yes/No buttons ----
        var btnW = 140;
        var btnH = 40;
        var gap = 20;
        var totalW = btnW * 2 + gap;
        var startX = (w - totalW) / 2;
        var btnY = 180;

        var yesSelected = (_selectedOption == 0);
        dc.setColor(yesSelected ? 0xD4A84B : 0x444444, yesSelected ? 0x332200 : Gfx.COLOR_BLACK);
        dc.fillRectangle(startX, btnY, btnW, btnH);
        dc.setColor(yesSelected ? Gfx.COLOR_WHITE : 0x888888, Gfx.COLOR_TRANSPARENT);
        dc.drawText(startX + btnW / 2, btnY + 8, Gfx.FONT_SYSTEM_SMALL, "View", Gfx.TEXT_JUSTIFY_CENTER);

        var noSelected = (_selectedOption == 1);
        var noX = startX + btnW + gap;
        dc.setColor(noSelected ? 0xCCCCCC : 0x444444, noSelected ? 0x222222 : Gfx.COLOR_BLACK);
        dc.fillRectangle(noX, btnY, btnW, btnH);
        dc.setColor(noSelected ? Gfx.COLOR_WHITE : 0x888888, Gfx.COLOR_TRANSPARENT);
        dc.drawText(noX + btnW / 2, btnY + 8, Gfx.FONT_SYSTEM_SMALL, "Back", Gfx.TEXT_JUSTIFY_CENTER);

        // ---- Hint ----
        dc.setColor(0x444444, Gfx.COLOR_TRANSPARENT);
        dc.drawText(w / 2, h - 62, Gfx.FONT_SYSTEM_XTINY, "UP/DOWN  START", Gfx.TEXT_JUSTIFY_CENTER);
    }

    function onTap(clickEvent) {
        var coords = clickEvent.getCoordinates();
        var x = coords[0];
        var y = coords[1];
        var w = System.getDeviceSettings().screenWidth;
        var btnW = 140;
        var btnH = 40;
        var gap = 20;
        var totalW = btnW * 2 + gap;
        var startX = (w - totalW) / 2;
        var btnY = 180;

        if (y < btnY || y > btnY + btnH) {
            return false;
        }

        if (x >= startX && x <= startX + btnW) {
            _selectedOption = 0;
            WatchUi.requestUpdate();
            return true;
        }

        var noX = startX + btnW + gap;
        if (x >= noX && x <= noX + btnW) {
            _selectedOption = 1;
            WatchUi.requestUpdate();
            return true;
        }

        return false;
    }
}

// ---- BehaviorDelegate for WorkoutTypeMenu ----

class WorkoutTypeDelegate extends WatchUi.BehaviorDelegate {

    var _view;

    function initialize(view) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onNextPage() {
        System.println("onNextPage");
        _view._selectedOption = 1;
        WatchUi.requestUpdate();
        return true;
    }

    function onPreviousPage() {
        System.println("onPreviousPage");
        _view._selectedOption = 0;
        WatchUi.requestUpdate();
        return true;
    }

    function onSelect() {
        System.println("onSelect");
        if (_view._selectedOption == 0) {
            var previewView = new WorkoutPreviewView(_view._type);
            WatchUi.pushView(
                previewView,
                new WorkoutPreviewDelegate(previewView),
                WatchUi.SLIDE_IMMEDIATE
            );
        } else {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
        return true;
    }

    function onBack() {
        System.println("onBack");
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }

    function onTap(clickEvent) {
        return _view.onTap(clickEvent);
    }
}