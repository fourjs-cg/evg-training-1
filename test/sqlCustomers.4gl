Public Type
  tyCustomer Record
    customer_id integer,
    customer_name char(50),
    join_date date,
    img varchar(100)
  End Record

Public Define
  qryString String

Private Define
  isCursorOpen Boolean

Public Function setQry( s String )
  -- Tests
  Let qryString = s
End Function

Public Function updateCustomer( hasChanged Boolean, requestValidation Boolean, lr_customer tyCustomer InOut, lr_oldCustomer tyCustomer ) Returns Boolean
  Define
    doIt Boolean,
    lr_dbCustomer tyCustomer

  Let doIt = False
  If hasChanged Then
    Let doIt = True
  End If
  If doIt And requestValidation Then
    If Not askHim("Updates are here","question","Save your updates?") Then
      Let doIt = False
      Let hasChanged = False
    End If
  End If
  If doIt Then
    Call readDbCustomer(lr_customer.customer_id) Returning lr_dbCustomer.*
    If lr_dbCustomer.customer_id <> lr_oldCustomer.customer_id Then
    End If
    If lr_dbCustomer.join_date <> lr_oldCustomer.join_date Then
    End If
  End If
  If doIt Then
    Try
      Update customers
        Set customer_name = lr_customer.customer_name,
            join_date = lr_customer.join_date
        Where customer_id = lr_customer.customer_id
      Let hasChanged = False
    Catch
      Error "Customer Update: ",Sqlca.sqlcode," ",SqlErrMessage
    End Try
  End If
  Return hasChanged
End Function

Private Function init( withPrepare Boolean )
  If withPrepare Then
    Prepare pBrowseCustomers From qryString
    Declare cBrowseCustomers Scroll Cursor For pBrowseCustomers
  End If
  Open cBrowseCustomers
  Let isCursorOpen = True
End Function

Function readDbCustomer( keyval Integer )
  Define
    lr_Customer tyCustomer

  Select * Into lr_Customer.* From customers Where customer_id = keyval

  Return lr_Customer.*
End Function

Function readCustomer(lr_customer tyCustomer InOut, way String, forceRefresh Boolean ) Returns tyCustomer
  If Not isCursorOpen Then
    Call init( True )
  End If
  If forceRefresh Then
    Call closeCustomers( False )
    Call init( False )
  End If

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

  Return lr_customer.*
End Function

Public Function closeCustomers( withFree Boolean )
  Whenever Error Continue
  Close cBrowseCustomers
  If withFree Then
    Free cBrowseCustomers
    Free pBrowseCustomers
  End If
  Whenever Error Stop
End Function

Function askHim( ttl String, img String, msg String)
  Menu ttl
    Attributes (style="dialog",image= img,comment= msg)

    Command "Yes"
      Return True
    Command "No"
      Return False
  End Menu
End Function

Function deleteCustomer( li_customer_id Integer )
  Define
    Ok Boolean

  Let Ok = True
  Try
    Delete From customers Where customer_id = li_customer_id
  Catch
    Error "Delete customer: ", Sqlca.sqlcode," ", SqlErrMessage
    Let Ok = False
  End Try

  Return Ok
End Function

#+ Unit test
Function main()
End Function