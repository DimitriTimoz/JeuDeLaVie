program save&load;

//Sauvegarde//

var f : file of ^integer;
	i : ^integer;
	
	Begin
	
		assign(f,'Sauvegarde');
		rewrite(f);		
		
			new(i);
			i^:=1;
			repeat
			
				write(f,i);	
				i^:=i^+1;
				
			until not eof(f);
				
		close(f);
		  
	end;			
			
			
			
//Charger//
			
	begin
		reset(f);
			while not eof(f) do

				begin
					readln(f,i);
					showmessage(i);
				end;
				
		close(f);
	end;
