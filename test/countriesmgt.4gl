Import FGL sqlCountries

Schema firstapp

Type
  tyFunctionCallBack Function( la_countries Dynamic Array Of sqlCountries.tyCountry, CurLine Integer, isNew Boolean ) Returns Boolean

Function listCountries()
  Define
    fields        Dynamic Array of Record
      name          String,
      type          String
                  End Record,
    actList       Dictionary Of Record
      funcName      tyFunctionCallBack
                  End Record,
    dydi          ui.Dialog,
    i             Integer,
    act           String,
    la_countries Dynamic Array Of sqlCountries.tyCountry,
    lr_country sqlCountries.tyCountry

  Open Window wCountries With Form "countriesList" Attributes (Style="main2")

    Let fields[1].name = "countries.country_id"
    Let fields[1].type = "INTEGER"
    Let fields[2].name = "countries.country_name"
    Let fields[2].type = "VARCHAR(100)"
    Let dydi = ui.Dialog.createDisplayArrayTo(fields,"sr_country")
    Call dydi.addTrigger("ON ACTION search")
    Call dydi.addTrigger("ON APPEND")
    Call dydi.addTrigger("ON INSERT")
    Call dydi.addTrigger("ON UPDATE")
    Call dydi.addTrigger("ON DELETE")
    Call dydi.addTrigger("ON ACTION close")
    Call dydi.addTrigger("ON ACTION accept")
    Call dydi.addTrigger("ON ACTION cancel")

    Let actList["ON ACTION search"].funcName = Function searchCountries
    Let actList["ON APPEND"].funcName = Function inputcountry
    Let actList["ON INSERT"].funcName = Function inputCountry
    Let actList["ON UPDATE"].funcName = Function inputCountry
    Let actList["ON DELETE"].funcName = Function delCountry

    While sqlCountries.readCountries( lr_country, Null )
      Call la_countries.appendElement()
      Let la_countries[la_countries.getLength()].* = lr_country.*
    End While

    Call dydi.setCurrentRow("sr_country",1)
    For i=1 To la_countries.getLength()
      Call dydi.setCurrentRow("sr_country",i)
      Call dydi.setFieldValue(fields[1].name,la_countries[i].country_id)
      Call dydi.setFieldValue(fields[2].name,la_countries[i].country_name)
    End For

    Call dydi.setCurrentRow("sr_country",1)
    While (act:=dydi.nextEvent()) Is Not Null
      If actList.contains(act) Then
        Let int_flag = actList[act].funcName(la_countries,Dydi.getCurrentRow("sr_country"),Iif(act.getIndexOf("UPDATE",1)>0,True,False))
      End If
      If act = "ON ACTION close" Then
        Let int_flag = True
        Exit While
      End If
      If act = "ON ACTION accept" Then
        Let int_flag = False
        Exit While
      End If
      If act = "ON ACTION cancel" Then
        Let int_flag = True
        Exit While
      End If
      --Case act
      --  When "ON ACTION close"
      --    Exit While
      --  When "ON DELETE"
      --    Let Int_Flag = Not sqlCountries.removeCountry( la_countries[Dydi.getCurrentRow("sr_country")].country_id, False )
      --  When "ON ACTION search"
--        If searchCountries( la_countries, Null, Null ) Then
--        End If
      --  When "ON APPEND"
--        Let Int_Flag = Not inputCountry( la_countries, Arr_Curr(), True )
      --  When "ON INSERT"
--        Let Int_Flag = Not inputCountry( la_countries, Arr_Curr(), True )
      --  When "ON UPDATE"
--        If inputCountry( la_countries, Arr_Curr(), False ) Then End If
      --End Case
    End While
    Call dydi.close()
    Let dydi = Null

--    Let Int_Flag = False
--    Display Array la_countries To sr_country.* Attributes (Unbuffered, Count=la_countries.getLength())
--      Before Display
--        While sqlCountries.readCountries( lr_country, Null )
--          Call la_countries.appendElement()
--          Let la_countries[la_countries.getLength()].* = lr_country.*
--        End While
--
--      On Action Search
--        If searchCountries( la_countries, Null, Null ) Then
--        End If
--
--  -- Actions: Add Update Delete
--      On Append
--        Let Int_Flag = Not inputCountry( la_countries, Arr_Curr(), True )
--
--      On Insert
--        Let Int_Flag = Not inputCountry( la_countries, Arr_Curr(), True )
--
--      On Update
--        If inputCountry( la_countries, Arr_Curr(), False ) Then End If
--
--      On Delete
--        Let Int_Flag = Not sqlCountries.removeCountry( la_countries[Dialog.getCurrentRow("sr_country")].country_id, False )
--
--    End Display

    If Int_Flag Then
      Let lr_country.country_id = -1
    Else
      Let lr_country.country_id = la_countries[ARR_CURR()].country_id
    End If

  Close Window wCountries

  Return lr_country.country_id
End Function

Function delCountry( la_countries Dynamic Array Of sqlCountries.tyCountry, CurLine Integer, isNew Boolean ) Returns Boolean
  Return Not sqlCountries.removeCountry( la_countries[CurLine].country_id, False )
End Function

Function inputCountry( la_countries Dynamic Array Of sqlCountries.tyCountry, CurLine Integer, isNew Boolean ) Returns Boolean
  Define
    oldCountry sqlCountries.tyCountry,
    lr_country sqlCountries.tyCountry,
    isOk Boolean = True

  Let lr_country = la_countries[CurLine]
  Open Window wCountry With Form "countryForm"

    Let Int_Flag = False
    Let oldCountry = lr_country
    Input By Name lr_country.* Attributes (Without Defaults= Not isNew )

    If int_flag Then
      Let lr_country = oldCountry
      Let isOk = False
    Else
      If IsNew Then
        If Not sqlCountries.insertCountry( lr_country.* ) Then
          Let lr_country = oldCountry
          Let isOk = False
        End If
      Else
        If Not sqlCountries.updateCountry( lr_country.* ) Then
          Let lr_country = oldCountry
          Let isOk = False
        End If
      End If
    End If

  Close Window wCountry
  Let la_countries[CurLine] = lr_country
  Return isOk
End Function

Function searchCountries( la_countries Dynamic Array Of sqlCountries.tyCountry, CurLine Integer, isNew Boolean ) Returns Boolean
  Define
    lr_country sqlCountries.tyCountry,
    wcl String,
    isOk Boolean = True

  Open Window wCountry With Form "countryForm"

    Let Int_Flag = False
    Construct By Name wcl On countries.*

    If Not Int_Flag Then
      Call la_countries.clear()
      While sqlCountries.readCountries( lr_country, wcl )
        Call la_countries.appendElement()
        Let la_countries[la_countries.getLength()].* = lr_country.*
      End While
    End If

  Close Window wCountry
  Return isOk
End Function

Function main()
End Function