// PacerApp.mc — Entry point for Pacer Garmin watch app
// Skeleton PoC: static workout display + navigation

using Toybox.Application;
using Toybox.WatchUi;

class PacerApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) { }

    function onStop(state) { }

    function getInitialView() {
        var view = new MainMenuView();
        return [ view, new MainMenuDelegate(view) ];
    }
}
