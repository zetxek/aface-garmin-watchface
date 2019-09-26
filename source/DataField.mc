using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System;
/**
 ** Draws a data field next to an optional icon
**/ 
class DataField extends Ui.Drawable{

	const CHAR_ICON_BLUETOOTH	= "~";
	const CHAR_ICON_BATTERY 	= ">";
	
	enum{
		DATA_FIELD_BATTERY,
		DATA_FIELD_SUN,
		DATA_FIELD_CALORIES,
		DATA_FIELD_STEPS,
		DATA_FIELD_FLOORS,
	}

	var hasIcon = true;
	var dataType;
	
	var posX = 0;
	var posY = 0;
	
	var stats;

	function initialize(params) {
        Drawable.initialize(params);
        dataType = params.get(:dataType);
        posX = params.get(:posX);
        posY = params.get(:posY);
        System.println("Data type args: " + params);
        stats = System.getSystemStats();
    }
    
    function draw(dc) {
        var font = WatchUi.loadResource(Rez.Fonts.CustomFont);
        dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT);
        
        var posX1 = calcPixelValue(posX, dc);
        var posY1 = calcPixelValue(posY, dc);
        dc.drawText(
        	posX1,
        	posY1, 
        	font, 
        	getIcon(), 
        	Graphics.TEXT_JUSTIFY_LEFT
        );
		
		font = WatchUi.loadResource(Rez.Fonts.InterTiny);
		dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
		
		var posX2 = posX1 + 16;
		var posY2 = posY1 - 6;
        dc.drawText(
        	posX2,
        	calcPixelValue(posY, dc), 
        	font, 
        	getTextValue(), 
			Graphics.TEXT_JUSTIFY_LEFT
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
    		default:
    			return "";
    	}
    }
    
    function getTextValue(){
    	switch(dataType){
    		case DATA_FIELD_BATTERY:
    			return stats.battery.format("%d") + "%";
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
    
    
}