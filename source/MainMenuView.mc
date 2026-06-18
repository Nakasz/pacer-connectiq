// MainMenuView.mc — Home screen with workout type selection
// Custom drawn list on AMOLED, UP/DOWN/ENTER/BACK navigation

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

        var titleY    = 48;
        var subtitleY = 82;
        var listStartY = 125;
        var rowHeight  = 34;
        var hintY      = h - 62;

        // ---- Title ----
        dc.setColor(0xD4A84B, Gfx.COLOR_TRANSPARENT);
        dc.drawText(w / 2, titleY, Gfx.FONT_SYSTEM_MEDIUM, "PACER", Gfx.TEXT_JUSTIFY_CENTER);

        // ---- Subtitle ----
        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.drawText(w / 2, subtitleY, Gfx.FONT_SYSTEM_XTINY, "Select Workout", Gfx.TEXT_JUSTIFY_CENTER);

        // ---- Workout list ----
        var selectorH = 28;
        var selectorW = 180;

        for (var i = 0; i < _types.size(); i++) {
            var y = listStartY + (i * rowHeight);
            var isSelected = (i == _selectedIndex);

            if (isSelected) {
                dc.setColor(0x2A2A2A, Gfx.COLOR_TRANSPARENT);
                dc.fillRectangle((w - selectorW) / 2, y - 2, selectorW, selectorH);
                dc.setColor(0xD4A84B, Gfx.COLOR_TRANSPARENT);
                dc.drawText(w / 2, y + 2, Gfx.FONT_SYSTEM_SMALL, _types[i], Gfx.TEXT_JUSTIFY_CENTER);
            } else {
                dc.setColor(0x666666, Gfx.COLOR_TRANSPARENT);
                dc.drawText(w / 2, y + 2, Gfx.FONT_SYSTEM_SMALL, _types[i], Gfx.TEXT_JUSTIFY_CENTER);
            }
        }

        // ---- Navigation hint ----
        dc.setColor(0x444444, Gfx.COLOR_TRANSPARENT);
        dc.drawText(w / 2, hintY, Gfx.FONT_SYSTEM_XTINY, "UP/DOWN  START", Gfx.TEXT_JUSTIFY_CENTER);
    }

    function onTap(clickEvent) {
        // Tap not used for menu navigation — use buttons
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
        var previewView = new WorkoutPreviewView(label);
        WatchUi.pushView(
            previewView,
            new WorkoutPreviewDelegate(previewView),
            WatchUi.SLIDE_IMMEDIATE
        );
        return true;
    }

    function onBack() {
        System.println("onBack");
        System.exit();
        return true;
    }
}