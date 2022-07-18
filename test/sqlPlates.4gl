Public Type
  tyPlates Record
    customer_id integer,
    plate_id integer,
    plate_name char(50),
    plate_rate integer
  End Record

Function deletePlate(li_customer_id Integer, li_plate_id Integer) Returns Boolean
  Define
    isOk Boolean = True

  Try
    Delete From custplates
     Where customer_id = li_customer_id 
       And plate_id = li_plate_id
  Catch
    Let isOk = False
    Error "Remove plate Error: ",Sqlca.sqlcode," ",SqlErrMessage
  End Try

  Return isOk
End Function
