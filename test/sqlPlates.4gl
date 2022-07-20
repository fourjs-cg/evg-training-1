Schema firstapp

Public Type
  tyPlate Record Like plates.*,
  tyCustPlate Record Like custplates.*,
  tyNamedCustPlate Record
    customer_id Like custplates.customer_id,
    plate_id Like custplates.plate_id,
    plate_rate Like custplates.plate_rate,
    plate_name like plates.plate_name
  End Record

Public Function deletePlate(li_customer_id Like custplates.customer_id, 
                            li_plate_id Like custplates.plate_id) 
                Returns Boolean
  Define
    isOk Boolean = True

  Try
    Delete From custplates
     Where customer_id = li_customer_id 
       And plate_id = li_plate_id
  Catch
    Let isOk = False
    --Display __LINE__," ",__FILE__
    Call myErrorLog(__FILE__,"Remove plate Error: "||Sqlca.sqlcode||" "||SqlErrMessage)
    Error "Remove plate Error: ",Sqlca.sqlcode," ",SqlErrMessage
  End Try

  Return isOk
End Function

Public Function addPlate(Dlg ui.Dialog, 
                         la_plates Dynamic Array Of tyNamedCustPlate) 
                Returns Boolean
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

Public Function updatePlate(Dlg ui.Dialog, 
                            la_plates Dynamic Array Of tyNamedCustPlate) 
                Returns Boolean
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

Function initPlates( wcl String, ordby String, ordway String )
  Define
    qry String

  Let qry = "Select custplates.*,plates.plate_id,plates.plate_name From custplates Left Join plates On custplates.plate_id = plates.plate_id Where custplates.customer_id = ?"
  Let qry = qry," And "||wcl," order by "||NVL(ordby||" "||Iif(ordway,"ASC","DESC"),"plate_id")
  Prepare pReadPlates From qry
  Declare cReadPlates Scroll Cursor For pReadPlates
End Function

Function fillPlates( customer_id Integer, 
                     la_plates Dynamic Array Of tyNamedCustPlate, 
                     startRow Integer, 
                     endRow Integer )
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

Function endPlates()
  Whenever Error Continue
  Close cReadPlates
  Free cReadPlates
  Free pReadPlates
  Whenever Error Stop
End Function

Function plateGetKey( ls_plateName Like plates.plate_name )
  Define
    li_plate_id Like plates.plate_id

  Select plate_id Into li_plate_id From plates Where plate_name = ls_plateName
  Return li_plate_id
End Function