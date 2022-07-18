Schema firstapp

Public Type
  tyCountry Record Like countries.*

Private Define
  isCursorOpen Boolean = False

Function readCountries( lr_country tyCountry InOut ) Returns Boolean
  If Not isCursorOpen Then
    Declare cCountries Cursor From "Select * From countries Order By country_name"
    Open cCountries
    Let isCursorOpen = True
  End If
  Fetch Next cCountries Into lr_country.*
  If Sqlca.sqlcode = NOTFOUND Then
    Let isCursorOpen = False
    Close cCountries
    Free cCountries
    Return False
  Else
    Return True
  End If
End Function
