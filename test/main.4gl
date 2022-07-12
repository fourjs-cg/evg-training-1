--Import

-- Schema

-- Global Variables
Globals
  Define
    gs_company_name String

End Globals

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
    Call browsePlates()

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

  Call navigateCustomers()

  Close cBrowseCustomers
  Free cBrowseCustomers
  Free pBrowseCustomers
End Function

Function navigateCustomers()
  Define
    lr_customer tyCustomer

  Call readCustomer(lr_customer, "first")
  Display By Name lr_customer.*
  Menu
    On Action first
      Call readCustomer(lr_customer, "first")
      Display By Name lr_customer.*
    On Action previous
      Call readCustomer(lr_customer, "previous")
      Display By Name lr_customer.*
    On Action next
      Call readCustomer(lr_customer, "next")
      Display By Name lr_customer.*
    On Action last
      Call readCustomer(lr_customer, "last")
      Display By Name lr_customer.*
    On Action close
      Exit Menu
  End Menu
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

Function browsePlates()
  Define
    la_plates Dynamic Array Of tyPlates,
    lr_plate tyPlates,
    qry String

  Call la_plates.clear()
  Let qry = "Select * From custplates order by plate_id"
  Prepare pReadPlates From qry
  Declare cReadPlates Cursor For pReadPlates
  Foreach cReadPlates Into lr_plate.*
    Call la_plates.appendElement()
    Let la_plates[la_plates.getLength()].* = lr_plate.*
  End Foreach

  Display Array la_plates To sr_plate.*
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
End Function