Function Build-Function{
    Param (
        [Parameter(Position=0)]
        [String]
        $FunctionName = ""
    )
    If($FunctionName -eq ""){
        Write-Host "No function name provided, please choose from the following options:"
        $yml = (Get-Content -Path template.yaml | ConvertFrom-Yaml)
        $options = [ordered]@{}
        $i = 0
        $yml.Resources.GetEnumerator() | `
            Where-Object {$_.Value.Type -eq "AWS::Serverless::Function"} |  `
            Sort-Object -Property Key | `
            ForEach-Object { 
                $options.Add($i,$_.Key)
                $i++
            }
        $options.GetEnumerator() | ForEach-Object {Write-Host "$($_.Key): $($_.Value)"}
        Write-Host "> " -NoNewLine
        $choice = [int](Read-Host)
        if(!$options.Contains($choice)){
            Write-Host "Invalid option"
            break
        }
        $FunctionName = $options[$choice]
    }

    sam build $FunctionName -b temp

    if($LASTEXITCODE -ne 0){
        break
    }

    Write-Host "Fixing YAML"

    $yml = (Get-Content -Path temp\template.yaml | ConvertFrom-Yaml)
    $yml.Resources.Values | Where-Object {$_.Type -eq "AWS::Serverless::Function"} | ForEach-Object {If ($_.Properties.CodeUri.StartsWith("..\")) {$_.Properties.CodeUri = $_.Properties.CodeUri.Substring(3)}}
    ConvertTo-Yaml $yml > temp\output.yaml

    If(Test-Path .aws-sam\build\$FunctionName){
        Remove-Item .aws-sam\build\$FunctionName -Force -Recurse
    }

    Write-Host "Replacing binaries"
    Copy-Item temp\$FunctionName .aws-sam\build\$FunctionName -Force -Recurse
    Write-Host "Replacing template.yaml"
    Copy-Item temp\output.yaml .aws-sam\build\template.yaml -Force -Recurse
    Write-Host "Cleaning up"
    Remove-Item temp -Force -Recurse
    Write-Host "Function $FunctionName was built successfully, don't forget to deploy if needed!"
}

Export-ModuleMember -Function Build-Function