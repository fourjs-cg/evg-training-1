Public Type
  tyPlates Record
    customer_id integer,
    plate_id integer,
    plate_name char(50),
    plate_rate integer
  End Record

Public Function deletePlate(li_customer_id Integer, li_plate_id Integer) Returns Boolean
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

Public Function addPlate(Dlg ui.Dialog, la_plates Dynamic Array Of tyPlates) Returns Boolean
  Define
    isOk Boolean = True

  Try
    Insert Into custplates
     Values (la_plates[Dlg.getCurrentRow("sr_plate")].*)
  Catch
    Let isOk = False
    Error "Insert plate Error: ",Sqlca.sqlcode," ",SqlErrMessage
  End Try

  Return isOk
End Function

Public Function updatePlate(Dlg ui.Dialog, la_plates Dynamic Array Of tyPlates) Returns Boolean
  Define
    isOk Boolean = True

  Try
    Update custplates
       Set plate_name = la_plates[Dlg.getCurrentRow("sr_plate")].plate_name,
           plate_rate = la_plates[Dlg.getCurrentRow("sr_plate")].plate_rate
     Where customer_id = li_customer_id 
       And plate_id = li_plate_id
  Catch
    Let isOk = False
    Error "Update plate Error: ",Sqlca.sqlcode," ",SqlErrMessage
  End Try

  Return isOk
End Function

Function initPlates()
  Define
    qry String

  Let qry = "Select * From custplates Where customer_id = ? order by plate_id"
  Prepare pReadPlates From qry
  Declare cReadPlates Scroll Cursor For pReadPlates
End Function

Function fillPlates( customer_id Integer, la_plates Dynamic Array Of tyPlates, startRow Integer, endRow Integer )
  Define
    lr_plate tyPlates,
    i Integer = 0

  --Display endRow
  Call la_plates.clear()
  Open cReadPlates Using customer_id
  While i < endRow
    Fetch Absolute startRow+i cReadPlates Into lr_plate.*
    Call la_plates.appendElement()
    Let la_plates[la_plates.getLength()].* = lr_plate.*
    Let i = i + 1
  End While
  Close cReadPlates

End Function
