-- Module Variables
Type
  tyCustomer Record
    customer_id integer,
    customer_name char(50),
    join_date date,
    img varchar(100)
  End Record,
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

  Let qry = "Select * From customers Order By customer_id"
  Prepare pBrowseCustomers From qry
  Declare cBrowseCustomers Scroll Cursor For pBrowseCustomers
  Open cBrowseCustomers

  Call initPlates()

  Let nbl = countlines("customers", Null)
  Call navigateCustomers( nbl )

  Close cBrowseCustomers
  Free cBrowseCustomers
  Free pBrowseCustomers
End Function

Function countLines( tbl String, wcl String )
  Define
    qry String,
    nbl Integer

  Let qry = "Select Count(*) From "
  If tbl is not null Then
    Let qry = qry.append(tbl)
    If wcl Is Not Null Then
      --
    End If
    Prepare pCountTblRows From qry
    Execute pCountTblRows Into nbl
    Free pCountTblRows
  Else
    Let nbl = -1
  End If

  Return nbl
End Function

Function navigateCustomers( nbl Integer )
  Define
    lr_customer tyCustomer,
    la_plates Dynamic Array Of tyPlates,
    curl Integer

  If nbl < 0 Then
    Error "Something went wrong"
  End If

  Dialog Attributes (unbuffered)
    Input By Name lr_customer.* Attributes (Without Defaults)
      Before Input
        Call readCustomer(lr_customer, "first")
        Call fillPlates( lr_customer.customer_id, la_plates )
        Let curl = mgtActions(DIALOG,1,nbl)
      On Action first
        Call readCustomer(lr_customer, "first")
        Call fillPlates( lr_customer.customer_id, la_plates )
        Let curl = mgtActions(DIALOG,1,nbl)
      On Action previous
        Call readCustomer(lr_customer, "previous")
        Call fillPlates( lr_customer.customer_id, la_plates )
        Let curl = mgtActions(DIALOG,curl - 1,nbl)
      On Action next
        Call readCustomer(lr_customer, "next")
        Call fillPlates( lr_customer.customer_id, la_plates )
        Let curl = mgtActions(DIALOG,curl + 1,nbl)
      On Action last
        Call readCustomer(lr_customer, "last")
        Call fillPlates( lr_customer.customer_id, la_plates )
        Let curl = mgtActions(DIALOG,nbl,nbl)
      On Action dummy
        Display "Hello"
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

Function readCustomer(lr_customer tyCustomer InOut, way String)
  Message ""
  try
  Case way.toLowerCase()
    When "first"
      Fetch First cBrowseCustomers Into lr_customer.*
    When "previous"
      Fetch Prior cBrowseCustomers Into lr_customer.*
      If sqlca.sqlcode == NotFound Then
        Message "No more row in this direction"
      End If
    When "next"
      Fetch Next cBrowseCustomers Into lr_customer.*
      If sqlca.sqlcode == NotFound Then
        Message "No more row in this direction"
      End If
    When "last"
      Fetch Last cBrowseCustomers Into lr_customer.*
    Otherwise
      Fetch Absolute way cBrowseCustomers Into lr_customer.*
  End Case
  Catch
    Error sqlca.sqlcode
  End Try
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

Function createDB()
  Connect To ":memory:+driver='dbmsqt'"
  Create Table customers (
    customer_id integer,
    customer_name char(50),
    join_date date,
    img varchar(100)
    )
  Insert Into customers Values (0,"Jane Doe",Today,"https://4js.com/wp-content/uploads/2021/09/eric_byrnes_b.jpg")
  Insert Into customers Values (1,"John Doe",Today,"https://4js.com/wp-content/uploads/2021/09/Kirk_Cameron_b.jpg")
  Insert Into customers Values (2,"Mike Doe",Today,"https://4js.com/wp-content/uploads/2021/09/Allan_Wilson2b.jpg")
  Create Table custplates (
    customer_id integer,
    plate_id integer,
    plate_name char(50),
    plate_rate integer
    )
  Insert Into custplates Values (0,0,"Pizza",5)
  Insert Into custplates Values (0,1,"Pasta",2)
  Insert Into custplates Values (0,2,"Fried Vegs",4)
  Insert Into custplates Values (1,0,"Pizza",3)
  Insert Into custplates Values (1,1,"Pasta",5)
  Insert Into custplates Values (1,2,"Fried Vegs",2)
  Insert Into custplates Values (2,0,"Pizza",1)
  Insert Into custplates Values (2,1,"Pasta",2)
  Insert Into custplates Values (2,2,"Fried Vegs",5)
End Function