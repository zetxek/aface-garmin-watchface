import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System;

using Toybox.ActivityMonitor as ActivityMonitor;

/**
 ** Draws a data field next to an optional icon
**/ 
class DataField extends Ui.Drawable{

	// custom font glyps for the icons on screen
	const CHAR_ICON_BLUETOOTH	= "~";
	const CHAR_ICON_BATTERY 	= ">";
	const CHAR_ICON_CALORIES	= "æ";
	const CHAR_ICON_SUN			= "^";
	const CHAR_ICON_FLOORS		= "}";
	
	enum{
		DATA_FIELD_BATTERY,
		DATA_FIELD_SUN,
		DATA_FIELD_CALORIES,
		DATA_FIELD_STEPS,
		DATA_FIELD_FLOORS,
	}
	
	enum{
		ICON_ALIGNMENT_LEFT,
		ICON_ALIGNMENT_RIGHT
	}

	var hasIcon = true;
	var dataType;
	var iconAlignment = ICON_ALIGNMENT_LEFT;
	
	var posX = 0;
	var posY = 0;
	
	var stats;
	var activityInfo;
	var sunTimes as Array<Float> or Null;

	function initialize(params) {
        Drawable.initialize(params);
        dataType = params.get(:dataType);
        iconAlignment = params.get(:iconAlignment);
        posX = params.get(:posX);
        posY = params.get(:posY);
        System.println("Data type args: " + params);
        
        stats = System.getSystemStats();
    	activityInfo = ActivityMonitor.getInfo();
    }
    
    function draw(dc) {
        var font = WatchUi.loadResource(Rez.Fonts.CustomFont);
        dc.setColor(getIconColor(), Gfx.COLOR_TRANSPARENT);
        
        var posX1 = calcPixelValue(posX, dc);
        var posY1 = calcPixelValue(posY, dc);
        dc.drawText(
        	posX1,
        	posY1, 
        	font, 
        	getIcon(), 
        	Graphics.TEXT_JUSTIFY_LEFT
        );
		
		font = Graphics.FONT_SYSTEM_TINY;
		dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
		
		var offsetX = 16;
		var offsetY = -40;
		var textAlignment = Graphics.TEXT_JUSTIFY_LEFT;
		
		if (iconAlignment == ICON_ALIGNMENT_RIGHT){
			offsetX = -6;
			textAlignment = Graphics.TEXT_JUSTIFY_RIGHT;
		}
		var posX2 = posX1 + offsetX;
		var posY2 = posY1 - offsetY;
        dc.drawText(
        	posX2,
        	calcPixelValue(posY, dc), 
        	font, 
        	getTextValue(), 
			textAlignment
		);
    }
    
    function getIconColor(){
    	switch(dataType){
    		case DATA_FIELD_BATTERY:
    			return getBatteryColor();
    		default:
    			return Gfx.COLOR_LT_GRAY;
    	}
    }
    
    function getIcon(){
    	switch(dataType){
    		case DATA_FIELD_BATTERY:
    			return CHAR_ICON_BATTERY;
    		case DATA_FIELD_CALORIES:
    			return CHAR_ICON_CALORIES;
    		case DATA_FIELD_FLOORS:
    			return CHAR_ICON_FLOORS;
    		case DATA_FIELD_SUN:
    			return CHAR_ICON_SUN;
    		default:
    			return "";
    	}
    }
    
    function getTextValue(){
    	switch(dataType){
    		case DATA_FIELD_BATTERY:
    			return stats.battery.format("%d") + "%";
    		case DATA_FIELD_CALORIES:
    			return activityInfo.calories.format("%d");
    		case DATA_FIELD_FLOORS:
    			return activityInfo.floorsClimbed.format("%d");
    		case DATA_FIELD_SUN:
    			return getSunValue();
    		default:
    			return "";
    	}
    	
    }
    
    function getBatteryColor(){
		if (stats.battery < 15.0){
			return Graphics.COLOR_RED;
		}else if (stats.battery < 30.0){
			return Graphics.COLOR_YELLOW;
		}
		
		return Graphics.COLOR_GREEN;
	}
    
    // as drawText does not support % values, if we want to use them, we transform first
    function calcPixelValue(coord, dc){
    	if (coord.find("%") != null){
    		coord = coord.substring(0, coord.find("%"));
    		coord = coord.toFloat();
    		coord = coord * dc.getWidth() / 100;
    	}
    	
    	return coord;
    }
    
    function getSunValue(){
    
    	var sunCalc = new SunCalc();
    	var value;
    	if (gLocationLat != null) {
			var nextSunEvent = 0;
			var now = Toybox.Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);

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
				value = sunCalc.getFormattedTime(hour, min);
				value = value[:hour] as Toybox.Lang.String 
						+ ":" + value[:min] as Toybox.Lang.String 
						+ value[:amPm] as Toybox.Lang.String; 
			}

		// Waiting for location.
		} else {
			value = "❌ gps";
		}
    	return value;
    }
}