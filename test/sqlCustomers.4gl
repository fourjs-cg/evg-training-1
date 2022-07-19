Import FGL utilities

Schema firstapp

Public Type
  tyCustomer Record Like customers.*

Public Define
  qryString String

Private Define
  isCursorOpen Boolean

Public Function setQry( s String )
  -- Tests
  Let qryString = s
End Function

Public Function updateCustomer( hasChanged Boolean, 
                                requestValidation Boolean, 
                                lr_customer tyCustomer InOut, 
                                lr_oldCustomer tyCustomer ) 
                Returns Boolean
  Define
    doIt Boolean,
    lr_dbCustomer tyCustomer

  Let doIt = False
  If hasChanged Then
    Let doIt = True
  End If
  If doIt And requestValidation Then
    If Not utilities.askHim("Updates are here","question","Save your updates?") Then
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
            join_date = lr_customer.join_date,
            customer_country = lr_customer.customer_country
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

Function readDbCustomer( keyval Like customers.customer_id )
  Define
    lr_Customer tyCustomer

  Select * Into lr_Customer.* From customers Where customer_id = keyval

  Return lr_Customer.*
End Function

Function readCustomer( lr_customer tyCustomer InOut, 
                       way String, 
                       forceRefresh Boolean ) 
         Returns tyCustomer

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

Function deleteCustomer( li_customer_id Like customers.customer_id )
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
