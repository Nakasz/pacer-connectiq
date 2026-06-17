// MainMenuView.mc — Home screen with workout type selection
// Custom drawn list on AMOLED, UP/DOWN/ENTER/BACK navigation + touch

using Toybox.WatchUi;
using Toybox.Graphics as Gfx;
using Toybox.System;

class MainMenuView extends WatchUi.View {

    var _selectedIndex;
    var _types;

    function initialize() {
        View.initialize();
        _selectedIndex = 0;
        _types = [ "Easy", "Tempo", "Threshold", "Long Run", "VO2max" ];
    }

    function onUpdate(dc) {
        // Clear to AMOLED black
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
        dc.clear();

        var w = dc.getWidth();
        var h = dc.getHeight();

        // ---- Title ----
        dc.setColor(0xD4A84B, Gfx.COLOR_TRANSPARENT); // amber accent
        dc.drawText(w / 2, 28, Gfx.FONT_SYSTEM_LARGE, "PACER", Gfx.TEXT_JUSTIFY_CENTER);

        // ---- Subtitle ----
        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.drawText(w / 2, 60, Gfx.FONT_SYSTEM_TINY, "Select Workout", Gfx.TEXT_JUSTIFY_CENTER);

        // ---- Thin divider ----
        dc.setColor(0x444444, Gfx.COLOR_TRANSPARENT);
        dc.drawLine(40, 82, w - 40, 82);

        // ---- Workout list ----
        var startY = 100;
        var itemH = 40;
        var itemW = w - 60;

        for (var i = 0; i < _types.size(); i++) {
            var y = startY + i * (itemH + 4);
            var isSelected = (i == _selectedIndex);

            if (isSelected) {
                // Highlighted item: white fill, black text
                dc.setColor(0xCCCCCC, 0xCCCCCC);
                dc.fillRectangle(30, y - 2, itemW, itemH - 2);
                dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
            } else {
                // Dim item: no fill, grey text
                dc.setColor(0x888888, Gfx.COLOR_TRANSPARENT);
            }

            dc.drawText(w / 2, y, Gfx.FONT_SYSTEM_MEDIUM, _types[i], Gfx.TEXT_JUSTIFY_CENTER);
        }

        // ---- Navigation hint ----
        dc.setColor(0x555555, Gfx.COLOR_TRANSPARENT);
        dc.drawText(w / 2, h - 22, Gfx.FONT_SYSTEM_TINY, "START select | BACK exit", Gfx.TEXT_JUSTIFY_CENTER);
    }

    // ---- Button input ----

    function onKey(keyEvent) {

        var key = keyEvent.getKey();

        if (key == WatchUi.KEY_DOWN) {
            _selectedIndex = (_selectedIndex + 1) % _types.size();
            WatchUi.requestUpdate();
            return true;
        }

        if (key == WatchUi.KEY_UP) {
            _selectedIndex = (_selectedIndex - 1 + _types.size()) % _types.size();
            WatchUi.requestUpdate();
            return true;
        }

        if (key == WatchUi.KEY_ENTER) {
            _pushPreview();
            return true;
        }

        if (key == WatchUi.KEY_ESC) {
            System.exit();
            return true;
        }

        return false;
    }

    // ---- Touch input ----

    function onTap(clickEvent) {
        var coords = clickEvent.getCoordinates();
        var x = coords[0];
        var y = coords[1];

        // Check if tap is within list area
        var startY = 100;
        var itemH = 40;
        var itemW = 394; // w - 60

        // Left-right margin check
        var margin = (454 - itemW) / 2; // ~30
        if (x < margin || x > 454 - margin) {
            return false;
        }

        for (var i = 0; i < _types.size(); i++) {
            var itemTop = startY + i * (itemH + 4) - 2;
            var itemBottom = itemTop + itemH - 2;
            if (y >= itemTop && y <= itemBottom) {
                _selectedIndex = i;
                _pushPreview();
                return true;
            }
        }

        return false;
    }

    // ---- Private ----

    function _pushPreview() {
        var label = _types[_selectedIndex];
        WatchUi.pushView(
            new WorkoutTypeMenu(label),
            null,
            WatchUi.SLIDE_IMMEDIATE
        );
    }
}
