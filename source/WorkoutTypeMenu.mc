// WorkoutTypeMenu.mc — Confirmation after type selection
// Shows workout type name + short description, user confirms to view full workout

using Toybox.WatchUi;
using Toybox.Graphics as Gfx;

class WorkoutTypeMenu extends WatchUi.View {

    var _type;
    var _description;
    var _selectedOption; // 0 = Yes, 1 = No

    function initialize(type) {
        View.initialize();
        _type = type;
        _selectedOption = 0;

        // Static descriptions per type
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

        // Yes button
        var yesSelected = (_selectedOption == 0);
        dc.setColor(yesSelected ? 0xD4A84B : 0x444444, yesSelected ? 0x332200 : Gfx.COLOR_BLACK);
        dc.fillRectangle(startX, btnY, btnW, btnH);
        dc.setColor(yesSelected ? Gfx.COLOR_WHITE : 0x888888, Gfx.COLOR_TRANSPARENT);
        dc.drawText(startX + btnW / 2, btnY + 8, Gfx.FONT_SYSTEM_SMALL, "View", Gfx.TEXT_JUSTIFY_CENTER);

        // No button
        var noSelected = (_selectedOption == 1);
        var noX = startX + btnW + gap;
        dc.setColor(noSelected ? 0xCCCCCC : 0x444444, noSelected ? 0x222222 : Gfx.COLOR_BLACK);
        dc.fillRectangle(noX, btnY, btnW, btnH);
        dc.setColor(noSelected ? Gfx.COLOR_WHITE : 0x888888, Gfx.COLOR_TRANSPARENT);
        dc.drawText(noX + btnW / 2, btnY + 8, Gfx.FONT_SYSTEM_SMALL, "Back", Gfx.TEXT_JUSTIFY_CENTER);

        // ---- Hint ----
        dc.setColor(0x555555, Gfx.COLOR_TRANSPARENT);
        dc.drawText(w / 2, h - 22, Gfx.FONT_SYSTEM_TINY, "UP/DOWN  |  START confirm", Gfx.TEXT_JUSTIFY_CENTER);
    }

    // ---- Button input ----

    function onKey(keyEvent) {

        var key = keyEvent.getKey();

        if (key == WatchUi.KEY_DOWN || key == WatchUi.KEY_UP) {
            _selectedOption = _selectedOption == 0 ? 1 : 0;
            WatchUi.requestUpdate();
            return true;
        }

        if (key == WatchUi.KEY_ENTER) {
            if (_selectedOption == 0) {
                // View workout → push preview
                WatchUi.pushView(
                    new WorkoutPreviewView(_type),
                    null,
                    WatchUi.SLIDE_IMMEDIATE
                );
            } else {
                // Back → pop
                WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            }
            return true;
        }

        if (key == WatchUi.KEY_ESC) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            return true;
        }

        return false;
    }

    // ---- Touch input ----

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

        // Check Y range
        if (y < btnY || y > btnY + btnH) {
            return false;
        }

        // Yes button
        if (x >= startX && x <= startX + btnW) {
            _selectedOption = 0;
            WatchUi.pushView(new WorkoutPreviewView(_type), null, WatchUi.SLIDE_IMMEDIATE);
            return true;
        }

        // No button
        var noX = startX + btnW + gap;
        if (x >= noX && x <= noX + btnW) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            return true;
        }

        return false;
    }
}
