function ConvertTo-PsvTable {
    
    param(
        [Parameter(Mandatory)]
        [psobject]$Object
    )

    $Output = "<table>`n<colgroup>$("<col>" * ($Object[0].psobject.Properties | Measure-Object).Count)</colgroup>`n"
    $Output += $Object[0].psobject.Properties |
        ForEach-Object -Begin {"<tr>"} -Process {"<th>$($_.Name)</th>"} -End {"</tr>`n"}

    foreach ($obj in $Object) {
        $Output += "<tr>"
        foreach ($property in $Object[0].psobject.Properties) {
            $Output += "<td>$($obj.($property.Name))</td>"
        }
        $Output += "</tr>`n"
    }
    $Output += "</table>"

    return $Output
}