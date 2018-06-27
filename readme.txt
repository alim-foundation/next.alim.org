Content Types
==============

	archetypes/quran.md  // It is the content type for Quran
	archetypes/quran.md  // It is the content type for Hadith
	

Content
=======

content/quran/Surah  // Has the complete surah 
	Used /layouts/partials/surah.html to render the html content of .md file
	Since I could not make the drop down list selected with current Surah loaded using js (It wil have a jerking if it is added in the layout file) I have added it in the .md file itself and added "selected" by default.

content/quran/Ayah  // Designed to add all ayahs from each surah in separate folder (for Fathiha, Baqara etc.)
	Can use Section template and loop the folder to list each ayahs from the folder (https://gohugo.io/templates/section-templates/)

/data/quran  // Has the Complete Surah json files under each surahNo folder
	layouts/partials/quran.html // This will read Surah json file, but i could make it read by giving the json file name statically.

/static/js // Added js functions to manage navigations 


// Shahid's Note

Hugo data templates -> AJAX to read/write dynamically
Asia's current model


FUSE file system tied to the database during generation


content
  folder 1
     foler 2
        file 1.md 
        file 2.md 

data
   file.json
   file.csv


FUSE file system  -> SQL to generate the folder names, files, etc.

create a SQL -> FUSE file system layer
whatever files are needed can come dynamically from FUSE
	