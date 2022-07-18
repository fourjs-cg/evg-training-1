Public Function countLines( tbl String, wcl String )
  Define
    qry String,
    nbl Integer

  Let qry = "Select Count(*) From "
  If tbl is not null Then
    Let qry = qry.append(tbl)
    If wcl Is Not Null Then
      Let qry = qry.append(" Where ")
      Let qry = qry.append(" "||wcl)
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
  Define
    i SmallInt,
    s String

  Connect To ":memory:+driver='dbmsqt'"
  Create Table countries (
    country_id Integer,
    country_name varchar(100)
  )
  Insert Into countries Values (0,"Germany")
  Insert Into countries Values (1,"France")
  Insert Into countries Values (2,"United Kingdom")
  Insert Into countries Values (3,"Belguim")
  Insert Into countries Values (4,"Swiss")
  Insert Into countries Values (5,"Spain")
  Insert Into countries Values (6,"Portugal")
  Insert Into countries Values (7,"Italy")
  Insert Into countries Values (8,"Austria")
  Create Table customers (
    customer_id integer,
    customer_name char(50),
    join_date date,
    img varchar(100),
    customer_country integer
    )
  Insert Into customers Values (0,"Jane Doe",Today,"https://4js.com/wp-content/uploads/2021/09/eric_byrnes_b.jpg",0)
  Insert Into customers Values (1,"John Doe",Today,"https://4js.com/wp-content/uploads/2021/09/Kirk_Cameron_b.jpg",1)
  Insert Into customers Values (2,"Mike Doe",Today,"https://4js.com/wp-content/uploads/2021/09/Allan_Wilson2b.jpg",2)
  Insert Into customers Values (3,"Jane Doe2",Today,"https://4js.com/wp-content/uploads/2021/09/eric_byrnes_b.jpg",3)
  Insert Into customers Values (4,"John Doe2",Today,"https://4js.com/wp-content/uploads/2021/09/Kirk_Cameron_b.jpg",4)
  Insert Into customers Values (5,"Mike Doe2",Today,"https://4js.com/wp-content/uploads/2021/09/Allan_Wilson2b.jpg",5)
  Insert Into customers Values (6,"Jane Doe3",Today,"https://4js.com/wp-content/uploads/2021/09/eric_byrnes_b.jpg",6)
  Insert Into customers Values (7,"John Doe4",Today,"https://4js.com/wp-content/uploads/2021/09/Kirk_Cameron_b.jpg",7)
  Insert Into customers Values (8,"Mike Doe5",Today,"https://4js.com/wp-content/uploads/2021/09/Allan_Wilson2b.jpg",8)
  Create Table plates (
    plate_id integer,
    plate_name char(50)
  )
  For i = 1 To 1000
    Let s = SFMT("%1 Plate",i)
    Insert Into plates Values (i,s)
  End For
  Create Table custplates (
    customer_id integer,
    plate_id integer,
    plate_rate integer
    )
  For i = 1 To 1000
    Insert Into custplates Values (0,i,5)
  End For
  For i = 1 To 500
    Insert Into custplates Values (1,i,2)
  End For
  For i = 1 To 800
    Insert Into custplates Values (2,i,3)
  End For
  For i = 1 To 200
    Insert Into custplates Values (3,i,4)
  End For
  For i = 1 To 12
    Insert Into custplates Values (5,i,5)
  End For
End Function
