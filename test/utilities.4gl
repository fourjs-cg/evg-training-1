Function askHim( ttl String, img String, msg String) Returns Boolean
  Define
    answer Boolean

  Menu ttl
    Attributes (style="dialog",image= img,comment= msg)

    Command "Yes"
      Let answer = True
      Exit Menu
    Command "No"
      Let answer = False
      Exit Menu
  End Menu

  Return answer
End Function
