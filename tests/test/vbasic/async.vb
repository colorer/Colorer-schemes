Public Async Function FetchAsync() As Task(Of String)
    Dim name = NameOf(FetchAsync)
    Return Await IO.ReadAsync()
End Function

Public Iterator Function Items() As IEnumerable(Of Integer)
    Yield 1
End Function
