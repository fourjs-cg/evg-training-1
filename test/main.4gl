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
  End Record

Define
  ms_contact_name String

Main
  Define
    ls_customer tyCustomer,
    la_customers Dynamic Array Of tyCustomer,
    --ls_customer_name String,
    nbl Integer

  Call createDB()

  Select Count(*) Into nbl From tst1
  Display nbl

  Select customer_name Into ls_customer.customer_name From tst1 Where customer_id = 1
  --Let ls_customer.customer_name = "Doe"
  Let ms_contact_name = ""
  Let gs_company_name = Null

  --Close Window screen
  --Open Window w1 With Form "ftest"

  Open Form f1 From "ftest"
  Display Form f1

    --Display ls_customer_name To ls_customer_name
    --Display By Name ls_customer_name
    --Menu "test"
    --  On Action close
    --    Exit Menu
    --End Menu

    --Input ls_customer_name From ls_customer_name
    Let int_flag = False
    Input By Name ls_customer.customer_name Without Defaults

    If Not int_flag Then
      Try
        Update tst1 Set customer_name = ls_customer.customer_name Where customer_id = 1
      Catch
        Error "Error while update: ",Sqlca.sqlcode, " ",SQLERRMESSAGE
      End Try
    End If

    Call readCustomers(la_customers)
    Display Array la_customers To sr_customers.*

    Call browseCustomers()

  Close Form f1
  --Close Window w1

  Disconnect All
End Main

Function browseCustomers()
  Define
    qry String,
    lr_customer tyCustomer

  Let qry = "Select * From tst1 Order By customer_id"
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

Function readCustomers( la_customers Dynamic Array Of tyCustomer )
  Define
    qry String,
    lr_customer tyCustomer

  Call la_customers.clear()
  Let qry = "Select * From tst1 Order By customer_id"
  Prepare pReadCustomers From qry
  Declare cReadCustomers Cursor For pReadCustomers
  Foreach cReadCustomers Into lr_customer.*
    Call la_customers.appendElement()
    Let la_customers[la_customers.getLength()].* = lr_customer.*
  End Foreach
  Free cReadCustomers
  Free pReadCustomers
End Function

Function createDB()
  Connect To ":memory:+driver='dbmsqt'"
  Create Table tst1 (
    customer_id integer,
    customer_name char(50),
    join_date date
    )
  Insert Into tst1 Values (0,"Jane Doe",Today)
  Insert Into tst1 Values (1,"John Doe",Today)
  Insert Into tst1 Values (2,"Mike Doe",Today)
End Function