package module4;

import java.util.ArrayList;
import java.util.List;

import de.fhpotsdam.unfolding.UnfoldingMap;
import de.fhpotsdam.unfolding.data.Feature;
import de.fhpotsdam.unfolding.data.GeoJSONReader;
import de.fhpotsdam.unfolding.data.PointFeature;
import de.fhpotsdam.unfolding.geo.Location;
import de.fhpotsdam.unfolding.marker.AbstractShapeMarker;
import de.fhpotsdam.unfolding.marker.Marker;
import de.fhpotsdam.unfolding.marker.MultiMarker;
import de.fhpotsdam.unfolding.providers.Google;
import de.fhpotsdam.unfolding.providers.MBTilesMapProvider;
import de.fhpotsdam.unfolding.utils.MapUtils;
import parsing.ParseFeed;
import processing.core.PApplet;

/** EarthquakeCityMap
 * An application with an interactive map displaying earthquake data.
 * Author: UC San Diego Intermediate Software Development MOOC team
 * @author Your name here
 * Date: July 17, 2015
 * */
public class EarthquakeCityMap extends PApplet {
	
	// We will use member variables, instead of local variables, to store the data
	// that the setUp and draw methods will need to access (as well as other methods)
	// You will use many of these variables, but the only one you should need to add
	// code to modify is countryQuakes, where you will store the number of earthquakes
	// per country.
	
	// You can ignore this.  It's to get rid of eclipse warnings
	private static final long serialVersionUID = 1L;

	// IF YOU ARE WORKING OFFILINE, change the value of this variable to true
	private static final boolean offline = false;
	
	/** This is where to find the local tiles, for working without an Internet connection */
	public static String mbTilesString = "blankLight-1-3.mbtiles";
	
	

	//feed with magnitude 2.5+ Earthquakes
	private String earthquakesURL = "http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_week.atom";
	
	// The files containing city names and info and country names and info
	private String cityFile = "city-data.json";
	private String countryFile = "countries.geo.json";
	
	// The map
	private UnfoldingMap map; // create a map object
	
	// Markers for each city
	private List<Marker> cityMarkers; // is a list of city markers
	// Markers for each earthquake
	private List<Marker> quakeMarkers; // is a list of quake markers

	// A List of country markers
	private List<Marker> countryMarkers; // is a list of country markers
	
	public void setup() {		
		// (1) Initializing canvas and map tiles
		size(900, 700, OPENGL);
		if (offline) {
		    map = new UnfoldingMap(this, 200, 50, 650, 600, new MBTilesMapProvider(mbTilesString));
		    earthquakesURL = "2.5_week.atom";  // The same feed, but saved August 7, 2015
		}
		else {
			map = new UnfoldingMap(this, 200, 50, 650, 600, new Google.GoogleMapProvider()); // size of map: 450 x 550 square pixels
			// IF YOU WANT TO TEST WITH A LOCAL FILE, uncomment the next line
		    //earthquakesURL = "test2.atom";
		}
		MapUtils.createDefaultEventDispatcher(this, map); // display the canvas and map tiles
	 	
		// FOR TESTING: Set earthquakesURL to be one of the testing files by uncommenting
		// one of the lines below.  This will work whether you are online or offline
		//earthquakesURL = "test1.atom";
		//earthquakesURL = "test2.atom";
		
		// WHEN TAKING THIS QUIZ: Uncomment the next line
		earthquakesURL = "quiz1.atom";
				
		// (2) Reading in earthquake data and geometric properties
	    //     STEP 1: load country features and markers
		List<Feature> countries = GeoJSONReader.loadData(this, countryFile); // load country names into list of countries
		countryMarkers = MapUtils.createSimpleMarkers(countries); // create marker for each country in the list
		
		//     STEP 2: read in city data
		List<Feature> cities = GeoJSONReader.loadData(this, cityFile); // load city names into list of cities
		cityMarkers = new ArrayList<Marker>(); // create marker for each city in the list
		for(Feature city : cities) { // for each city in the list of cities
		  cityMarkers.add(new CityMarker(city)); // add the city feature to the list of cityMarkers
		}
	    
		//     STEP 3: read in earthquake RSS feed
	    List<PointFeature> earthquakes = ParseFeed.parseEarthquake(this, earthquakesURL);
	    quakeMarkers = new ArrayList<Marker>();
	    
	    for(PointFeature feature : earthquakes) {
		  //check if LandQuake
		  if(isLand(feature)) {
		    quakeMarkers.add(new LandQuakeMarker(feature));
		  }
		  // OceanQuakes
		  else {
		    quakeMarkers.add(new OceanQuakeMarker(feature));
		  }
	    }

	    // could be used for debugging
	    printQuakes();
	    
	    // (3) Add markers to map
	    //     NOTE: Country markers are not added to the map.  They are used
	    //           for their geometric properties
	    map.addMarkers(quakeMarkers);
	    map.addMarkers(cityMarkers);
	    
	}  // End setup
	
	
	public void draw() {
		background(0);
		map.draw();
		addKey();
		
	}
	
