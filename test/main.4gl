Import FGL mySqlUtilities
Import FGL sqlCustomers
Import FGL sqlPlates
Import FGL sqlCountries
Import FGL countriesmgt
Import FGL utilities
Import util

Schema firstapp
--Database firstapp

Main
  Define
    wId ui.Window

  Call startlog("firstapp.log")

  Call ui.Interface.loadStyles("mystyle")
  Call createDB()

  Open Form f1 From "ftest"
  Display Form f1

    Let wId = ui.Window.getCurrent()
    If base.Application.getArgumentCount() > 0 Then
      Call wId.setText(base.Application.getArgument(1))
    Else
      Call wId.setText("Customers")
    End If

    Call browseCustomers()

  Close Form f1

  Disconnect All
End Main

Function browseCustomers()
  Define
    qry String,
    nbl Integer

  Call sqlCustomers.setQry("Select * From customers Order By customer_id")
  Call initPlates(Null,Null,Null)

  Let nbl = mySqlUtilities.countLines("customers", Null)
  Call navigateCustomers( nbl )

  Call sqlCustomers.closeCustomers(True)
End Function

Function navigateCustomers( nbl Integer )
  Define
    lr_customer tyCustomer,
    lr_oldCustomer tyCustomer,
    li_countryId Like countries.country_id,
    la_plates Dynamic Array Of sqlPlates.tyNamedCustPlate,
    curl Integer,
    curCust Integer,
    cntPlate Integer = 0,
    hasChanged Boolean,
    inputMode Char(1),
    fId ui.Form,
    isShown Boolean = False

  If nbl < 0 Then
    Error "Something went wrong"
  End If

  Dialog Attributes (unbuffered)
    Input By Name lr_customer.* Attributes (Without Defaults)
      Before Input
        Let inputMode = IIF(nbl>1,"U","I")
        Let hasChanged = False
        Call readCustomer(lr_customer, "first", False) Returning lr_oldCustomer.*
        Let curCust = 1
        Let curl = mgtActions(DIALOG,1,nbl)
        Call Dialog.setArrayLength("sr_plate",countLines("custplates","customer_id = "||lr_customer.customer_id))
        Call Dialog.setActionActive("save",false)

      On Change customer_name, join_date, customer_country
        Call Dialog.setActionActive("save",true)
        Let hasChanged = True
        If lr_oldCustomer.* = lr_customer.* Then
          Call Dialog.setActionActive("save",False)
          Let hasChanged = False
        End If

      On Action first
        Let hasChanged = sqlCustomers.updateCustomer( hasChanged, True, lr_customer, lr_oldCustomer.* )
        Call readCustomer(lr_customer, "first", False)  Returning lr_oldCustomer.*
        Call Dialog.setArrayLength("sr_plate",countLines("custplates","customer_id = "||lr_customer.customer_id))
        Call Dialog.setActionActive("save",false)
        Let curCust = mgtActions(DIALOG,1,nbl)

      On Action previous
        Let hasChanged = sqlCustomers.updateCustomer( hasChanged, True, lr_customer, lr_oldCustomer.* )
        Call readCustomer(lr_customer, "previous", False) Returning lr_oldCustomer.*
        Call Dialog.setArrayLength("sr_plate",countLines("custplates","customer_id = "||lr_customer.customer_id))
        Call Dialog.setActionActive("save",false)
        Let curCust = mgtActions(DIALOG,curCust - 1,nbl)

      On Action next
        Let hasChanged = sqlCustomers.updateCustomer( hasChanged, True, lr_customer, lr_oldCustomer.* )
        Call readCustomer(lr_customer, "next", False)  Returning lr_oldCustomer.*
        Call Dialog.setActionActive("save",false)
        Call Dialog.setArrayLength("sr_plate",countLines("custplates","customer_id = "||lr_customer.customer_id))
        Let curCust = mgtActions(DIALOG,curCust + 1,nbl)

      On Action last
        Let hasChanged = sqlCustomers.updateCustomer( hasChanged, True, lr_customer, lr_oldCustomer.* )
        Call readCustomer(lr_customer, "last", False) Returning lr_oldCustomer.*
        Call Dialog.setActionActive("save",false)
        Call Dialog.setArrayLength("sr_plate",countLines("custplates","customer_id = "||lr_customer.customer_id))
        Let curCust = mgtActions(DIALOG,nbl,nbl)

      On Action save
        Let hasChanged = sqlCustomers.updateCustomer( hasChanged, False, lr_customer, lr_oldCustomer.* )
        If hasChanged Then
          Call readCustomer(lr_customer, curCust, False) Returning lr_oldCustomer.*
          Let hasChanged = False
        End If
        Call Dialog.setActionActive("save",false)

      On Action revert
        Let lr_customer = lr_oldCustomer
        Call Dialog.setActionActive("save",False)
        Let hasChanged = False

      On Action refresh
        Call readCustomer(lr_customer, curCust, True) Returning lr_oldCustomer.*
        Call Dialog.setActionActive("save",true)
        Let hasChanged = True
        If lr_oldCustomer.* = lr_customer.* Then
          Call Dialog.setActionActive("save",False)
          Let hasChanged = False
        End If

      On Action delete
        If sqlCustomers.deleteCustomer(lr_customer.customer_id) Then
          Let nbl = mySqlUtilities.countLines("customers", Null)
          If curCust > nbl Then Let curCust = nbl End If
          Call readCustomer(lr_customer, curCust, True) Returning lr_oldCustomer.*
          Let curCust = mgtActions(DIALOG,curCust,nbl)
        End If
    End Input

    Display Array la_plates To sr_plate.* Attributes (count=cntPlate)
      On Fill Buffer
        Call la_plates.clear()
        Call sqlPlates.fillPlates( lr_customer.customer_id, la_plates, fgl_dialog_getbufferstart(), fgl_dialog_getbufferlength() )

      On Sort
        Call sqlPlates.endPlates()
        Call sqlPlates.initPlates(Null,Dialog.getSortKey("sr_plate"),Dialog.isSortReverse("sr_plate"))

      On Append
        Let int_flag = False
        Call inputPlate(Dialog, la_plates, False)
        If Not Int_Flag Then
          Let Int_Flag = addPlate(Dialog, la_plates)
        End If

      On Insert
        Let int_flag = False
        Call inputPlate(Dialog, la_plates, False)
        If Not Int_Flag Then
          Let Int_Flag = addPlate(Dialog, la_plates)
        End If

      On Update
        Let int_flag = False
        Call inputPlate(Dialog, la_plates, True)
        If Not Int_Flag Then
          Let Int_Flag = updatePlate(Dialog, la_plates)
        End If

      On Delete
        Let Int_flag = Not deletePlate(la_plates[Dialog.getCurrentRow("sr_plate")].customer_id,
                                       la_plates[Dialog.getCurrentRow("sr_plate")].plate_id)
    End Display

    On Action mgtcountries
      Let li_countryId = countriesmgt.listCountries()
      If li_countryId >= 0 Then
        Let lr_customer.customer_country = li_countryId
        If lr_customer.customer_country <> lr_oldCustomer.customer_country Then
          Call Dialog.setActionActive("save",true)
          Let hasChanged = True
        Else
          If lr_oldCustomer.* = lr_customer.* Then
            Call Dialog.setActionActive("save",False)
            Let hasChanged = False
          End If
        End If
        Call fillCbCountry( ui.ComboBox.forName("customer_country") )
      End If

    On Action hideimg
      Let fId = ui.Window.getCurrent().getForm()
      Call fId.setFieldHidden("img",isShown := Not isShown )

    On Action close
      Exit Dialog
  End Dialog
