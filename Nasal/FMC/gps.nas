# GPS 'Positioned API' Functions

## getBearing(lat,lon) - returns bearing to position

var getBearing = func(lat,lon) {
	var ac_pos = geo.aircraft_position();
	var wpt = geo.Coord.new();
	wpt.set_latlon(lat,lon);
	return ac_pos.course_to(wpt);
}

## getDistance(lat,lon) - returns distance to position

var getDistance = func(lat,lon) {
	var NM2M = 1852;
	var ac_pos = geo.aircraft_position();
	var wpt = geo.Coord.new();
	wpt.set_latlon(lat,lon);
	return (ac_pos.distance_to(wpt))/NM2M;
}

### Data required to be returned: ident, lat, lon, type, name, brg, dist

## gpsSearch(name, type) - Looks for navaids of specified type

var gpsSearch = func(name, type) {
	var results = positioned.sortByRange(positioned.findByIdent(name, type));
	var returnResults = [];
	foreach(var result; results) {
		var returnResult = {
			ident: result.id,
			lat: result.lat,
			lon: result.lon,
			type: result.type,
			name: result.name,
			brg: 0,
			dist: 0
		};
		
		returnResult.brg = getBearing(result.lat, result.lon);
		returnResult.dist = getDistance(result.lat, result.lon);
		
		append(returnResults, returnResult);
	}
	
	return returnResults;
}

## gpsSearchAll(name) - Looks for VORs, NDBs and FIXes

var gpsSearchAll = func(name) {
	var types = ["vor", "ndb", "fix"]; # Add more here if required
	var returnResults = [];
	foreach(var type; types) {
		var results = positioned.sortByRange(positioned.findByIdent(name, type));
		foreach(var result; results) {
			var returnResult = {
				ident: result.id,
				lat: result.lat,
				lon: result.lon,
				type: result.type,
				name: result.name,
				brg: 0,
				dist: 0
			};
		
			returnResult.brg = getBearing(result.lat, result.lon);
			returnResult.dist = getDistance(result.lat, result.lon);
		
			append(returnResults, returnResult);
		}
	}
	
	return returnResults;
}
