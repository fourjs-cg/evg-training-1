Import FGL mySqlUtilities
Import FGL sqlCustomers
Import FGL sqlPlates

Main
  Call ui.Interface.loadStyles("mystyle")
  Call createDB()

  Open Form f1 From "ftest"
  Display Form f1

    Call browseCustomers()

  Close Form f1

  Disconnect All
End Main

Function browseCustomers()
  Define
    qry String,
    nbl Integer

  Call sqlCustomers.setQry("Select * From customers Order By customer_id")
  Call initPlates()

  Let nbl = mySqlUtilities.countLines("customers", Null)
  Call navigateCustomers( nbl )

  Call sqlCustomers.closeCustomers(True)
End Function

Function navigateCustomers( nbl Integer )
  Define
    lr_customer tyCustomer,
    lr_oldCustomer tyCustomer,
    la_plates Dynamic Array Of tyPlates,
    curl Integer,
    curCust Integer,
    cntPlate Integer = 0,
    hasChanged Boolean,
    inputMode Char(1)

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

      On Change customer_name, join_date
        Call Dialog.setActionActive("save",true)
        Let hasChanged = True

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

      On Action refresh
        Call readCustomer(lr_customer, curCust, True) Returning lr_oldCustomer.*

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
        Call fillPlates( lr_customer.customer_id, la_plates, fgl_dialog_getbufferstart(), fgl_dialog_getbufferlength() )

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

    On Action close
      Exit Dialog
  End Dialog
End Function

Function inputPlate( Dlg ui.Dialog, la_plates Dynamic Array Of sqlPlates.tyPlates, isUpdate Boolean )
  Define
    lr_plate sqlPlates.tyPlates

  Let lr_plate = la_plates[Dlg.getCurrentRow("sr_plate")]
  Let int_flag = False
  Input la_plates[Dlg.getCurrentRow("sr_plate")].* From sr_plate[Dlg.getCurrentRow("sr_plate")].*
    Attributes (Without Defaults = isUpdate)
  If int_flag Then
    Let la_plates[Dlg.getCurrentRow("sr_plate")] = lr_plate
  End If
End Function

Function mgtActions(dlg ui.Dialog, curl Integer ,nbl Integer ) Returns Integer

  Call dlg.setActionActive("first",curl > 1)
  Call dlg.setActionActive("previous",curl > 1)
  Call dlg.setActionActive("next",curl < nbl)
  Call dlg.setActionActive("last",curl < nbl)

  Return curl
End Function
