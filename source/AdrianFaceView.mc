using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.System as Sys;
using Toybox.Lang;
using Toybox.Application;
using Graphics as Gfx;

using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.SensorHistory as SensorHistory;

using Toybox.Time;
using Toybox.Time.Gregorian;

class AdrianFaceView extends Ui.WatchFace {

	const INTEGER_FORMAT = "%d";

	var hoursView;
	var separatorView;
	var minutesView;
	var dateView;
	
	var bottomIndicatorLongText1View;
	var bottomIndicatorLongText2View;
	
	var sunTimes;
	
	
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
    	
    }

    // Update the view
    function onUpdate(dc) {
    
    	var activityInfo = ActivityMonitor.getInfo();
    	var settings = System.getDeviceSettings();
    	var stats = System.getSystemStats();
    
    
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
   		// so thursday is not "thurs", but "thu"
   		var shortDayName = today.day_of_week.substring(0, 3);
   		var dateString = Lang.format(
    		"$1$ $2$",
    		[shortDayName, today.day]
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
		
		bluetoothIcon = View.findDrawableById("BluetoothIcon");
		var phone = settings.phoneConnected;
		if (phone){
			bluetoothIcon.setColor(Graphics.COLOR_GREEN);		
		}else{
			bluetoothIcon.setColor(Graphics.COLOR_RED);
		}
		
		var dndIcon = View.findDrawableById("DNDIcon");
		var doNotDisturb = settings.doNotDisturb;
		if (doNotDisturb){
			dndIcon.setColor(Graphics.COLOR_GREEN);		
		}else{
			dndIcon.setColor(Graphics.COLOR_RED);		
		}

		var notificationIcon = View.findDrawableById("NotificationsIcon");
		var notificationCount = settings.notificationCount;
		if (notificationCount > 0){
			notificationIcon.setColor(Graphics.COLOR_GREEN);	
		}

        View.onUpdate(dc);
        		
    }
    
    function getSunValue(){
    
    	var sunCalc = new SunCalc();
    	var value;
    	if (gLocationLat != null) {
			var nextSunEvent = 0;
			var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT);

			// Convert to same format as sunTimes, for easier comparison. Add a minute, so that e.g. if sun rises at
			// 07:38:17, then 07:38 is already consided daytime (seconds not shown to user).
			now = now.hour + ((now.min + 1) / 60.0);
			//Sys.println(now);

			// Get today's sunrise/sunset times in current time zone.
			sunTimes = sunCalc.getSunTimes(gLocationLat, gLocationLng, null, /* tomorrow */ false);
			//Sys.println(sunTimes);

			// If sunrise/sunset happens today.
			var sunriseSunsetToday = ((sunTimes[0] != null) && (sunTimes[1] != null));
			if (sunriseSunsetToday) {

				// Before sunrise today: today's sunrise is next.
				if (now < sunTimes[0]) {
					nextSunEvent = sunTimes[0];
					// result["isSunriseNext"] = true;

				// After sunrise today, before sunset today: today's sunset is next.
				} else if (now < sunTimes[1]) {
					nextSunEvent = sunTimes[1];

				// After sunset today: tomorrow's sunrise (if any) is next.
				} else {
					sunTimes = sunCalc.getSunTimes(gLocationLat, gLocationLng, null, /* tomorrow */ true);
					nextSunEvent = sunTimes[0];
					// result["isSunriseNext"] = true;
				}
			}

			// Sun never rises/sets today.
			if (!sunriseSunsetToday) {
				value = "---";

				// Sun never rises: sunrise is next, but more than a day from now.
				if (sunTimes[0] == null) {
					// result["isSunriseNext"] = true;
				}

			// We have a sunrise/sunset time.
			} else {
				var hour = Math.floor(nextSunEvent).toLong() % 24;
				var min = Math.floor((nextSunEvent - Math.floor(nextSunEvent)) * 60); // Math.floor(fractional_part * 60)
				value = getFormattedTime(hour, min);
				value = value[:hour] + ":" + value[:min] + value[:amPm]; 
			}

		// Waiting for location.
		} else {
			value = "gps?";
		}
    	return value;
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
