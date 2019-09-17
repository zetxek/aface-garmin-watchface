using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Application;
using Graphics as Gfx;

using Toybox.Time;
using Toybox.Time.Gregorian;

class AdrianFaceView extends Ui.WatchFace {

	var hoursView;
	var separatorView;
	var minutesView;
	var dateView;
	var topIndicatorLongText1View;
	var topIndicatorLongText2View;
	
	var bluetoothIcon;

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
    	bluetoothIcon = Ui.loadResource(Rez.Drawables.IconBluetooth);
    	
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
        hoursView = View.findDrawableById("TimeHour");
        hoursView.setText(hoursString);
        
        separatorView = View.findDrawableById("TimeSeparator");
       	separatorView.setText(":");
       	
        minutesView = View.findDrawableById("TimeMinutes");
        minutesView.setText(minutesString);

		dateView = View.findDrawableById("Date");
		dateView.setText(dateString);
		
		topIndicatorLongText1View = View.findDrawableById("TopIndicatorLongText1");
		// next sun event
		topIndicatorLongText1View.setText("️20:13");

		topIndicatorLongText2View = View.findDrawableById("TopIndicatorLongText2");		
		topIndicatorLongText2View.setText("4d (80%)");


        // bluetooth
        View.onUpdate(dc);
        
        /*
        var font = WatchUi.loadResource(Rez.Fonts.CustomFont);
        dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_WHITE);
        
        dc.drawText(100,60, font, Lang.format(
	    	"$1$ $2$",
		    	[
			        "~",
			        "bt"
			        
			    ]
			), Graphics.TEXT_JUSTIFY_LEFT);*/
		
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
