program tests;

uses FileUtil;

var 
 PascalFiles: TStringList;

begin
  //No need to create the stringlist; the function does that for you
  PascalFiles := FindAllFiles(LazarusDirectory, '*.save', true); 
  try
    ShowMessage(Format('Found %d Pascal source files', [PascalFiles.Count]));
  finally
    PascalFiles.Free;
  
end.
