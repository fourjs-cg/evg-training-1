Public Type
  tyPlate Record
    plate_id integer,
    plate_name varchar(100)
  End Record,
  tyCustPlate Record
    customer_id integer,
    plate_id integer,
    plate_rate integer
  End Record,
  tyNamedCustPlate Record
    customer_id integer,
    plate_id integer,
    plate_rate integer,
    plate_name varchar(100)
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

Public Function addPlate(Dlg ui.Dialog, la_plates Dynamic Array Of tyNamedCustPlate) Returns Boolean
  Define
    isOk Boolean = True

  Try
    Insert Into custplates
     Values (la_plates[Dlg.getCurrentRow("sr_plate")].customer_id,
             la_plates[Dlg.getCurrentRow("sr_plate")].plate_id,
             la_plates[Dlg.getCurrentRow("sr_plate")].plate_rate)
  Catch
    Let isOk = False
    Error "Insert plate Error: ",Sqlca.sqlcode," ",SqlErrMessage
  End Try

  Return isOk
End Function

Public Function updatePlate(Dlg ui.Dialog, la_plates Dynamic Array Of tyNamedCustPlate) Returns Boolean
  Define
    isOk Boolean = True

  Try
    Update custplates
       Set plate_id = la_plates[Dlg.getCurrentRow("sr_plate")].plate_id,
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

  Let qry = "Select custplates.*,plates.plate_id,plates.plate_name From custplates Left Join plates On custplates.plate_id = plates.plate_id Where custplates.customer_id = ? order by plate_id"
  Prepare pReadPlates From qry
  Declare cReadPlates Scroll Cursor For pReadPlates
End Function

Function fillPlates( customer_id Integer, la_plates Dynamic Array Of tyNamedCustPlate, startRow Integer, endRow Integer )
  Define
    lr_plate tyNamedCustPlate,
    d Integer,
    i Integer = 0

  --Display endRow
  Call la_plates.clear()
  Open cReadPlates Using customer_id
  While i < endRow
    Fetch Absolute startRow+i cReadPlates 
     Into lr_plate.customer_id,
          lr_plate.plate_id,
          lr_plate.plate_rate,
          d,
          lr_plate.plate_name
    Call la_plates.appendElement()
    Let la_plates[la_plates.getLength()].* = lr_plate.*
    Let i = i + 1
  End While
  Close cReadPlates

End Function

Function plateGetKey( ls_plateName String )
  Define
    li_plate_id Integer

  Select plate_id Into li_plate_id From plates Where plate_name = ls_plateName
  Return li_plate_id
End Function