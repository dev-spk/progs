package module3;

//Java utilities libraries
import java.util.ArrayList;
//import java.util.Collections;
//import java.util.Comparator;
import java.util.List;

//Processing library
import processing.core.PApplet;

//Unfolding libraries
import de.fhpotsdam.unfolding.UnfoldingMap;
import de.fhpotsdam.unfolding.marker.Marker;
import de.fhpotsdam.unfolding.data.PointFeature;
import de.fhpotsdam.unfolding.marker.SimplePointMarker;
import de.fhpotsdam.unfolding.providers.Google;
import de.fhpotsdam.unfolding.providers.MBTilesMapProvider;
import de.fhpotsdam.unfolding.utils.MapUtils;

//Parsing library
import parsing.ParseFeed;

/** EarthquakeCityMap
 * An application with an interactive map displaying earthquake data.
 * Author: UC San Diego Intermediate Software Development MOOC team
 * @author Your name here
 * Date: July 17, 2015
 * */
public class EarthquakeCityMap extends PApplet {

	// You can ignore this.  It's to keep eclipse from generating a warning.
	private static final long serialVersionUID = 1L;

	// IF YOU ARE WORKING OFFLINE, change the value of this variable to true
	private static final boolean offline = false;
	
	// Less than this threshold is a light earthquake
	public static final float THRESHOLD_MODERATE = 5;
	// Less than this threshold is a minor earthquake
	public static final float THRESHOLD_LIGHT = 4;

	/** This is where to find the local tiles, for working without an Internet connection */
	public static String mbTilesString = "blankLight-1-3.mbtiles";
	
	// The map
	private UnfoldingMap map;
	
	//feed with magnitude 2.5+ Earthquakes
	private String earthquakesURL = "http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_week.atom";//"http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_month.atom";//"http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_week.atom";

	
	public void setup() {
		size(950, 600, OPENGL);

		if (offline) {
		    map = new UnfoldingMap(this, 200, 50, 700, 500, new MBTilesMapProvider(mbTilesString));
		    earthquakesURL = "2.5_week.atom"; 	// Same feed, saved Aug 7, 2015, for working offline
		}
		else {
			map = new UnfoldingMap(this, 200, 50, 1750, 950, new Google.GoogleMapProvider());
			// IF YOU WANT TO TEST WITH A LOCAL FILE, uncomment the next line
			//earthquakesURL = "2.5_week.atom";
		}
		
	    map.zoomToLevel(2);
	    MapUtils.createDefaultEventDispatcher(this, map);	
			
	    // The List you will populate with new SimplePointMarkers
	    List<Marker> markers = new ArrayList<Marker>();

	    //Use provided parser to collect properties for each earthquake
	    //PointFeatures have a getLocation method
	    List<PointFeature> earthquakes = ParseFeed.parseEarthquake(this, earthquakesURL);
	    
	    /* // These print statements show you (1) all of the relevant properties 
	    // in the features, and (2) how to get one property and use it
	    if (earthquakes.size() > 0) {
	    	PointFeature f = earthquakes.get(0);
	    	// println("Location is " + f.getLocation());
	    	System.out.println(f.getProperties());
	    	Object magObj = f.getProperty("magnitude");
	    	float mag = Float.parseFloat(magObj.toString());
	    	// println("magnitude is " + mag);
	    	// PointFeatures also have a getLocation method
	    } 
	    
	    // Here is an example of how to use Processing's color method to generate 
	    // an int that represents the color yellow.  
	    int yellow = color(255, 255, 0);
	    */
	    
	    //TODO: Add code here as appropriate
	    //List<SimplePointMarker> SPMarkers = new ArrayList<SimplePointMarker>(); // create an empty-list of SimplePointMarkers
	    if (earthquakes.size() > 0) {
	    	for(PointFeature earthquake : earthquakes) {
	    		Object magObj = earthquake.getProperty("magnitude");
	    		float mag = Float.parseFloat(magObj.toString());
	    		SimplePointMarker S = createMarker(earthquake);
	    		S = selectColor(S, mag);
	    		markers.add(S); // insert element at the end-of-the-List
	    	}
	    	map.addMarkers(markers);
	    	/*	    
	    	showMarkers(); // see function in LifeExpectancy.java
	    	 */
	    }
	    
	}
    
	// Helper function for choosing the color
	private SimplePointMarker selectColor(SimplePointMarker S, float mag){
		if (mag <= 3.99){
			S.setColor(color(0, 0, 255*mag/4));
			S.setRadius(5);
		} else if (mag > 3.99 && mag <= 4.99){
			S.setColor(color(255*mag/5, 255*mag/5, 0));
			S.setRadius(8);
		} else{
			S.setColor(color(255*mag/5, 0, 0)); // earthquake magnitude range: 0-10
			S.setRadius(10);
		}
		return S;
	}
	
	// A suggested helper method that takes in an earthquake feature and 
	// returns a SimplePointMarker for that earthquake
	// TODO: Implement this method and call it from setUp, if it helps
	private SimplePointMarker createMarker(PointFeature feature)
	{
		// finish implementing and use this method, if it helps.
		SimplePointMarker S = new SimplePointMarker(feature.getLocation());
		S.setRadius(10);
		return S;
	}
	
	public void draw() {
	    background(10);
	    map.draw();
	    addKey();
	}


	// helper method to draw key in GUI
	// TODO: Implement this method to draw the key
	private void addKey() 
	{	
		// Remember you can use Processing's graphics methods here
		fill(color(200, 200, 200));
		rect(50, 50, 250, 350, 10); // (x1, y1, x2, y2, edge-curvature) 
		
		textSize(24);
		fill(color(0, 0, 0));
		text("Magnitude", 65, 75);
		
		fill(color(255, 0, 0));
		ellipse(75, 105, 20, 20); // (x, y, d_minor, d_major)
		text(">= 5.0", 100, 115);
		// textAlign(CENTER, LEFT);
		
		fill(color(255, 255, 0));
		ellipse(75, 180, 14, 14);
		text("= 4.0 - 4.99", 100, 190);
		
		fill(color(0, 0, 255));
		ellipse(75, 255, 7, 7);
		text("<= 3.99", 100, 265);
	}
}
