window.onload = function() {
	// Changing Surah names
	$('#surahlist').on('change', function() {
		var surahId= $(this).val();
		var url = "/quran/surah/"+surahId;
		location.replace(url);  
	})
	// Changing Surah in Compare page
	$('#surahlist-compare').on('change', function() {
		var surahId= $(this).val();
		var url = "/quran/compare/"+surahId+"/1";
		location.replace(url);  
	})
	// Changing Ayah in Compare page
	$('#ayahlist-compare').on('change', function() {
		var surahId= $('#surahlist-compare').val();
		var ayahId= $('#ayahlist-compare').val();
		var url = "/quran/compare/"+surahId+"/"+ayahId;
		location.replace(url);  
	})
	//Changing Hadith books
	$('#hadithlist').on('change', function() {
		var hdBook= $(this).val();
		var url = "/hadith/"+hdBook+"/1";
		localStorage.setItem("hdBook", hdBook);
		location.replace(url);  
	})
	// Next hadith navigation 
	$('#hadith-next').on('click', function() {
		var pathArray = window.location.pathname.split( '/' );
		var hadithNumber = pathArray[3];
		var hdBook = pathArray[2];
		var url = "/hadith/"+hdBook+"/"+(parseInt(hadithNumber)+1);
		if(parseInt(hadithNumber)+1 <= 10)
			location.replace(url); 
	})
	// Previous hadith navigation 
	$('#hadith-prev').on('click', function() {
		var pathArray = window.location.pathname.split( '/' );
		var hadithNumber = pathArray[3];
		var hdBook = pathArray[2];
		var url = "/hadith/"+hdBook+"/"+(parseInt(hadithNumber)-1);
		if(parseInt(hadithNumber)-1 > 0)
			location.replace(url); 
	})

}
