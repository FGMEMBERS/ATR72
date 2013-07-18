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
	var types = [];
	types[0] = type;
	var results = internalSearch(name, types);
	return results;
}
## gpsSearchAll(name) - Looks for VORs, NDBs and FIXes

var gpsSearchAll = func(name) {
	var types = ["vor", "ndb", "fix"]; # Add more here if required
	var results = internalSearch(name, types);
	return results;
}

var internalSearch = func(name, types) {
	if (fgfs.versionCheck()) {
		return SearchNew(name, types);
	}
	else {
		return SearchLegacy(name, types);
	}
}

var SearchLegacy = func(name, types) {
	var gps = "/instrumentation/gps/";
	var results = [];
	
	foreach(var type; types) {
			setprop(gps~"scratch/query", name);
			setprop(gps~"scratch/type", type);
			setprop(gps~"command", "search");
			
			var num = getprop(gps~"scratch/result-count");
			
			for(var n=0; n<num; n+=1) {
					if (getprop(gps~"/scratch/valid")) {
						var result = {
						
								ident: getprop(gps~"scratch/ident"),
								name: getprop(gps~"scratch/name"),
								brg: int(getprop(gps~"scratch/true-bearing-deg")),
								dist: int(getprop(gps~"scratch/distance-nm")),
								lat: getprop(gps~"scratch/latitude-deg"),
								lon: getprop(gps~"scratch/longitude-deg"),
								type: type
						
						};

						if (result.dist != nil) {
								#if (result.dist > 0) {
										append(results, result);
								#}
						}
					}
					setprop(gps~"command", "next");
			}
	}
	return results;
}

var SearchNew = func(name, types) {
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
	
			returnResult.brg = int(getBearing(result.lat, result.lon));
			returnResult.dist = int(getDistance(result.lat, result.lon));
	
			append(returnResults, returnResult);
		}
	}	
	return returnResults;
}
