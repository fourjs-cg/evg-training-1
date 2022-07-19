Import FGL sqlCountries

Schema firstapp

Function listCountries()
  Define
    la_countries Dynamic Array Of sqlCountries.tyCountry,
    lr_country sqlCountries.tyCountry

  Open Window wCountries With Form "countriesList" Attributes (Style="main2")

    Let Int_Flag = False
    Display Array la_countries To sr_country.* Attributes (Unbuffered, Count=la_countries.getLength())
      Before Display
        While sqlCountries.readCountries( lr_country, Null )
          Call la_countries.appendElement()
          Let la_countries[la_countries.getLength()].* = lr_country.*
        End While

      On Action Search
        If searchCountries( la_countries ) Then
        End If

  -- Actions: Add Update Delete
      On Append
        Let Int_Flag = Not inputCountry( la_countries[Arr_Curr()], True )

      On Insert
        Let Int_Flag = Not inputCountry( la_countries[Arr_Curr()], True )

      On Update
        If inputCountry( la_countries[Arr_Curr()], False ) Then End If

      On Delete
        Let Int_Flag = Not sqlCountries.removeCountry( la_countries[Dialog.getCurrentRow("sr_country")].country_id, False )

    End Display

    If Int_Flag Then
      Let lr_country.country_id = -1
    Else
      Let lr_country.country_id = la_countries[ARR_CURR()].country_id
    End If

  Close Window wCountries

  Return lr_country.country_id
End Function

Function inputCountry( lr_country sqlCountries.tyCountry InOut, isNew Boolean )
  Define
    oldCountry sqlCountries.tyCountry,
    isOk Boolean = True

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
  Return isOk
End Function

Function searchCountries( la_countries Dynamic Array Of sqlCountries.tyCountry )
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