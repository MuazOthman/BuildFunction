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

    # TODO: should adjust parsing behavior to skip parsing dates #1
    $yml = (Get-Content -Path temp\template.yaml | ConvertFrom-Yaml)

    # CodeUri must match function logical name according to SAM build, see #2
    $yml.Resources.GetEnumerator() | Where-Object {$_.Value.Type -eq "AWS::Serverless::Function"} | ForEach-Object {$_.Value.Properties.CodeUri = $_.Key}
    
    # custom code to serialize YAML without breaking date-like strings for versions, a temporary solution for #1
    $sb = New-Object -TypeName YamlDotNet.Serialization.SerializerBuilder
    [array]$foo = $null
    $sb = $sb.WithTypeConverter((New-Object -TypeName YamlDotNet.Serialization.Converters.DateTimeConverter -ArgumentList Utc, $foo, @("yyyy-MM-dd")))
    $ser = $sb.Build()
    $ymlString = $ser.Serialize($yml)

    # Updated YAML saving to encode in UTF8, see #3
    If(!(Test-Path ".\temp"))
    {
        New-Item -ItemType Directory -Force -Path ".\temp"
    }
    $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
    [System.IO.File]::WriteAllText((Join-Path -Path (Get-Location) -ChildPath "temp\output.yaml"), $ymlString, $Utf8NoBomEncoding)

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