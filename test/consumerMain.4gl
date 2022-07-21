Import com

Main
  Define
    urlStr String,
    url    com.HttpRequest,
    ans    com.HttpResponse,
    ret    smallInt

  Menu "Pools"
    Command "Nb Pools"
      Let urlStr = "http://127.0.0.1:8099/poolService/pools/count"
      Let url = com.HttpRequest.Create(urlStr)
      Call url.setMethod("GET")
      Call url.doRequest()

      Let ans = url.getResponse()
      Display ans.getStatusCode()

    Command "Exit"
      Exit Menu
  End Menu

End Main