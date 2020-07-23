#!/usr/bin/env bash

fileScholar=$(ls scholar_URLs.txt)
pathScholar=$(find Scholar)


#If it doesnt have scholar_URLs.txt the program stops
if [[ $fileScholar = "" ]];
then
	echo '[ERRO] Não foi possivel encontrar 'scholar_URLs.txt''
	exit
fi
#google_scholar.sh -i
if [[ $1 = "-i" ]];
then
	#If it doesnt have Scholar directory it creates one
	if [[ $pathScholar = "" ]];
	then
		echo 'Criando a pasta Scholar...'
		mkdir Scholar
	fi


 	   for i in 1 2 3 4
		do
		#Ignores the lines that starts with an "#"
		[ "${i:0:1}" = "#" ] && continue
  		 
  		 URLgeneral=`grep ^h "$fileScholar" | cut -d'|' -f 1 | head -n "$i" | tail -n 1`
  		 HTMLgeneral=`grep ^h "$fileScholar" | cut -d'|' -f 2 | head -n "$i" | tail -n 1`
  			
  	   #copy all the content from the pages to a .html file		
       curl -ks  "$URLgeneral" >$HTMLgeneral

       #Save on variables the especific content
  	   totalCitations=`curl -ks  "$URLgeneral" | tail -n 1 | cut -c 18262-18268 | cut -d'>' -f 2 | cut -d'<' -f 1`
  	   totalCitationsLast5Years=`curl -ks  "$URLgeneral" | tail -n 1 | cut -c 18285-18320 | cut -d'>' -f 2 | cut -d'<' -f 1`
       hindex=`curl -ks  "$URLgeneral" | tail -n 1 | cut -c 18695-18720 | cut -d'>' -f 2 | cut -d'<' -f 1`
  	   hindexLast5Years=`curl -ks  "$URLgeneral" | tail -n 1 | cut -c 18735-18798 | cut -d'>' -f 2 | cut -d'<' -f 1`
       name=`curl -ks  "$URLgeneral" | head -n 1 | cut -c 30-70 | cut -d'>' -f 2 | cut -d'-' -f 1 | tr -d ' '`
       #[EXTRA] it show the file bytes using du command
       tamanho=`du -b "$HTMLgeneral" | cut -f 1`
       
       
       #It shows the following content: Total citações | Total citacoes ultimos 5 anos | h-index | h-index ultimos 5 anos 
       echo '------------------------------------------------------------------------------'
 	   echo '[A processar]:'  $URLgeneral
	   echo '[INFO] A utilizer o ficheiro local  '
       echo 'Scholar: '$HTMLgeneral
       #[EXTRA] it show the file bytes using du command
       echo 'name': $name
       echo 'tamanho: '$tamanho '(bytes)'
       echo 'Citacoes - Total:' $totalCitations 'ultimos 5 anos:' $totalCitationsLast5Years
       echo 'H-Index - Total:' $hindex ', ultimos 5 anos: '$hindexLast5Years
	   
	   #move the *.html to Scholar directory
       mv "$HTMLgeneral" Scholar


       #Writing to .db   
       echo '# Ficheiro: ' $name'.db'>"$name".db
       echo '# Info Scholar: ' $name >>"$name".db
       echo '# Criado em: '$(date "+%Y.%m.%d_%Hh%M:%S") >>"$name".db
       echo '#:Citacoes:h-index:h-index_5anos' >>"$name".db
       echo $(date "+%Y.%m.%d")':'$totalCitations':'$hindex':'$hindexLast5Years >>"$name".db
       echo '# Ultima atualizacao: '$(date "+%Y.%m.%d_%Hh%M:%S" -r "$name".db) >>"$name".db
       
       #moving *.db to Scholar
       mv "$name".db Scholar

	done < $fileScholar
			
fi
#google_scholar.sh
if [[ $1 = "" ]];
then 
	   
 	   for i in 1 2 3 4
		do
		[ "${i:0:1}" = "#" ] && continue
  		 
  		 #it saves all *.html names from scholar_URLs.txt to another txt
  		 grep ^h "$fileScholar" | cut -d'|' -f 2 | head -n "$i" | tail -n 1 >> listHTMLS.txt 
  		
  		  
  		done < $fileScholar
		
		#move the list to Scholar
		mv listHTMLS.txt Scholar
		
		#change directory
		cd Scholar

  		#it saves all *.html inside Scholar directory to a txt
		
		find *.html > listHTMLSScholar.txt

		while read FILENAME
		do
			

			if grep -Fxq "$FILENAME" listHTMLSScholar.txt
			then
				#In case the program finds *.html

			   totalCitations=`cat "$FILENAME" | sed '1, 60d' | cut -c 18262-18266 | cut -d'>' -f 2 | cut -d'<' -f 1`
			   totalCitationsLast5Years=`cat "$FILENAME" | sed '1, 60d' | cut -c 18285-18320 | cut -d'>' -f 2 | cut -d'<' -f 1`
      		   hindex=`cat "$FILENAME" | sed '1, 60d' | cut -c 18695-18720 | cut -d'>' -f 2 | cut -d'<' -f 1`
  	   		   hindexLast5Years=`cat "$FILENAME" | sed '1, 60d' | cut -c 18735-18798 | cut -d'>' -f 2 | cut -d'<' -f 1`
       		   name=`cat "$FILENAME" | head -n 1 | tr -d ' ' | cut -c 30-70 | cut -d'>' -f 2 | cut -d'-' -f 1 | tr -d ' '`
       		   

			   #It shows all the especific content: Total citações | Total citacoes ultimos 5 anos | h-index | h-index ultimos 5 anos 
		       echo '------------------------------------------------------------------------------'
		 	   echo '[A processar]:'  $name
			   echo '[INFO] A utilizer o ficheiro local  '
		       echo 'Scholar: ' "$FILENAME"
		       echo 'Citacoes - Total:' $totalCitations 'ultimos 5 anos:' $totalCitationsLast5Years
		       echo 'H-Index - Total:' $hindex ', ultimos 5 anos: '$hindexLast5Years

			    continue;
			else
				echo '------------------------------------------------------------------------------'
			    echo '[ERRO] Não foi possível encontrar o ficheiro' $FILENAME 
			fi
			 

		done < listHTMLS.txt


rm *.txt
	

fi

if [[ $1 = "-h" ]];
then
	echo '-h: Mostra ajuda'
	echo '-i: Descarrega e analisa a página de cada perfil'
	echo '[NOTA]: Se não colocar nenhuma das opções acima, procura se existe ficheiro HTML na pasta Scholar'
fi

if [[ $1 != "-h" ]] && [[ $1 != "-i" ]] && [[ $1 != "" ]];
then
	echo '[ERRO] Parâmetro(s) não suportado(s)!'
fi