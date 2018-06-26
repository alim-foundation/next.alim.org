window.onload = function() {	
	// changing Surah names
	$('#surahlist').on('change', function() {
		var surahId= $(this).val();
		var url = "/quran/surah/"+surahId;
		localStorage.setItem("surahId", surahId);
		location.replace(url);  
	})
	//changing Hadith books
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
		if(parseInt(hadithNumber)+1 <= 2)
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