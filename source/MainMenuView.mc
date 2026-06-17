// MainMenuView.mc — Home screen with workout type selection
// Custom drawn list on AMOLED, BehaviorDelegate navigation + touch

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
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
        dc.clear();

        var w = dc.getWidth();
        var h = dc.getHeight();

        // ---- Title ----
        dc.setColor(0xD4A84B, Gfx.COLOR_TRANSPARENT);
        dc.drawText(w / 2, 28, Gfx.FONT_SYSTEM_LARGE, "PACER", Gfx.TEXT_JUSTIFY_CENTER);

        // ---- Subtitle ----
        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.drawText(w / 2, 60, Gfx.FONT_SYSTEM_TINY, "Select Workout", Gfx.TEXT_JUSTIFY_CENTER);

        // ---- Divider ----
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
                dc.setColor(0xCCCCCC, 0xCCCCCC);
                dc.fillRectangle(30, y - 2, itemW, itemH - 2);
                dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
            } else {
                dc.setColor(0x888888, Gfx.COLOR_TRANSPARENT);
            }

            dc.drawText(w / 2, y, Gfx.FONT_SYSTEM_MEDIUM, _types[i], Gfx.TEXT_JUSTIFY_CENTER);
        }

        // ---- Navigation hint ----
        dc.setColor(0x555555, Gfx.COLOR_TRANSPARENT);
        dc.drawText(w / 2, h - 22, Gfx.FONT_SYSTEM_TINY, "START select | BACK exit", Gfx.TEXT_JUSTIFY_CENTER);
    }

    function onTap(clickEvent) {
        var coords = clickEvent.getCoordinates();
        var x = coords[0];
        var y = coords[1];
        var w = System.getDeviceSettings().screenWidth;

        var startY = 100;
        var itemH = 40;
        var itemW = w - 60;
        var margin = (w - itemW) / 2;

        if (x < margin || x > w - margin) {
            return false;
        }

        for (var i = 0; i < _types.size(); i++) {
            var itemTop = startY + i * (itemH + 4) - 2;
            var itemBottom = itemTop + itemH - 2;
            if (y >= itemTop && y <= itemBottom) {
                _selectedIndex = i;
                WatchUi.requestUpdate();
                return true;
            }
        }

        return false;
    }
}

// ---- BehaviorDelegate for MainMenu ----

class MainMenuDelegate extends WatchUi.BehaviorDelegate {

    var _view;

    function initialize(view) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onNextPage() {
        System.println("onNextPage");
        _view._selectedIndex = (_view._selectedIndex + 1) % _view._types.size();
        WatchUi.requestUpdate();
        return true;
    }

    function onPreviousPage() {
        System.println("onPreviousPage");
        _view._selectedIndex = (_view._selectedIndex - 1 + _view._types.size()) % _view._types.size();
        WatchUi.requestUpdate();
        return true;
    }

    function onSelect() {
        System.println("onSelect");
        var label = _view._types[_view._selectedIndex];
        var menuView = new WorkoutTypeMenu(label);
        WatchUi.pushView(
            menuView,
            new WorkoutTypeDelegate(menuView),
            WatchUi.SLIDE_IMMEDIATE
        );
        return true;
    }

    function onBack() {
        System.println("onBack");
        System.exit();
        return true;
    }

    function onTap(clickEvent) {
        return _view.onTap(clickEvent);
    }
}
