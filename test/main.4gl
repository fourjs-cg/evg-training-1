Import FGL mySqlUtilities
Import FGL sqlCustomers

-- Module Variables
Type
  tyPlates Record
    customer_id integer,
    plate_id integer,
    plate_name char(50),
    plate_rate integer
  End Record

Main
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
        Call fillPlates( lr_customer.customer_id, la_plates )
        Let curl = mgtActions(DIALOG,1,nbl)
        Call Dialog.setActionActive("save",false)

      On Change customer_name, join_date
        Call Dialog.setActionActive("save",true)
        Let hasChanged = True

      On Action first
        Let hasChanged = sqlCustomers.updateCustomer( hasChanged, True, lr_customer, lr_oldCustomer.* )
        Call readCustomer(lr_customer, "first", False)  Returning lr_oldCustomer.*
        Call Dialog.setActionActive("save",false)
        Call fillPlates( lr_customer.customer_id, la_plates )
        Let curCust = mgtActions(DIALOG,1,nbl)

      On Action previous
        Let hasChanged = sqlCustomers.updateCustomer( hasChanged, True, lr_customer, lr_oldCustomer.* )
        Call readCustomer(lr_customer, "previous", False) Returning lr_oldCustomer.*
        Call Dialog.setActionActive("save",false)
        Call fillPlates( lr_customer.customer_id, la_plates )
        Let curCust = mgtActions(DIALOG,curCust - 1,nbl)

      On Action next
        Let hasChanged = sqlCustomers.updateCustomer( hasChanged, True, lr_customer, lr_oldCustomer.* )
        Call readCustomer(lr_customer, "next", False)  Returning lr_oldCustomer.*
        Call Dialog.setActionActive("save",false)
        Call fillPlates( lr_customer.customer_id, la_plates )
        Let curCust = mgtActions(DIALOG,curCust + 1,nbl)

      On Action last
        Let hasChanged = sqlCustomers.updateCustomer( hasChanged, True, lr_customer, lr_oldCustomer.* )
        Call readCustomer(lr_customer, "last", False) Returning lr_oldCustomer.*
        Call Dialog.setActionActive("save",false)
        Call fillPlates( lr_customer.customer_id, la_plates )
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

    Display Array la_plates To sr_plate.*
    End Display

    On Action close
      Exit Dialog
  End Dialog
End Function

Function mgtActions(dlg ui.Dialog, curl Integer ,nbl Integer ) Returns Integer

  Call dlg.setActionActive("first",curl > 1)
  Call dlg.setActionActive("previous",curl > 1)
  Call dlg.setActionActive("next",curl < nbl)
  Call dlg.setActionActive("last",curl < nbl)

  Return curl
End Function

Function initPlates()
  Define
    qry String

  Let qry = "Select * From custplates Where customer_id = ? order by plate_id"
  Prepare pReadPlates From qry
  Declare cReadPlates Cursor For pReadPlates
End Function

Function fillPlates( customer_id Integer, la_plates Dynamic Array Of tyPlates )
  Define
    lr_plate tyPlates

  Call la_plates.clear()
  Foreach cReadPlates Using customer_id Into lr_plate.*
    Call la_plates.appendElement()
    Let la_plates[la_plates.getLength()].* = lr_plate.*
  End Foreach

End Function
