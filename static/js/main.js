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
////////////////////////////////////////////////
///////Starts Alim Arabic Page Recitation///////
////////////////////////////////////////////////
var pathArray = window.location.pathname.split( '/' );
var playlistAudios = [];
var repeatAyah ;
var ayahFrom;
var ayahTo ; 
var repeatsurahByAya;  
var repeatSurah;
var repeatSurahCount = 1;
var currIndex;
var lastIndex;
var totalAyahNo;
var stops = 0;
var plays = false;
var paused = false;
var icecastSources =[];
var currentReciter;
var currentSurah = pathArray[3];
var currReciteAya;
function scrollToTop(item) {
    var selid = "ayah-text_"+item;
    var id =  "#"+selid;
    var position = $(id).position();    
    var window_height = $(window).height();
    var check_val = position.top;
    var windowscroll = getScrollXY();
    var curr_pos = parseInt(check_val)-parseInt(windowscroll);
    var gopos = parseInt(check_val)-150;
    var chkpos = parseInt(curr_pos)+100;
    var chkpos2 = parseInt(curr_pos)-100;
    if( (check_val > chkpos) || (window_height-chkpos <= 0) )
    {   
        $('html, body').animate({scrollTop:gopos},'slow');
    }
    else if(chkpos2<0)
    {
        window.scrollTo(0,gopos);
    }
}
function getScrollXY() {
    var scrOfX = 0, scrOfY = 0;
    if( typeof( window.pageYOffset ) == 'number' ) {
        scrOfY = window.pageYOffset;
        scrOfX = window.pageXOffset;
    } else if( document.body && ( document.body.scrollLeft || document.body.scrollTop ) ) {
        scrOfY = document.body.scrollTop;
        scrOfX = document.body.scrollLeft;
    } else if( document.documentElement && ( document.documentElement.scrollLeft || document.documentElement.scrollTop ) ) {
        scrOfY = document.documentElement.scrollTop;
        scrOfX = document.documentElement.scrollLeft;
    }
    return [scrOfY];
}
$(document).ready(function() { 
    function validateFrom() {
        if(document.getElementById("From").value<1) {
            alert("Please enter a value greater than 0");
            document.getElementById("From").value = 1;
        } else if(isNaN(document.getElementById("From").value)) {
            alert("Characters are not allowed");
            document.getElementById("From").value = 1;
        } else if(isFloat(document.getElementById("From").value)) {
            alert("Invalid Data! Only Integer values are allowed");
            document.getElementById("From").value = 1;
        } else if(parseInt(document.getElementById("From").value)>totalAyahNo) {        
            alert("Please enter a valid from value");
            document.getElementById("From").value = 1;
        }
    }
    function validateTo() {
        if(document.getElementById("To").value>totalAyahNo || document.getElementById("To").value < 1 ) {
            alert("Please give an appropriate value for 'To'");
            document.getElementById("To").value = totalAyahNo;
        } else if(parseInt(document.getElementById("From").value) > parseInt(document.getElementById("To").value)) {
            alert("From value cannot be greater the To value");
            document.getElementById("To").value = totalAyahNo;
        } else if(isNaN(document.getElementById("To").value)) {
            alert("Invalid 'To' Value");
            document.getElementById("To").value = 1;
        }else if(isFloat(document.getElementById("To").value)) {
            alert("Invalid Data! Only Integer values are allowed");
            document.getElementById("To").value = totalAyahNo;
        }
    }
    function validateRepeat(type) {
        if(type == 1) {
            if(document.getElementById("repeatSurah").value<1) {
                alert("Please enter a value greater than 0");
                document.getElementById("repeatSurah").value = 1;
            } else if (document.getElementById("repeatSurah").value>99) {
                alert("Please enter a maximum value of 99");
                document.getElementById("repeatSurah").value = 1;
            } else if(isNaN(document.getElementById("repeatSurah").value)) {
                alert("Invalid Value! Characters are not allowed");
                document.getElementById("repeatSurah").value = 1;
            }else if(isFloat(document.getElementById("repeatSurah").value)) {
                alert("Invalid Data! Only Integer values are allowed");
                document.getElementById("repeatSurah").value = 1;
            }
        } else if(type == 2) {
            if(document.getElementById("repeatAyah").value<1) {
                alert("Please enter a value greater than 0");
                document.getElementById("repeatAyah").value = 1;
            } else if (document.getElementById("repeatAyah").value>99) {
                alert("Please enter a maximum value of 99");
                document.getElementById("repeatAyah").value = 1;
            } else if(isNaN(document.getElementById("repeatAyah").value)) {
                alert("Invalid Value! Characters are not allowed");
                document.getElementById("repeatAyah").value = 1;
            } else if(isFloat(document.getElementById("repeatAyah").value)) {
                alert("Invalid Data! Only Integer values are allowed");
                document.getElementById("repeatAyah").value = 1;
            }
        } else if(type == 3) {
            if(document.getElementById("repeatsurahByAya").value<1) {
                alert("Please enter a value greater than 0");
                document.getElementById("repeatsurahByAya").value = 1;
            } else if (document.getElementById("repeatsurahByAya").value>99) {
                alert("Please enter a maximum value of 99");
                document.getElementById("repeatsurahByAya").value = 1;
            } else if(isNaN(document.getElementById("repeatsurahByAya").value)) {
                alert("Invalid Value! Characters are not allowed");
                document.getElementById("repeatsurahByAya").value = 1;
            } else if(isFloat(document.getElementById("repeatsurahByAya").value)) {
                alert("Invalid Data! Only Integer values are allowed");
                document.getElementById("repeatsurahByAya").value = 1;
            }
        }
    }
    // Called when the surah/ ayah repetition radio chosen
    function activateFields(type) {
        if(type == 1) {
            document.getElementById('repeatSurah').disabled = false;                    
            document.getElementById("repeatAyah").setAttribute("disabled", true);
            document.getElementById("repeatsurahByAya").setAttribute("disabled", true);
            document.getElementById("From").setAttribute("disabled", true);
            document.getElementById("To").setAttribute("disabled", true);
        } else if(type == 2) {
            document.getElementById("repeatSurah").setAttribute("disabled", true);
            document.getElementById("repeatAyah").disabled=false;
            document.getElementById("repeatsurahByAya").disabled=false;
            document.getElementById("From").disabled=false;
            document.getElementById("To").disabled=false;
        }
    }
    //Called when the reciter changed..It loads the new playlist with the selected reciter ..
    function newreciter()
    {
        stop_player();  
        getPlayListBySurah();   
    }
    function getPlayListBySurah() {
        var pathArray = window.location.pathname.split( '/' );
        var surahNumer = pathArray[3];
        var left_url = "http://www.alim.org/sites/all/themes/alim/alimplayer_surah//arabic/"+surahNumer+"/";
        var right_url = ".txt";
        currentReciter = document.getElementById("reciter_list").value; 
        filePath = left_url+currentReciter+right_url;
        xmlhttp = new XMLHttpRequest();
        xmlhttp.open("GET",filePath,false);
        xmlhttp.send(null);
        icecastSources = eval(xmlhttp.responseText);  
        if(currentSurah == 1 || currentSurah == 9)     
        totalAyahNo = icecastSources.length;
        else 
        totalAyahNo = parseInt(icecastSources.length)-1;  
        document.getElementById("To").value = totalAyahNo;
        document.getElementById("From").value = 1;
    }
    //Assigning the playlist to Flow Player and its state change functions 
    getPlayListBySurah();
        apis = flowplayer("#icecast", {
        live: true,
        splash: true,
        audioOnly: true,     
        playlist: icecastSources
    }).on("ready error", function (e, api, arg) {      
        currIndex = arg.index;
        lastIndex = arg.is_last;
        var indx ="";
        if(currentSurah==1 || currentSurah==9) {
            indx = parseInt(arg.title); 
        } else {
            indx = parseInt(arg.title)-1;   
        }   
        currReciteAya = indx;
        document.getElementById("curraya").innerHTML = currReciteAya;
        var selid = "ayah-text_"+indx;
        if ($("#"+selid).length) {  
            $(".selectaudio").css("background-color","#fff");
            document.getElementById(selid).style.backgroundColor =  "#fdf6da";
            $(".selectaudio").removeClass('selected_row');
            $("#"+selid).addClass('selected_row');
            scrollToTop(indx); 
        }
    }).on("finish", function (e, api)  {
        if(surahOrAyah == 2) {
            if(lastIndex) {
                $(".selectaudio").css("background-color","#fff")
                $(".selectaudio").removeClass('selected_row');              
                stop();
            }
        }
        if(surahOrAyah == 1) {
            if(currIndex == icecastSources.length - 1) {         
                if(repeatSurahCount == repeatSurah) {
                    $(".selectaudio").css("background-color","#fff")
                    $(".selectaudio").removeClass('selected_row');               
                    stop();
                } else {              
                    repeatSurahCount++;
                    api.play(0);
                }           
            }
        }
    }).on("progress", function (e, api, arg)  { 	
        $(".selected_row").css("background-color","#fdf6da")	  
        if(stops == 1) {
            stops=0;   
            api.unload();      
        }
    }).on("pause", function (e, api)  {
        $(".selectaudio").removeClass('selected_row');
        paused = true;
        $("#playdiv").css('display','block');
        $("#pause_btn").css('display','none');
    }).on("resume", function (e, api)  {
        $("#playdiv").css('display','none');
        $("#pause_btn").css('display','block');
        paused = false;
    });
    if ($(".fp-play").length) {  
        $(".fp-mute").attr('title', 'Mute');   
        $(".fp-volumeslider").attr('title', 'Volume');
        $(".fp-ui").attr('title', '');  
        $('<div class="flowplayer-icon-stop" onClick="stop_player();" title="Stop"><i class="fa fa-stop" aria-hidden="true"></i></div>').insertAfter('.fp-play');
        $('<div class="fp-next" onClick="nextAudio();" title="Next"><i class="fa fa-step-forward" aria-hidden="true"></i></div>').insertAfter('.fp-play');
        $('<div class="fp-previous" onClick="previousAudio();" title="Previous"><i class="fa fa-step-backward" aria-hidden="true"></i></div>').insertAfter('.fp-play');
    }
    $(".fp-play").click(function(){  
        if(plays == false) {
            play();
        }   
    })
    $('.fp-controls').bind('contextmenu', function(e) {
        return false;
    }); 
    $('#reciter_list').on('change', function() {
        newreciter();
    })
    $('#From').on('blur', function() {
        validateFrom();
    })
    $('#To').on('blur', function() {
        validateTo();
    })
    $('#surahOrAyah2').on('change', function() {
        activateFields(2);
    })
    $('#surahOrAyah1').on('change', function() {
        activateFields(1);
    })
    $('#repeatSurah').on('blur', function() {
        validateRepeat(1)
    })
    $('#repeatAyah').on('blur', function() {
        validateRepeat(2)
    })
    $('#repeatsurahByAya').on('blur', function() {
        validateRepeat(3);
    })
    function isFloat(num) {  
        if((num % 1) !== 0) {
            return true;
        } else {
            return false;
        }
    }
});
function stop_player() {
    paused = false;
    $(".selected_row").css("background-color","#fff")
    $(".selectaudio").removeClass('selected_row');
    apis.stop();  
    stop();
}
function pause_player() {
    apis.pause();  
}
function resume_player() {
    apis.resume();  
}
function play() {
    plays = true;
    stops = 0;
    surahOrAyah = document.querySelector('input[name = "surahOrAyah"]:checked').value; 
    if(surahOrAyah == 1) {
        playlistAudios = [];
        repeatSurah = document.getElementById("repeatSurah").value;
        if(icecastSources){  
            for (i = 0; i < icecastSources.length; i += 1) {      
                playlistAudios.push(icecastSources[i]);  
            }   
        }  
        scrollToTop(playlistAudios[0].sources[0].title);  
        apis.setPlaylist(playlistAudios);
        apis.play(0);
    } else if(surahOrAyah == 2) {  
        repeatAyah = document.getElementById("repeatAyah").value;
        if(currentSurah ==1 || currentSurah ==9) {
            ayahFrom = parseInt(document.getElementById("From").value)-1;
            ayahTo = parseInt(document.getElementById("To").value)-1;
        } else {
            ayahFrom = parseInt(document.getElementById("From").value);
            ayahTo = parseInt(document.getElementById("To").value);
        }
        repeatsurahByAya = parseInt(document.getElementById("repeatsurahByAya").value);  
        refreshPlaylist(ayahFrom,ayahTo,repeatAyah,repeatsurahByAya); 
    }
}
var refreshPlaylist = function(from,to,repeatAyah,repeatSurah) {
    apis.unload();
    playlistAudios = [];
    var m;
    var j;
    var k=0;
    do {    
    for (m = from; m <= to; m += 1) {
    for(j = 0;j<repeatAyah ; j+=1)
    playlistAudios.push(icecastSources[m]);  
    }
    k++;      
    }  while(k<repeatSurah);
    var position = (playlistAudios[0].sources[0].title-1)?playlistAudios[0].sources[0].title-1:playlistAudios[0].sources[0].title;
    scrollToTop(position); 
    apis.setPlaylist(playlistAudios);  
    apis.play(0);
};

function stop() { 
    paused = false;
    stops =1;
    plays = false;
    var playlistAudios = [];
    var repeatAyah ;
    var ayahFrom;
    var ayahTo ; 
    var repeatsurahByAya;  
    var repeatSurah;
    var repeatSurahCount = 1;
    var currIndex;  
    if(paused == true ) {
        stops=0;   
        paused = false; 
        plays = false;   
        apis.unload();  
    }
    document.getElementById("repeatSurah").value = 1;
    document.getElementById("repeatAyah").value = 1;
    document.getElementById("From").value =1;
    ayahCount = totalAyahNo;
    document.getElementById("To").value = ayahCount;  
    document.getElementById("repeatsurahByAya").value = 1;
    //document.getElementById("surahOrAyah1").checked = true;
    $("#surahOrAyah1").trigger("click");
    document.getElementById("curraya").innerHTML = 1; 
}
function nextAudio() { 
    apis.next();
}
function previousAudio() { 
    apis.prev();
}
////////////////////////////////////////////////
///////Ends Alim Arabic Page Recitation/////////
////////////////////////////////////////////////