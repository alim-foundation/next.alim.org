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
		var hdVolume = $('#hd_volume').val();
		if( hdBook =="amh" || hdBook =="shb" || hdBook =="fqs")
		{
			var url = "/hadith/"+hdBook+"/"+hdVolume+"/1";
			localStorage.setItem("hdBook", hdBook);
			location.replace(url); 
		}
		else
		{
			var url = "/hadith/"+hdBook+"/1";
			localStorage.setItem("hdBook", hdBook);
			location.replace(url);  
		}

	})
	function UrlExists(hdNum,url,nav) {
		var hdInt =  parseInt(hdNum);
		var hdIntNxt =  parseInt(hdNum)+1;
		var hdIntPrv =  parseInt(hdNum)-1;
		var urls= "";
		if(nav == "goto"){
			urls = url+"/"+hdInt
		}
		else if(nav == "next"){
			urls = url+"/"+hdIntNxt;
		}
		else if(nav == "prev"){
			urls = url+"/"+hdIntPrv;
		}
		var http = new XMLHttpRequest();
		http.open('HEAD', urls, false);
		http.send();
		if (http.status != 404)
			location.replace(urls); 
		else{
			alert('Hadith does not exist');
			if(nav == "next"){
				UrlExists(hdIntNxt, url,nav);
			}
			else if(nav == "prev"){
				UrlExists(hdIntPrv, url,nav);
			}	
		}
			 
	}
	//Hadith goto function
	$('#goto_button').on('click', function() {
		var hdBook= $('#hadithlist').val();
		var gotoNum= $("#goto_text").val();
		var hdVolume = $('#hd_volume').val();
		var hadithCount = $('#hadith-next').attr('rel');
		if((hdBook =="amh" || hdBook =="shb" || hdBook =="fqs"))
		{
			if( parseInt(gotoNum) <=  parseInt(hadithCount))
			{
				var url = "/hadith/"+hdBook+"/"+hdVolume;
				var statusReq = UrlExists(gotoNum, url,"goto");
			}
		}
		else{
			if( parseInt(gotoNum) <=  parseInt(hadithCount))
			{
				var url = "/hadith/"+hdBook;
				var statusReq = UrlExists(gotoNum, url,"goto");
			}
			else{
				alert('Hadith does not exist');
			}
		}
	})
	//Hadith Volume changes
	$('#hd_volume').on('change', function() {
		var hdBook= $("#hadithlist").val();
		var hdVolume = $('#hd_volume').val();
		if( hdBook =="amh" || hdBook =="shb" || hdBook =="fqs")
		{
			var url = "/hadith/"+hdBook+"/"+hdVolume+"/1";
			location.replace(url); 
		}
	})
	// Next hadith navigation 
	$('#hadith-next').on('click', function() {
		var pathArray = window.location.pathname.split( '/' );
		var hdBook = pathArray[2];
		if(pathArray[4]){
			hadithNumber = pathArray[4];
			volumeNumber = pathArray[3];
		}
		else{
			hadithNumber = pathArray[3];
		}
		var hadithCount = $('#hadith-next').attr('rel');
		if((hdBook =="amh" || hdBook =="shb" || hdBook =="fqs") && volumeNumber )
		{
			var url = "/hadith/"+hdBook+"/"+volumeNumber;
		}
		else
		{
			var url = "/hadith/"+hdBook;
		}
		if((parseInt(hadithNumber)+1) <= parseInt(hadithCount))
			var statusReq = UrlExists(hadithNumber, url,"next");
		else
			alert("Reached End of hadith for the current Volume."); 
	})
	// Previous hadith navigation 
	$('#hadith-prev').on('click', function() {
		var pathArray = window.location.pathname.split( '/' );
		if(pathArray[4]){
			hadithNumber = pathArray[4];
			volumeNumber = pathArray[3];
		}
		else{
			hadithNumber = pathArray[3];
		}
		var hdBook = pathArray[2];
		var hadithCount = $('#hadith-next').attr('rel');
		if( (hdBook =="amh" || hdBook =="shb" || hdBook =="fqs") && volumeNumber)
		{
			var url = "/hadith/"+hdBook+"/"+volumeNumber;
		}
		else
		{
			var url = "/hadith/"+hdBook;
		}
		if(parseInt(hadithNumber)-1 > 0)
			var statusReq = UrlExists(hadithNumber, url,"prev");
		else
			alert("Reached beginning of hadith for the current Volume.")
	})

}
