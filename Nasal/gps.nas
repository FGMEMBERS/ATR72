var gps = {
	searchIdent : func(query, type) {
		return positioned.sortByRange(positioned.findByIdent(query, type));
	}
};
