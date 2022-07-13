Import util

Type
  tyPools DYNAMIC ARRAY OF RECORD
    datasetid STRING,
    recordid STRING,
    fields RECORD
        accessforelder FLOAT,
        exceptions STRING,
        accessforblind FLOAT,
        name STRING,
        address STRING,
        idsurfs STRING,
        serviceandactivities STRING,
        additionalinformation STRING,
        normalizedalias STRING,
        instagramurl STRING,
        images STRING,
        accessfordeaf FLOAT,
        accessforwheelchair FLOAT,
        exceptionalschedule STRING,
        phone STRING,
        mail STRING,
        description STRING,
        access STRING,
        point_geo DYNAMIC ARRAY OF FLOAT,
        characteristics STRING,
        friendlyurl STRING,
        schedulelinkname STRING,
        imageurl STRING,
        instagramname STRING,
        schedulelinkurl STRING,
        periods STRING,
        hasurlschedule FLOAT,
        accessfordeficient FLOAT,
        websitename STRING,
        facebookname STRING,
        websiteurl STRING,
        facebookurl STRING,
        accessfordisabled STRING
    END RECORD,
    geometry RECORD
        type STRING,
        coordinates DYNAMIC ARRAY OF FLOAT
    END RECORD,
    record_timestamp STRING
END RECORD,
  tyPoolFrequentation DYNAMIC ARRAY OF RECORD
    datasetid STRING,
    recordid STRING,
    fields RECORD
        occupation FLOAT,
        isopen FLOAT,
        sigid STRING,
        name STRING,
        dayschedule STRING,
        realtimestatus STRING,
        types STRING,
        updatedate STRING
    END RECORD,
    record_timestamp STRING
END RECORD,
  tyPoolFreq Record
    name String,
    address String,
    isOpen String,
    occupation Integer
  End Record

Main
  Define
    fileId base.Channel,
    jsonStr String,
    pools tyPools,
    poolFrequentation tyPoolFrequentation,
    poolFreq Dynamic Array Of tyPoolFreq,
    i,j Integer

  Let fileId = base.Channel.create()
  Call fileId.openFile("lieux_piscines.json","r")
  Let jsonStr = fileId.readLine()
  Call fileId.close()
  --Display util.JSON.proposeType( jsonStr )
  Call util.JSON.parse( jsonStr, pools )
  --Display pools[1].fields.name

  Let fileId = base.Channel.create()
  Call fileId.openFile("frequentation-en-temps-reel-des-piscines.json","r")
  Let jsonStr = fileId.readLine()
  Call fileId.close()
  Call util.JSON.parse( jsonStr, poolFrequentation )

  Open Form f1 From "pools"
  Display Form f1

    For i=1 To pools.getLength()
      Let poolFreq[i].name = pools[i].fields.name
      Let poolFreq[i].address = pools[i].fields.address
      Let j = searchRow( poolFrequentation,pools[i].fields.idsurfs )
      Case poolFrequentation[j].fields.isopen
        When 0
          Let poolFreq[i].isOpen = "font:FontAwesome.ttf:f05c:red"
        When 1
          Let poolFreq[i].isOpen = "font:FontAwesome.ttf:f05d:green"
        Otherwise
          Let poolFreq[i].isOpen = "font:FontAwesome.ttf:f059:blue"
      End Case
      Let poolFreq[i].occupation = poolFrequentation[j].fields.occupation
    End For
    Display Array poolFreq To srPoolFreq.*
      Before Row
        Display pools[Dialog.getCurrentRow("srpoolfreq")].fields.phone To phone
        Display pools[Dialog.getCurrentRow("srpoolfreq")].fields.mail To mail
        Display pools[Dialog.getCurrentRow("srpoolfreq")].fields.websiteurl To websiteurl
        Display pools[Dialog.getCurrentRow("srpoolfreq")].fields.imageurl To imageurl
    End Display

  Close Form f1
End Main

Function searchRow( poolFrequentation tyPoolFrequentation, keyval String ) Returns Integer
  Define
    i Integer

  For i=1 To poolFrequentation.getLength()
    If poolFrequentation[i].fields.sigid = keyval Then
      Exit For
    End If
  End For
  If i=poolFrequentation.getLength() 
     And poolFrequentation[i].fields.sigid <> keyval 
  Then
    Let i = 0
  End If

  Return i
End Function