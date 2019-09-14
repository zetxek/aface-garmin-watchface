using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Application;

using Toybox.Time;
using Toybox.Time.Gregorian;

class AdrianFaceView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
        // Get the current time and format it correctly
        var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        
        if (!System.getDeviceSettings().is24Hour) {
            if (hours > 12) {
                hours = hours - 12;
            }
        }
        
        var minutesString = clockTime.min.format("%02d");
        var hoursString = Lang.format("$1$", [hours]);
   		
   		var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
   		var dateString = Lang.format(
    		"$1$ $2$",
    		[today.day_of_week, today.day]
		);
		
        // Update the view
        var hoursView = View.findDrawableById("TimeHour");
        hoursView.setText(hoursString);
        
        var separatorView = View.findDrawableById("TimeSeparator");
       	separatorView.setText(":");
       	
        var minutesView = View.findDrawableById("TimeMinutes");
        minutesView.setText(minutesString);

		var dateView = View.findDrawableById("Date");
		dateView.setText(dateString);

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }

}
