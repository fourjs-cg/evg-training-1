-- Module Variables
Type
  tyCustomer Record
    customer_id integer,
    customer_name char(50),
    join_date date
  End Record,
  tyPlates Record
    customer_id integer,
    plate_id integer,
    plate_name char(50),
    plate_rate integer
  End Record

Main
  Define
    ls_customer tyCustomer,
    nbl Integer

  Call createDB()

  Open Form f1 From "ftest"
  Display Form f1

    Call browseCustomers()

  Close Form f1

  Disconnect All
End Main

Function browseCustomers()
  Define
    qry String

  Let qry = "Select * From customers Order By customer_id"
  Prepare pBrowseCustomers From qry
  Declare cBrowseCustomers Scroll Cursor For pBrowseCustomers
  Open cBrowseCustomers

  Call initPlates()

  Call navigateCustomers()

  Close cBrowseCustomers
  Free cBrowseCustomers
  Free pBrowseCustomers
End Function

Function navigateCustomers()
  Define
    lr_customer tyCustomer,
    la_plates Dynamic Array Of tyPlates

  Call readCustomer(lr_customer, "first")
  Call fillPlates( lr_customer.customer_id, la_plates )

  Dialog Attributes (unbuffered)
    Input By Name lr_customer.* Attributes (Without Defaults)
      On Action first
        Call readCustomer(lr_customer, "first")
        Call fillPlates( lr_customer.customer_id, la_plates )
      On Action previous
        Call readCustomer(lr_customer, "previous")
        Call fillPlates( lr_customer.customer_id, la_plates )
      On Action next
        Call readCustomer(lr_customer, "next")
        Call fillPlates( lr_customer.customer_id, la_plates )
      On Action last
        Call readCustomer(lr_customer, "last")
        Call fillPlates( lr_customer.customer_id, la_plates )
      On Action dummy
        Display "Hello"
    End Input

    Display Array la_plates To sr_plate.*
    End Display

    On Action close
      Exit Dialog
  End Dialog
End Function

Function readCustomer(lr_customer tyCustomer InOut, way String)
  Case way.toLowerCase()
    When "first"
      Fetch First cBrowseCustomers Into lr_customer.*
    When "previous"
      Fetch Prior cBrowseCustomers Into lr_customer.*
    When "next"
      Fetch Next cBrowseCustomers Into lr_customer.*
    When "last"
      Fetch Last cBrowseCustomers Into lr_customer.*
    Otherwise
      Fetch Absolute way cBrowseCustomers Into lr_customer.*
  End Case
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
    join_date date
    )
  Insert Into customers Values (0,"Jane Doe",Today)
  Insert Into customers Values (1,"John Doe",Today)
  Insert Into customers Values (2,"Mike Doe",Today)
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