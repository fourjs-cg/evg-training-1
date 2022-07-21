Import util

Public Type
  tyMenuCmd Record
    btName  String,
    btLabel String,
    btActive Boolean,
    btHidden Boolean,
    btAnswer String
  End Record

Function askHim( ttl String, img String, msg String, JsonStr String) Returns Boolean
  Define
    answer String,
    JsonArr util.JSONArray,
    bts Dynamic Array Of tyMenuCmd,
    i SmallInt

  Let JsonArr = util.JSONArray.parse( JsonStr )
  Call JsonArr.toFGL(bts)

  For i = bts.getLength()+1 To 10
    Let bts[i].btName = "bt"||i
    Let bts[i].btLabel = "bt"||i
    Let bts[i].btActive = False
    Let bts[i].btHidden = True
  End For

  Menu ttl
    Attributes (style="dialog",image= img,comment= msg)

    Before Menu
      For i = 1 To bts.getLength()
        Call Dialog.setActionActive(bts[i].btName,bts[i].btActive)
        Call Dialog.setActionHidden(bts[i].btName,bts[i].btHidden)
      End For
      For i = bts.getLength()+1 To 10
        Call Dialog.setActionActive(bts[i].btName,False)
        Call Dialog.setActionHidden(bts[i].btName,True)
      End For

    Command bts[1].btName bts[1].btLabel
      Let answer = bts[1].btAnswer
      Exit Menu
    Command bts[2].btName bts[2].btLabel
      Let answer = bts[2].btAnswer
      Exit Menu
    Command bts[3].btName bts[3].btLabel
      Let answer = bts[3].btAnswer
      Exit Menu
    Command bts[4].btName bts[4].btLabel
      Let answer = bts[4].btAnswer
      Exit Menu
    Command bts[5].btName bts[5].btLabel
      Let answer = bts[5].btAnswer
      Exit Menu
    Command bts[6].btName bts[6].btLabel
      Let answer = bts[6].btAnswer
      Exit Menu
    Command bts[7].btName bts[7].btLabel
      Let answer = bts[7].btAnswer
      Exit Menu
    Command bts[8].btName bts[8].btLabel
      Let answer = bts[8].btAnswer
      Exit Menu
    Command bts[9].btName bts[9].btLabel
      Let answer = bts[9].btAnswer
      Exit Menu
    Command bts[10].btName bts[10].btLabel
      Let answer = bts[10].btAnswer
      Exit Menu
  End Menu

  Return answer
End Function

Function myErrorLog(FileNAme String,msg String)
  Call ErrorLog("["||Current Year To Second||" In "||fileName||"] "||msg)
End Function