#! /usr/bin/perl

#Primero el directorio y luego el fichero de paginas y luego fichero de 
#datos

  


  opendir ($DIR,$ARGV[0]) || die "No se puede abrir $ARGV[0]\n" ;
  @files=readdir($DIR);
  closedir($DIR);
  
  open ($OUT,">$ARGV[1]") || die "No se puede abrir $ARGV[1]\n" ;
  binmode $OUT;

  open ($LIST,">$ARGV[2]") || die "No se puede abrir $ARGV[2]\n";
 
  shift(@files);
  shift(@files);
  $cont=0;
  $npag=0;
  foreach $file (@files)
   {
   print "Fichero=$file\n";
   open($DATA,"$ARGV[0]/$file") || die "No se puede abrir el fichero d\n";
   binmode $DATA;
   $size=-s "$ARGV[0]/$file";
   
   if ($cont + $size  > 8*1024)
     {
     print "Escribiendo una pagina con tamaño $cont\n";
     $buf=pack a8192,$buffer;     
     syswrite($OUT,$buf,8*1024);
     $cont=0;
     $npag++;
     }
   
   $nfile=expfname($file);
   print $LIST "\tdb 0,$file,$npag,$cont\n";
      
   read ($DATA,$buffer,$size,$cont); 
   $cont+=$size;
   close($DATA);
   }
   

 $buf=pack a8192,$buffer;
 syswrite($OUT,$buf,8*1024);
	   
 close ($OUT);
 close ($LIST); 



sub expfname
 {
 return $_;
 }

  
  
  

