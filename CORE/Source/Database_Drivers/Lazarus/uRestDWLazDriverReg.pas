unit uRestDWLazDriverReg;

interface

uses
 LResources, Classes, propedits, uRestDWLazDriver;

Procedure Register;

implementation

Procedure Register;
Begin
 RegisterComponents('REST Dataware - Drivers', [TRESTDWLazDriver]);
End;

initialization
{$I restdwlazdriver.lrs}

end.
