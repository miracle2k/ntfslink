unit ntfslink_TLB;

// ************************************************************************ //
// WARNUNG                                                                    
// -------                                                                    
// Die in dieser Datei deklarierten Typen wurden aus Daten einer Typbibliothek
// generiert. Wenn diese Typbibliothek explizit oder indirekt (über eine     
// andere Typbibliothek) reimportiert wird oder wenn die Anweisung            
// 'Aktualisieren' im Typbibliotheks-Editor während des Bearbeitens der     
// Typbibliothek aktiviert ist, wird der Inhalt dieser Datei neu generiert und 
// alle manuell vorgenommenen Änderungen gehen verloren.                           
// ************************************************************************ //

// PASTLWTR : 1.2
// Datei generiert am 26.06.2004 20:05:00 aus der unten beschriebenen Typbibliothek.

// ************************************************************************  //
// Typbib: F:\Developing\Projects\NTFSLink\source\ntfslink.tlb (1)
// LIBID: {E709C2BC-CFB4-49EC-B985-2B1C40EAD54F}
// LCID: 0
// Hilfedatei: 
// Hilfe-String: ntfslink Bibliothek
// DepndLst: 
//   (1) v2.0 stdole, (C:\windows\System32\stdole2.tlb)
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit muß ohne Typüberprüfung für Zeiger compiliert werden. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
interface

uses Windows, ActiveX, Classes, Graphics, StdVCL, Variants;
  

// *********************************************************************//
// In dieser Typbibliothek deklarierte GUIDS . Es werden folgende         
// Präfixe verwendet:                                                     
//   Typbibliotheken     : LIBID_xxxx                                     
//   CoClasses           : CLASS_xxxx                                     
//   DISPInterfaces      : DIID_xxxx                                      
//   Nicht-DISP-Schnittstellen: IID_xxxx                                       
// *********************************************************************//
const
  // Haupt- und Nebenversionen der Typbibliothek
  ntfslinkMajorVersion = 1;
  ntfslinkMinorVersion = 0;

  LIBID_ntfslink: TGUID = '{E709C2BC-CFB4-49EC-B985-2B1C40EAD54F}';


implementation

uses ComObj;

end.
