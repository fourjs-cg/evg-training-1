Public Function countLines( tbl String, wcl String )
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
  Insert Into customers Values (3,"Jane Doe2",Today,"https://4js.com/wp-content/uploads/2021/09/eric_byrnes_b.jpg")
  Insert Into customers Values (4,"John Doe2",Today,"https://4js.com/wp-content/uploads/2021/09/Kirk_Cameron_b.jpg")
  Insert Into customers Values (5,"Mike Doe2",Today,"https://4js.com/wp-content/uploads/2021/09/Allan_Wilson2b.jpg")
  Insert Into customers Values (6,"Jane Doe3",Today,"https://4js.com/wp-content/uploads/2021/09/eric_byrnes_b.jpg")
  Insert Into customers Values (7,"John Doe4",Today,"https://4js.com/wp-content/uploads/2021/09/Kirk_Cameron_b.jpg")
  Insert Into customers Values (8,"Mike Doe5",Today,"https://4js.com/wp-content/uploads/2021/09/Allan_Wilson2b.jpg")
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
