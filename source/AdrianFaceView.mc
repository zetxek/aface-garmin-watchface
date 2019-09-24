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
	var topIndicatorLongText1View;
	var topIndicatorLongText2View;
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
		
		var heartIcon = View.findDrawableById("HeartIcon");
		
		
		topIndicatorLongText1View = View.findDrawableById("TopIndicatorLongText1");
		topIndicatorLongText1View.setText(getSunValue());

		topIndicatorLongText2View = View.findDrawableById("TopIndicatorLongText2");		
		topIndicatorLongText2View.setText(stats.battery.format(INTEGER_FORMAT) + "%");
		var topIndicatorLongText2Icon = View.findDrawableById("TopIndicatorLongIcon2");
		topIndicatorLongText2Icon.setColor(Graphics.COLOR_GREEN);
		if (stats.battery < 30.0){
			topIndicatorLongText2Icon.setColor(Graphics.COLOR_YELLOW);
		}else if (stats.battery < 15.0){
			topIndicatorLongText2Icon.setColor(Graphics.COLOR_RED);
		}

		bottomIndicatorLongText1View = View.findDrawableById("BottomIndicatorLongText1");
		bottomIndicatorLongText1View.setText(activityInfo.calories.format(INTEGER_FORMAT));
		
		bottomIndicatorLongText2View = View.findDrawableById("BottomIndicatorLongText2");
		var value= activityInfo.floorsClimbed;
		bottomIndicatorLongText2View.setText(value.format(INTEGER_FORMAT));


		

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
    
    function getSunValue(){
    
    	var value;
    	if (gLocationLat != null) {
			var nextSunEvent = 0;
			var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT);

			// Convert to same format as sunTimes, for easier comparison. Add a minute, so that e.g. if sun rises at
			// 07:38:17, then 07:38 is already consided daytime (seconds not shown to user).
			now = now.hour + ((now.min + 1) / 60.0);
			//Sys.println(now);

			// Get today's sunrise/sunset times in current time zone.
			sunTimes = getSunTimes(gLocationLat, gLocationLng, null, /* tomorrow */ false);
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
					sunTimes = getSunTimes(gLocationLat, gLocationLng, null, /* tomorrow */ true);
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


	/**
	* With thanks to ruiokada. Adapted, then translated to Monkey C, from:
	* https://gist.github.com/ruiokada/b28076d4911820ddcbbc
	*
	* Calculates sunrise and sunset in local time given latitude, longitude, and tz.
	*
	* Equations taken from:
	* https://en.wikipedia.org/wiki/Julian_day#Converting_Julian_or_Gregorian_calendar_date_to_Julian_Day_Number
	* https://en.wikipedia.org/wiki/Sunrise_equation#Complete_calculation_on_Earth
	*
	* @method getSunTimes
	* @param {Float} lat Latitude of location (South is negative)
	* @param {Float} lng Longitude of location (West is negative)
	* @param {Integer || null} tz Timezone hour offset. e.g. Pacific/Los Angeles is -8 (Specify null for system timezone)
	* @param {Boolean} tomorrow Calculate tomorrow's sunrise and sunset, instead of today's.
	* @return {Array} Returns array of length 2 with sunrise and sunset as floats.
	*                 Returns array with [null, -1] if the sun never rises, and [-1, null] if the sun never sets.
	*/
	function getSunTimes(lat, lng, tz, tomorrow) {

		// Use double precision where possible, as floating point errors can affect result by minutes.
		lat = lat.toDouble();
		lng = lng.toDouble();

		var now = Time.now();
		if (tomorrow) {
			now = now.add(new Time.Duration(24 * 60 * 60));
		}
		var d = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
		var rad = Math.PI / 180.0d;
		var deg = 180.0d / Math.PI;
		
		// Calculate Julian date from Gregorian.
		var a = Math.floor((14 - d.month) / 12);
		var y = d.year + 4800 - a;
		var m = d.month + (12 * a) - 3;
		var jDate = d.day
			+ Math.floor(((153 * m) + 2) / 5)
			+ (365 * y)
			+ Math.floor(y / 4)
			- Math.floor(y / 100)
			+ Math.floor(y / 400)
			- 32045;

		// Number of days since Jan 1st, 2000 12:00.
		var n = jDate - 2451545.0d + 0.0008d;
		//Sys.println("n " + n);

		// Mean solar noon.
		var jStar = n - (lng / 360.0d);
		//Sys.println("jStar " + jStar);

		// Solar mean anomaly.
		var M = 357.5291d + (0.98560028d * jStar);
		var MFloor = Math.floor(M);
		var MFrac = M - MFloor;
		M = MFloor.toLong() % 360;
		M += MFrac;
		//Sys.println("M " + M);

		// Equation of the centre.
		var C = 1.9148d * Math.sin(M * rad)
			+ 0.02d * Math.sin(2 * M * rad)
			+ 0.0003d * Math.sin(3 * M * rad);
		//Sys.println("C " + C);

		// Ecliptic longitude.
		var lambda = (M + C + 180 + 102.9372d);
		var lambdaFloor = Math.floor(lambda);
		var lambdaFrac = lambda - lambdaFloor;
		lambda = lambdaFloor.toLong() % 360;
		lambda += lambdaFrac;
		//Sys.println("lambda " + lambda);

		// Solar transit.
		var jTransit = 2451545.5d + jStar
			+ 0.0053d * Math.sin(M * rad)
			- 0.0069d * Math.sin(2 * lambda * rad);
		//Sys.println("jTransit " + jTransit);

		// Declination of the sun.
		var delta = Math.asin(Math.sin(lambda * rad) * Math.sin(23.44d * rad));
		//Sys.println("delta " + delta);

		// Hour angle.
		var cosOmega = (Math.sin(-0.83d * rad) - Math.sin(lat * rad) * Math.sin(delta))
			/ (Math.cos(lat * rad) * Math.cos(delta));
		//Sys.println("cosOmega " + cosOmega);

		// Sun never rises.
		if (cosOmega > 1) {
			return [null, -1];
		}
		
		// Sun never sets.
		if (cosOmega < -1) {
			return [-1, null];
		}
		
		// Calculate times from omega.
		var omega = Math.acos(cosOmega) * deg;
		var jSet = jTransit + (omega / 360.0);
		var jRise = jTransit - (omega / 360.0);
		var deltaJSet = jSet - jDate;
		var deltaJRise = jRise - jDate;

		var tzOffset = (tz == null) ? (Sys.getClockTime().timeZoneOffset / 3600) : tz;
		return [
			/* localRise */ (deltaJRise * 24) + tzOffset,
			/* localSet */ (deltaJSet * 24) + tzOffset
		];
	}
	
// Return a formatted time dictionary that respects is24Hour and HideHoursLeadingZero settings.
	// - hour: 0-23.
	// - min:  0-59.
	function getFormattedTime(hour, min) {
		var amPm = "";

		if (!Sys.getDeviceSettings().is24Hour) {

			// #6 Ensure noon is shown as PM.
			var isPm = (hour >= 12);
			if (isPm) {
				
				// But ensure noon is shown as 12, not 00.
				if (hour > 12) {
					hour = hour - 12;
				}
				amPm = "p";
			} else {
				
				// #27 Ensure midnight is shown as 12, not 00.
				if (hour == 0) {
					hour = 12;
				}
				amPm = "a";
			}
		}

		// #10 If in 12-hour mode with Hide Hours Leading Zero set, hide leading zero. Otherwise, show leading zero.
		// #69 Setting now applies to both 12- and 24-hour modes.
		hour = hour.format(App.getApp().getProperty("HideHoursLeadingZero") ? INTEGER_FORMAT : "%02d");

		return {
			:hour => hour,
			:min => min.format("%02d"),
			:amPm => amPm
		};
	}
}