End Function

Function inputPlate( Dlg ui.Dialog, la_plates Dynamic Array Of sqlPlates.tyNamedCustPlate, isUpdate Boolean )
  Define
    lr_plate sqlPlates.tyNamedCustPlate,
    la_plateNames Dynamic Array Of String,
    la_plateNamesWithKey Dynamic Array Of sqlPlates.tyPlate

  Let lr_plate = la_plates[Dlg.getCurrentRow("sr_plate")]
  Let int_flag = False
  Input la_plates[Dlg.getCurrentRow("sr_plate")].*
    From sr_plate[SCR_LINE()].*
    Attributes (Without Defaults = isUpdate)

    On Change plate_name
      Call plateNameCompleter( Dialog,
                               la_plateNamesWithKey,
                               la_plateNames,
                               la_plates[Dlg.getCurrentRow("sr_plate")].plate_name)
      If la_plateNames.getLength() = 1 Then
        Let la_plates[Dlg.getCurrentRow("sr_plate")].plate_name = la_plateNames[1]
        Let la_plates[Dlg.getCurrentRow("sr_plate")].plate_id = sqlPlates.plateGetKey(la_plateNames[1])
      Else
        Call Dialog.setCompleterItems(la_plateNames)
      End If

  End Input
  If int_flag Then
    Let la_plates[Dlg.getCurrentRow("sr_plate")] = lr_plate
  End If
End Function

Function plateNameCompleter(
  Dlg ui.Dialog,
  la_plateNamesWithKey Dynamic Array Of sqlPlates.tyPlate,
  la_plateNames Dynamic Array Of String,
  plate_name String
)

  Define
    lr_plateNamesWithKey sqlPlates.tyPlate,
    qry String

  Let qry = "Select * From plates where plate_name Like ? Limit 40"
  If plate_name.getLength() > 0 Then
    Declare cPlatesCompleter Cursor From qry
    Call la_plateNames.clear()
    Call la_plateNamesWithKey.clear()
    Let plate_name = plate_name.append("%")
    Foreach cPlatesCompleter Using plate_name Into lr_plateNamesWithKey.*
      Call la_plateNames.appendElement()
      Let la_plateNames[la_plateNames.getLength()] = lr_plateNamesWithKey.plate_name
    End Foreach
  End If

End Function

Function mgtActions(dlg ui.Dialog, curl Integer ,nbl Integer ) Returns Integer

  Call dlg.setActionActive("first",curl > 1)
  Call dlg.setActionActive("previous",curl > 1)
  Call dlg.setActionActive("next",curl < nbl)
  Call dlg.setActionActive("last",curl < nbl)

  Return curl
End Function

Function fillCbCountry( cbId ui.ComboBox )
  Define
    lr_country sqlCountries.tyCountry

  Call cbId.clear()
  While readCountries( lr_country, Null )
    Call cbId.addItem(lr_country.country_id,lr_country.country_name)
  End While
End Function