	// helper method to draw key in GUI
	// TODO: Update this method as appropriate
	private void addKey() {	
		// Remember you can use Processing's graphics methods here
		fill(255, 250, 240);
		rect(25, 50, 150, 250);
		
		fill(0);
		textAlign(LEFT, CENTER);
		textSize(12);
		text("Earthquake Key", 50, 75);
		
		fill(color(255, 0, 0));
		int L = 10;
		int x = 50; 
		int y = 100;
		int dy = 20;
		triangle(x - L/2, (float) (y + L/(2 * 1.732)), 
				x + L/2, (float) (y + L/(2 * 1.732)), 
				x, (float) (y - L/1.732)); // ellipse(50, 125, 15, 15);
		fill(color(255, 255, 255));
		ellipse(x, y + dy, 10, 10);
		fill(color(255, 255, 255));
		rect(x - 5, y + 2*dy - 5, 10, 10);
		
		fill(0, 0, 0);
		text("City Marker", x + 25, (float) (y - L/(2 * 1.732)));//("5.0+ Magnitude", 75, 125);
		text("Land Marker", x + 25, y + dy);
		text("Ocean Marker", x + 25, y + 2*dy);
		
		// Depth legend
		fill(0);
		textAlign(LEFT, CENTER);
		textSize(12);
		text("size ~ magnitude", x, y + 3*dy);
		
		fill(color(255, 255, 0));
		ellipse(x, y + 5*dy, 10, 10);
		fill(color(0, 0, 255));
		ellipse(x, y + 6*dy, 10, 10);
		fill(color(255, 0, 0));
		ellipse(x, y + 7*dy, 10, 10);
		fill(0);
		line(x-2, y+8*dy-2, x+2, y+8*dy+2);
		line(x-2, y+8*dy+2, x+2, y+8*dy-2);
		
		fill(0);
		text("Shallow", x + 25, y + 5*dy);
		text("Intermediate", x + 25, y + 6*dy);
		text("Deep", x + 25, y + 7*dy);
		text("Occurred Today", x + 25, y + 8*dy);
		
	}

	
	
	// Checks whether this quake occurred on land.  If it did, it sets the 
	// "country" property of its PointFeature to the country where it occurred
	// and returns true.  Notice that the helper method isInCountry will
	// set this "country" property already.  Otherwise it returns false.
	private boolean isLand(PointFeature earthquake) {
		
		// IMPLEMENT THIS: loop over all countries to check if location is in any of them
		for(Marker country : countryMarkers) {
		// TODO: Implement this method using the helper method isInCountry
		// not inside any country
			if(isInCountry(earthquake, country)) {
				return true;
			} 
		}
		// if country not in the list	
		return false;
	}
	
	// prints countries with number of earthquakes
	// You will want to loop through the country markers or country features
	// (either will work) and then for each country, loop through
	// the quakes to count how many occurred in that country.
	// Recall that the country markers have a "name" property, 
	// And LandQuakeMarkers have a "country" property set.
	private void printQuakes() 
	{
		// TODO: Implement this method
		// Print quakes in each country
		int numOQuakes = 0;
		List<PointFeature> earthquakes = ParseFeed.parseEarthquake(this, earthquakesURL);
		
		for(Marker countryMarker : countryMarkers) {
			int numCQuakes = 0;
			for(PointFeature earthquake : earthquakes) {
				if(isInCountry(earthquake, countryMarker)) {numCQuakes ++;} // check if the location of earthquake is inside the country
			}
			
			if(numCQuakes > 0) { // any quakes
				System.out.println("The number of earthquakes in the " + 
			           countryMarker.getStringProperty("name") + 
			           " equals to " + numCQuakes);
			}
		}
		
		for(Marker quakeMarker : quakeMarkers) {
			if(!((EarthquakeMarker) quakeMarker).isOnLand) {
				numOQuakes ++;
			}
		}
		
		if(numOQuakes > 0) {
			System.out.println("The number of earthquakes in the Ocean equals " + 
		           numOQuakes);
		}
	}
	

	
	// helper method to test whether a given earthquake is in a given country
	// This will also add the country property to the properties of the earthquake 
	// feature if it's in one of the countries.
	// You should not have to modify this code
	private boolean isInCountry(PointFeature earthquake, Marker country) {
		// getting location of feature
		Location checkLoc = earthquake.getLocation();

		// some countries represented it as MultiMarker
		// looping over SimplePolygonMarkers which make them up to use isInsideByLoc
		if(country.getClass() == MultiMarker.class) {  // what is ".class"?
				
			// looping over markers making up MultiMarker
			for(Marker marker : ((MultiMarker)country).getMarkers()) {
					
				// checking if inside
				if(((AbstractShapeMarker)marker).isInsideByLocation(checkLoc)) {
					earthquake.addProperty("country", country.getProperty("name"));
						
					// return if is inside one
					return true;
				}
			}
		}
			
		// check if inside country represented by SimplePolygonMarker
		else if(((AbstractShapeMarker)country).isInsideByLocation(checkLoc)) {
			earthquake.addProperty("country", country.getProperty("name"));
			
			return true;
		}
		return false;
	}

}