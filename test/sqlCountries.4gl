Import FGL utilities

Schema firstapp

Public Type
  tyCountry Record Like countries.*

Private Define
  isCursorOpen Boolean = False

Function readCountries( lr_country tyCountry InOut, wcl String ) Returns Boolean
  Define
    qry String

  If Not isCursorOpen Then
    Let qry = "Select * From countries"
    --If wcl Is Null Then
    --  Let qry = qry," Order By country_name"
    --  Let qry = qry.append(" Order By country_name")
    --Else
    --  Let qry = qry," Where ",wcl," Order By country_name"
    --End If
    Let qry = qry," Where "||wcl," Order By country_name"
    Declare cCountries Cursor From qry
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

Function insertCountry( lr_Country tyCountry )
  Define
    isOk Boolean = True

  Try
    Insert Into countries
    Values ( lr_country.* )
  Catch
    Error "Add country error: ",Sqlca.sqlcode," ",SqlErrMessage
    Let isOk = False
  End Try

  Return isOk
End Function

Function updateCountry( lr_Country tyCountry )
  Define
    isOk Boolean = True

  Try
    Update countries
     Set country_name = lr_Country.country_name
    Where countries.country_id = lr_Country.country_id
  Catch
    Error "Add country error: ",Sqlca.sqlcode," ",SqlErrMessage
    Let isOk = False
  End Try

  Return isOk
End Function

Function removeCountry( li_countryId Like countries.country_id, requiresValidation Boolean )
  Define
    isOk Boolean = True

  If requiresValidation Then
    Let isOk = utilities.askHim("Delete","question","Are you sure?",
               '[{"btName":"yes","btLabel":"Yes","btActive":true,"btHidden":false,"btAnswer":"1"},{"btName":"no","btLabel":"No","btActive":true,"btHidden":false,"btAnswer":"0"}]')
  End If
  If isOk Then
    Try
      Delete From countries
       Where country_id = li_countryId
      If Sqlca.sqlcode <> 0 Then
        Error "Country was not deleted: ",Sqlca.sqlcode," ",SqlErrMessage
        Let isOk = False
      End If
    Catch
      Error "Delete country error: ",Sqlca.sqlcode," ",SqlErrMessage
      Let isOk = False
    End Try
  End If

  Return isOk
End Function