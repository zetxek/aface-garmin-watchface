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

	var hoursView as Ui.Text or Null;
	var separatorView as  Ui.Text or Null;
	var minutesView as  Ui.Text or Null;
	var dateView as  Ui.Text or Null;
	
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
    
    	// var activityInfo = ActivityMonitor.getInfo();
    	var settings = System.getDeviceSettings();
    	// var stats = System.getSystemStats();
    
    
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
        hoursView = View.findDrawableById("TimeHour") as Ui.Text;
        hoursView.setText(hoursString);
        
        separatorView = View.findDrawableById("TimeSeparator") as Ui.Text;
       	separatorView.setText(":");
       	
        minutesView = View.findDrawableById("TimeMinutes") as Ui.Text;
        minutesView.setText(minutesString);

		dateView = View.findDrawableById("Date") as Ui.Text;
		dateView.setText(dateString);
		
		bluetoothIcon = View.findDrawableById("BluetoothIcon");
		var phone = settings.phoneConnected;
		if (phone){
			bluetoothIcon.setColor(Graphics.COLOR_GREEN);		
		}else{
			bluetoothIcon.setColor(Graphics.COLOR_RED);
		}
		
		var dndIcon = View.findDrawableById("DNDIcon") as Ui.Text;
		var doNotDisturb = settings.doNotDisturb;
		if (doNotDisturb){
			dndIcon.setColor(Graphics.COLOR_GREEN);		
		}else{
			dndIcon.setColor(Graphics.COLOR_RED);		
		}

		var notificationIcon = View.findDrawableById("NotificationsIcon") as Ui.Text;
		var notificationCount = settings.notificationCount;
		if (notificationCount > 0){
			notificationIcon.setColor(Graphics.COLOR_GREEN);	
		}

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
